// Normal compile
// Intel:
// mpiicc -qopenmp phostone.c -o phostone
// gcc:
// mpicc  -qopenmp phostone.c -o phostone
//
// To compile without openmp 
// Intel:
// mpiicc -qopenmp-stubs phostone.c -o purempi
// gcc:
// mpicc  -DSTUBS        phostone.c -o purempi
//
//
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <omp.h>
#include <ctype.h>
//#include <mpi.h>
#include <unistd.h>
#include <math.h>
#include <utmpx.h>
#include <time.h>

#define MPI_Wtime omp_get_wtime 
// which processor on a node will 
// print env if requested
#ifndef PID
#define PID 0
#endif

char *trim ( char *s );
void slowit(long nints,int val);
int sched_getcpu();

void ptime(){
  time_t rawtime;
  struct tm * timeinfo;
  char buffer [80];
  time (&rawtime);
  timeinfo = localtime (&rawtime);
  strftime (buffer,80,"%c",timeinfo);
  //puts (buffer);
  printf("%s\n",buffer);
}
int findcore ()
{
    int cpu;
#ifdef __APPLE__
    cpu=-1;
#else
    cpu = sched_getcpu();
#endif
    return cpu;
}
void dohelp();
void dohelp() {

/************************************************************
 * This is a glorified hello world program. Each processor 
 * prints name, rank, and other information as described below.
 * ************************************************************/
printf("phostname arguments:\n");
printf("          -h : Print this help message\n");
printf("\n");
printf("no arguments : Print a list of the nodes on which the command is run.\n");
printf("\n");
printf(" -f or -1    : Same as no argument but print MPI task id and Thread id\n");
printf("               If run with OpenMP threading enabled OMP_NUM_THREADS > 1\n");
printf("               there will be a line per MPI task and Thread.\n");
printf("\n");
printf(" -F or -2    : Add columns to tell first MPI task on a node and and the\n");
printf("               numbering of tasks on a node. (Hint: pipe this output in\n");
printf("               to sort -r\n");
printf("\n");
printf(" -a          : Print a listing of the environmental variables passed to\n");
printf("               MPI task. (Hint: use the -l option with SLURM to prepend MPI\n");
printf("               task #.)\n");
printf("\n");
printf(" -s ######## : Where ######## is an integer.  Sum a bunch on integers to slow\n");
printf("               down the program.  Should run faster with multiple threads.\n");
printf("\n");
printf(" -t ######## : Where is a time in seconds.  Sum a bunch on integers to slow\n");
printf("               down the program and run for at least the given seconds.\n");
printf("\n");
printf(" -T          : Print time/date at the beginning/end of the run.\n");
printf("\n");
}
 
int main(int argc, char **argv,char *envp[])
{
    int myid,numprocs,resultlen;
    int mycolor,new_id,new_nodes;
    int i,k;
    char version[40];
    char myname[128];
    int full,envs,iarg,tn,nt,help,slow,vlan,wait,dotime;
    long nints;
    double t1,t2,dt;
    char f1234[128],f1235[128],f1236[128];


    strcpy(f1234,"%4.4d      %4.4d    %18s        %4.4d         %4.4d  %4.4d\n");
    strcpy(f1235,"%s %4.4d %4.4d\n");
    strcpy(f1236,"%s\n");
    sprintf(version,"%s","Pure OpenMP version");
    numprocs=1;
    myid=0;
    newid=0;
    gethostname(myname, 128);
    slow=0;
    wait=0;
/* read in command line args from task 0 */
    if(myid == 0 ) {
    	full=0;
    	envs=0;
        help=0;
        dotime=0;
    	if (argc > 1 ) {
    	  for (iarg=1;iarg<argc;iarg++) {
    	  	if ( (strcmp(argv[iarg],"-h")    == 0) || 
    	  	     (strcmp(argv[iarg],"--h")   == 0) ||
    	  	     (strcmp(argv[iarg],"-help") == 0) )  help=1;
/**/
    	  	if ((strcmp(argv[iarg],"-f") == 0)     || 
    	  	    (strcmp(argv[iarg],"-1") == 0) )      full=1;
/**/
    	  	if ( (strcmp(argv[iarg],"-F") == 0)    ||
    	  	     (strcmp(argv[iarg],"-2") == 0) )     full=2;
/**/
    	  	if (strcmp(argv[iarg],"-s") == 0)     slow=1;
/**/
    	  	if (strcmp(argv[iarg],"-t") == 0)     wait=1;
/**/
    	  	if (strcmp(argv[iarg],"-a") == 0)         envs=1;
/**/
    	  	if (strcmp(argv[iarg],"-T") == 0)         dotime=1;
        }
    	}
    }
/* send info to all tasks, if doing help doit and quit */
	if(help == 1) {
		if(myid == 0) dohelp();
		exit(0);
	}
    if(myid == 0 && dotime == 1)ptime();
    if(myid == 0 && full == 2){
    	
	printf("MPI VERSION %s\n",version);
    	printf("task    thread             node name  first task    # on node  core\n");
    }
/*********/
/* The routine NODE_COLOR will return the same value for all mpi
   tasks that are running on the same node.  We use this to create
   a new communicator from which we get the numbering of tasks on
   a node. */
    mycolor=0;
    tn=-1;
    nt=-1;
/* Here we print out the information with the format and
   verbosity determined by the value of full. We do this
   a task at a time to "hopefully" get a bit better formatting. */
    for (i=0;i<numprocs;i++) {
        if ( i != myid ) continue;
#pragma omp parallel 
	{
		nt=omp_get_num_threads();
		if ( nt == 0 ) nt=1;
#pragma omp critical 
		{
			if ( nt < 2 ) {
			  nt=1;
			  tn=0;
			}
			else {
				tn=omp_get_thread_num();
			}
			if(full == 0) {
				if(tn == 0)printf(f1236,trim(myname));
			}
			if(full == 1) {
				printf(f1235,trim(myname),myid,tn);
			}
			if(full == 2){
				printf(f1234,myid,tn,trim(myname),mycolor,new_id,findcore());
			}
		}
	 }
		if (envs == 1 && new_id==PID) {
			k=0;
			while(envp[k]) {
				printf("%s\n",envp[k]);
				k++;
			}
		}
    }
	if(myid == 0){
		dt=0;
		if(wait ) {
			slow=0;
			for (iarg=1;iarg<argc;iarg++) {
				//printf("%s\n",argv[iarg]);
				if(atof(argv[iarg])> 0)dt=atof(argv[iarg]);
			}
		}
	}
    if(dt > 0){
		nints=100000;
		t1=MPI_Wtime();
		t2=t1;
		while(dt > t2-t1) {
			for(i=1;i<=1000;i++) {
				slowit(nints,i);
			}
			t2=MPI_Wtime();
		}
	if(myid == 0)printf("total time %10.3f\n",t2-t1);
	nints=0;
	}
	if(myid == 0){
		nints=0;
		if(slow == 1) {
			for (iarg=1;iarg<argc;iarg++) {
				if(atol(argv[iarg])> 0)nints=atol(argv[iarg]);
			}
		}
	}
    if(nints > 0){
	t1=MPI_Wtime();
    	for(i=1;i<=1000;i++) {
    		slowit(nints,i);
    	}
	t2=MPI_Wtime();
	if(myid == 0)printf("total time %10.3f\n",t2-t1);
    }

    if(myid == 0 && dotime == 1)ptime();
    return 0;
}

char *trim ( char *s )
{
  int i = 0;
  int j = strlen ( s ) - 1;
  int k = 0;
 
  while ( isspace ( s[i] ) && s[i] != '\0' )
    i++;
 
  while ( isspace ( s[j] ) && j >= 0 )
    j--;
 
  while ( i <= j )
    s[k++] = s[i++];
 
  s[k] = '\0';
 
  return s;
}



void slowit(long nints, int val) {
	int *block;
	long i,sum;
#ifdef VERBOSET
	double t2,t1;
	t1=MPI_Wtime();
#endif
	block=(int*)malloc(nints*sizeof(int));
#pragma omp parallel for
	for (i=0;i<nints;i++) {
		block[i]=val;
	}
sum=0;
#pragma omp parallel for reduction(+:sum)
	for (i=0;i<nints;i++) {
		sum=sum+block[i];
	}
#ifdef VERBOSET
	t2=MPI_Wtime();
	printf("sum of integers %ld %10.3f\n",sum,t2-t1);
#endif
	free(block);
}

#ifdef STUBS
int omp_get_thread_num(void) { return 0; }
int omp_get_num_threads(void){ return 1; }
#endif

