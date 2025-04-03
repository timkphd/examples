// Author: Timothy H. Kaiser
//         2010-2025
//         tkaiser2@nrel.gov
//         tkaiserphd@gmail.com
//   Shows mapping of tasks/threads to cores while running stream triad.
//   Typical usage:
//     mpicc -O3 -fopenmp pstream.c -o pstream
//     export OMP_NUM_THREADS=52
//     srun -n 4 --nodes=2 --tasks-per-node=2  ./pstream  -F -t 3 -T -s -2 
//
//     Ideally should have one task/thread per core with no cores overloaded.

#ifndef STREAM_ARRAY_SIZE
#define STREAM_ARRAY_SIZE 10000000
#endif
#ifndef STREAM_TYPE
#define STREAM_TYPE double
#endif


// Normal compile
// Intel:
// mpiicc -qopenmp pstream.c -o pstream
// gcc:
// mpicc  -qopenmp pstream.c -o pstream
//
// To compile without openmp
// Intel:
// mpiicc -qopenmp-stubs pstream.c -o purempi
// gcc:
// mpicc  -DSTUBS        pstream.c -o purempi
#include <ctype.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/time.h>
#include <time.h>
#include <utmpx.h>
#include <unistd.h>
#include <string.h>

int ic = 0;
void dothreads(int full, char *myname, int myid, int mycolor, int new_id);
char *trim(char *s);
void triad(int nints, double val,int verbose);
int node_color();
int sched_getcpu();

int donow(int when,int where){
  return ((when & where) == where);
}

// print a dat/time stamp
void ptime() {
  time_t rawtime;
  struct tm *timeinfo;
  char buffer[80];

  time(&rawtime);
  timeinfo = localtime(&rawtime);
  strftime(buffer, 80, "%c", timeinfo);
  // puts (buffer);
  printf("%s\n", buffer);
}

// find the core for a thread.  Doesn't not work on Mac
int findcore() {
  int cpu;
#ifdef __APPLE__
  cpu = 9999;
#else
  cpu = sched_getcpu();
#endif
  return cpu;
}

// convert a string to upper case 
// used when printing node names
int str_upr(char *cstr) {
  char *str = cstr;

  for (; *str; str++) {
    if (isalpha(*str))
      if (*str >= 'a') {
        *str += 'A' - 'a';
      }
  }
  return 0;
}

// convert a string to lower case 
// used when printing node names
int str_low(char *cstr) {
  char *str = cstr;

  for (; *str; str++) {
    if (isalpha(*str))
      if (*str < 'a') {
        *str += 'a' - 'A';
      }
  }
  return 0;
}

void dohelp(char *appname) {
  /************************************************************
   * This is a glorified hello world program. Each processor
   * prints name, rank, and other information as described below.
   * ************************************************************/
  printf("%s arguments:\n", appname);
  printf("          -h : Print this help message and exit.\n");
  printf("\n");
  printf("no arguments : Print a list of the nodes on which the command is run and exit.\n");
  printf("\n");
  printf(" -f          : When paired with -E, -B, -D print MPI task id and Thread id\n");
  printf("               If run with OpenMP threading enabled OMP_NUM_THREADS > 1\n");
  printf("               there will be a line per MPI task and Thread.\n");
  printf("               If -E, -B, -D are not set then just run for the -t seconds.\n");
  printf("\n");
  printf(" -F          : Add columns to tell first MPI task on a node and the numbering\n");
  printf("               of tasks on a node. Should be paired with paired with -E, -B, -D\n");
  printf("\n");
  printf(" -B, -D, -E  : Print thread pinning at 'B'eginning of the run, 'E'nd of the run,\n");
  printf("               'D'uring, that is, after the first run of triad.\n");
  printf("               Default is to not print thread info.\n");
  printf("               With -B and -E  _B/_E will be appended to the node name.");
  printf("\n");
  printf(" -t ######## : Time in seconds.  Run TRIAD to slow down the program and run\n");
  printf("               for at least the given seconds.\n");
  printf("\n");
  printf(" -s ######## : Constant for TRIAD calculation. If <0 then use abs(s)\n");
  printf("               and reports stats for the calculation.\n");
  printf("\n");
  printf(" -T          : Print time/date at the beginning/end of the run.\n");
  printf("\n");
  printf("Typical run:\n");
  printf("             mpirun -n 2 %s -F -t 4 -D", appname);
  printf("\n");
}

// format strings for output
char f1234[128], f1235[128], f1236[128];



int main(int argc, char **argv, char *envp[]) {
  int myid, numprocs, resultlen;
  int mycolor, new_id, new_nodes;
  int i;
  MPI_Comm node_comm;
  char lname[MPI_MAX_PROCESSOR_NAME];
  char augname[MPI_MAX_PROCESSOR_NAME+3];
  char version[MPI_MAX_LIBRARY_VERSION_STRING];
  char *myname, *cutit;
  int full, help, vlan, dotime, when;
  double t1, t2, dt,scaler;
  int BEGINNING=1;
  int THEEND=2;
  int DURING=4;

  /* Format statements */
  strcpy(f1234, "%4.4d      %4.4d    %18s        %4.4d         %4.4d  %4.4d\n");
  strcpy(f1235, "%s %4.4d %4.4d\n");
  strcpy(f1236, "%s\n");
  
  // MPI setup
  MPI_Init(&argc, &argv);
  MPI_Get_library_version(version, &vlan);
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
  MPI_Get_processor_name(lname, &resultlen);
  /* Get rid of "stuff" from the processor name. */
  myname = trim(lname);
  /* The next line is required for BGQ because the MPI task ID
     is encoded in the processor name and we don't want it. */
  if (strrchr(myname, 32))
    myname = strrchr(myname, 32);
  /* Here we cut off the tail of node name, Summit in this case */
  cutit = strstr(myname, ".rc.int.colorado.edu");
  if (cutit)
    cutit[0] = (char)0;

  /* read in command line args from task 0 */
  if (myid == 0) {
    full = 0;
    help = 0;
    dotime = 0;
    when = 0;
    dt=0.0;
//  printf("%d\n", STREAM_ARRAY_SIZE);
    if (argc > 1) {
      int opt; 
      while ((opt = getopt(argc, argv, "hfFEBDt:Ts:")) != -1) {
        // printf("%c\n",opt);
        switch (opt) {
        case 'h':
          help = 1;
          break;
        case 'f':
          full = 1;
          break;
        case 'F':
          full = 2;
          break;
        case 'E':
          when = when | THEEND;
          break;
        case 'B':
          when = when | BEGINNING;
          break;
        case 'D':
          when = when | DURING;
          break;
        case 't':
          dt = atof(optarg);
          break;
        case 's':
          scaler = atof(optarg);
          break;
        case 'T':
          dotime = 1;
          break;
        default:
          fprintf(stderr, "Usage: %s [-hfFEBT] [-t x.x] [-3 x.x]\n", argv[0]);
          help=1;
          break;
        }
      }
    }
    if (help == 1 )dohelp(argv[0]);
  }
  /* send info to all tasks, if doing help doit and quit */
  MPI_Bcast(&help, 1, MPI_INT, 0, MPI_COMM_WORLD);
  if (help == 1) {
    MPI_Finalize();
    exit(0);
  }
  MPI_Bcast(&full, 1, MPI_INT, 0, MPI_COMM_WORLD);
  MPI_Bcast(&dt, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
  MPI_Bcast(&scaler, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

  if(full == 0 ){
      dothreads(full, myname, myid, 0, 0);
      if(dt == 0) {
        MPI_Finalize();
        exit(0);  
      }    
  }
  MPI_Bcast(&when, 1, MPI_INT, 0, MPI_COMM_WORLD);
  // maybe print start time
  if (myid == 0 && dotime == 1)
    ptime();
  // MPI info and header
  if (myid == 0 && full == 2) {
    printf("MPI VERSION %s\n", version);
    printf("task    thread             node name  first task    # on node  "
           "core\n");
  }
  /*********/
  /* The routine NODE_COLOR will return the same value for all mpi
     tasks that are running on the same node.  We use this to create
     a new communicator from which we get the numbering of tasks on
     a node. */
  mycolor = node_color();
  MPI_Comm_split(MPI_COMM_WORLD, mycolor, myid, &node_comm);
  MPI_Comm_rank(node_comm, &new_id);
  MPI_Comm_size(node_comm, &new_nodes);
  /* Here we print out the information with the format and
     verbosity determined by the value of full. We do this
     a task at a time to "hopefully" get a bit better formatting. */
  for (i = 0; i < numprocs; i++) {
    MPI_Barrier(MPI_COMM_WORLD);
    if (i != myid)
      continue;
      
  if (donow(when,BEGINNING)){       
		// if when == THEEND we will also print thread info at the end of
		// the run so here we set the node name to all lower case and
		// when we print at the end we set to upper case.
		// if (donow(when,THEEND))str_low(myname);
		if(myid == 0 )printf("dothreads BEGINNING %d\n",when);
		  sprintf(augname,"%s_B",myname);
		  dothreads(full, augname, myid, mycolor, new_id);
		  }
  }
  if (dt > 0) {
    t1 = MPI_Wtime();
    t2 = t1;
    // run triad for at least dt seconds
    int tricount;
    tricount=0;
    while (dt > t2 - t1) {
      triad(10, scaler,0);
      t2 = MPI_Wtime();
      tricount++;
      if (donow(when,DURING) && tricount==1){ 
      //if(myid == 0 )printf("dothreads DURING %d\n",when);
      sprintf(augname,"%s",myname);
      dothreads(full, augname, myid, mycolor, new_id);
      }
    }
    // run 1 more time to get results if we want them
    triad(10, scaler,1);
    t2 = MPI_Wtime();
    MPI_Barrier(MPI_COMM_WORLD);
    if (myid == 0)
      printf("total time %10.3f\n", t2 - t1);
  }
  // Maybe print end time
  if (myid == 0 && dotime == 1)
    ptime();
  if (donow(when,THEEND)) {
    for (i = 0; i < numprocs; i++) {
      MPI_Barrier(MPI_COMM_WORLD);
      if (i != myid)
        continue;
        // str_upr(myname);
        if(myid == 0 )printf("dothreads THEEND %d\n",when);
        sprintf(augname,"%s_E",myname);
        dothreads(full, augname, myid, mycolor, new_id);      
    }
  }
  MPI_Finalize();
  return 0;
}

char *trim(char *s) {
  int i = 0;
  int j = strlen(s) - 1;
  int k = 0;

  while (isspace(s[i]) && s[i] != '\0')
    i++;

  while (isspace(s[j]) && j >= 0)
    j--;

  while (i <= j)
    s[k++] = s[i++];

  s[k] = '\0';

  return s;
}

/*
   ! return a integer which is unique to all mpi
   ! tasks running on a particular node.  It is
   ! equal to the id of the first MPI task running
   ! on a node.  This can be used to create
   ! MPI communicators which only contain tasks on
   ! a node.

 */
int node_color() {
  int mycol;
  MPI_Status status;
  int xchng, i, n2, myid, numprocs;
  int nlen;
  int ie;
  char *pch;
  char name[MPI_MAX_PROCESSOR_NAME + 1];
  char nlist[MPI_MAX_PROCESSOR_NAME + 1];

  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
  MPI_Get_processor_name(name, &nlen);
  pch = strrchr(name, ' ');
  if (pch) {
    ie = strlen(pch + 1);
    memmove(&name[0], pch + 1, ie + 1);
    memmove(&nlist[0], pch + 1, ie + 1);
  } else {
    strcpy(nlist, name);
  }
  mycol = myid;
  n2 = 1;
  while (n2 < numprocs) {
    n2 = n2 * 2;
  }
  for (i = 1; i <= n2 - 1; i++) {
    xchng = i ^ myid;
    if (xchng <= (numprocs - 1)) {
      if (myid < xchng) {
        MPI_Send(name, MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345,
                 MPI_COMM_WORLD);
        MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345,
                 MPI_COMM_WORLD, &status);
      } else {
        MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345,
                 MPI_COMM_WORLD, &status);
        MPI_Send(name, MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345,
                 MPI_COMM_WORLD);
      }
      if (strcmp(nlist, name) == 0 && xchng < mycol)
        mycol = xchng;
    } else {
      /* skip this stage */
    }
  }
  return mycol;
}
// a timer.  we don't use MPI_Wtime for historical reasons
double mysecond() {
  struct timeval tp;
  struct timezone tzp;
  gettimeofday(&tp, &tzp);
  return ((double)tp.tv_sec + (double)tp.tv_usec * 1.e-6);
}

// Run triad.  This routine is called in a loop for dt seconds
void triad(int NTIMES, double val,int verbose) {
#include <float.h>

  static double avgtime, maxtime, mintime;
  size_t bytes;
  int myid;
  size_t j, k;
#ifndef MIN
#define MIN(x, y) ((x) < (y) ? (x) : (y))
#endif
#ifndef MAX
#define MAX(x, y) ((x) > (y) ? (x) : (y))
#endif

#ifndef OFFSET
#define OFFSET 0
#endif

  STREAM_TYPE atot;
  STREAM_TYPE scalar;
  if (val >= 0)
    scalar = (STREAM_TYPE)val;
  else
    scalar = -(STREAM_TYPE)val;

  double *times;
  times = (double *)malloc(NTIMES * sizeof(double));

  static STREAM_TYPE a[STREAM_ARRAY_SIZE + OFFSET],
      b[STREAM_ARRAY_SIZE + OFFSET], c[STREAM_ARRAY_SIZE + OFFSET];

  avgtime = 0;
  maxtime = 0;
  mintime = FLT_MAX;
#pragma omp parallel for
  for (j = 0; j < STREAM_ARRAY_SIZE; j++) {
    a[j] = 0.0;
    b[j] = 1.0;
    c[j] = 2.0;
  }
// This is the heart of traid.  The rest is fluff and timing
  for (k = 0; k < NTIMES; k++) {
    times[k] = mysecond();
#pragma omp parallel for
    for (j = 0; j < STREAM_ARRAY_SIZE; j++)
      a[j] = b[j] + scalar * c[j];
    times[k] = mysecond() - times[k];
  }
  atot = 0;
  for (j = 0; j < STREAM_ARRAY_SIZE; j++)
    atot = atot + a[j];
  if (atot < 0)
    printf("%g\n", (double)atot);

  for (k = 1; k < NTIMES; k++) /* note -- skip first iteration */
  {
    avgtime = avgtime + times[k];
    mintime = MIN(mintime, times[k]);
    maxtime = MAX(maxtime, times[k]);
  }
  avgtime = avgtime;
  mintime = mintime;
  maxtime = maxtime;
  avgtime = avgtime / (double)(NTIMES - 1);
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
  bytes = 3 * sizeof(STREAM_TYPE) * STREAM_ARRAY_SIZE;
  ic++;

  if (val < 0 && verbose == 1) {
    if (myid == 0) {
      fprintf(stderr,"STREAM_ARRAY_SIZE= %d\n",STREAM_ARRAY_SIZE);
      fprintf(stderr, "MPI_ID Function    Best Rate MB/s  Avg time     Min "
                      "time     Max time  Called\n");
    }
    fprintf(stderr, "%6d %s  %12.1f      %11.6f  %11.6f  %11.6f  %6d\n", myid,
            "triad", 1.0E-06 * bytes / mintime, avgtime, mintime, maxtime, ic);
  }
  free(times);
}

#ifdef STUBS
int omp_get_thread_num(void) { return 0; }
int omp_get_num_threads(void) { return 1; }
#endif

// prit our thread mappings
void dothreads(int full, char *myname, int myid, int mycolor, int new_id) {
  int nt, tn;

#pragma omp parallel
  {
    nt = omp_get_num_threads();
    if (nt == 0)
      nt = 1;
#pragma omp critical
    {
      if (nt < 2) {
        nt = 1;
        tn = 0;
      } else {
        tn = omp_get_thread_num();
      }
      if (full == 0) {
        if (tn == 0)
          printf(f1236, trim(myname));
      }
      if (full == 1) {
        printf(f1235, trim(myname), myid, tn);
      }
      if (full == 2) {
        printf(f1234, myid, tn, trim(myname), mycolor, new_id, findcore());
      }
    }
  }
}
