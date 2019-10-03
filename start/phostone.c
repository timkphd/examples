#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <string.h>
#include <omp.h>
#include <ctype.h>
#include <mpi.h>
#include <math.h>
#include <utmpx.h>
char *trim ( char *s );
void slowit(long nints,int val);
int node_color();
int sched_getcpu();

int findcore ()
{
    int cpu;
    cpu = sched_getcpu();
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
}
 
int main(int argc, char **argv,char *envp[])
{
    int myid,numprocs,resultlen;
    int mycolor,new_id,new_nodes;
    int i,k;
    MPI_Comm node_comm;
    char lname[MPI_MAX_PROCESSOR_NAME] ;
#ifdef MPI_MAX_LIBRARY_VERSION_STRING
    char version[MPI_MAX_LIBRARY_VERSION_STRING] ;
#else
    char version[40];
#endif
    char *myname,*cutit;
    int full,envs,iarg,tn,nt,help,slow,vlan,wait;
    long nints;
    double t1,t2,dt;
    char f1234[128],f1235[128],f1236[128];

/* Format statements */
//    char *f1234="%4.4d      %4.4d    %18s        %4.4d         %4.4d  %4.4d\n";
//    char *f1235="%s %4.4d %4.4d\n";
//    char *f1236="%s\n";
    strcpy(f1234,"%4.4d      %4.4d    %18s        %4.4d         %4.4d  %4.4d\n");
    strcpy(f1235,"%s %4.4d %4.4d\n");
    strcpy(f1236,"%s\n");
    MPI_Init(&argc,&argv);
#ifdef MPI_MAX_LIBRARY_VERSION_STRING
    MPI_Get_library_version(version,&vlan);
#else
    sprintf(version,"%s","UNDEFINED - consider upgrading");
#endif
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(lname,&resultlen); 
/* Get rid of "stuff" from the processor name. */
    myname=trim(lname);
/* The next line is required for BGQ because the MPI task ID 
   is encoded in the processor name and we don't want it. */
    if (strrchr(myname,32))myname=strrchr(myname,32);
/* Here we cut off the tail of node name, Summit in this case */
    cutit = strstr(myname, ".rc.int.colorado.edu");
    if(cutit)cutit[0]=(char)0;
    slow=0;
    wait=0;
/* read in command line args from task 0 */
    if(myid == 0 ) {
    	full=0;
    	envs=0;
        help=0;
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
        }
    	}
    }
/* send info to all tasks, if doing help doit and quit */
    MPI_Bcast(&help,1,MPI_INT,0,MPI_COMM_WORLD);
	if(help == 1) {
		if(myid == 0) dohelp();
		MPI_Finalize();
		exit(0);
	}
    MPI_Bcast(&full,1,MPI_INT,0,MPI_COMM_WORLD);
    MPI_Bcast(&envs,1,MPI_INT,0,MPI_COMM_WORLD);
    if(myid == 0 && full == 2){
	printf("MPI VERSION %s\n",version);
    	printf("task    thread             node name  first task    # on node  core\n");
    }
/*********/
/* The routine NODE_COLOR will return the same value for all mpi
   tasks that are running on the same node.  We use this to create
   a new communicator from which we get the numbering of tasks on
   a node. */
//    NODE_COLOR(&mycolor);
    mycolor=node_color();
    MPI_Comm_split(MPI_COMM_WORLD,mycolor,myid,&node_comm);
    MPI_Comm_rank( node_comm, &new_id );
    MPI_Comm_size( node_comm, &new_nodes);
    tn=-1;
    nt=-1;
/* Here we print out the information with the format and
   verbosity determined by the value of full. We do this
   a task at a time to "hopefully" get a bit better formatting. */
    for (i=0;i<numprocs;i++) {
	MPI_Barrier(MPI_COMM_WORLD);
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
/* here we print out the environment in which a MPI task is running */
		if (envs == 1 && new_id==0) {
			k=0;
			while(envp[k]) {
				printf("%s\n",envp[k]);
				k++;
			}
		}
    }
	if(myid == 0){
		dt=0;
		if(wait) {
			slow=0;
			for (iarg=1;iarg<argc;iarg++) {
				if(atof(argv[iarg])> 0)dt=atof(argv[iarg]);
			}
		}
	}
    MPI_Bcast(&dt,1,MPI_DOUBLE,0,MPI_COMM_WORLD);
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
	printf("total time %10.3f\n",t2-t1);
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
    MPI_Bcast(&nints,1,MPI_LONG,0,MPI_COMM_WORLD);
    if(nints > 0){
	t1=MPI_Wtime();
    	for(i=1;i<=1000;i++) {
    		slowit(nints,i);
    	}
	t2=MPI_Wtime();
	printf("total time %10.3f\n",t2-t1);
    }

    MPI_Finalize();
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

/*
! return a integer which is unique to all mpi
! tasks running on a particular node.  It is
! equal to the id of the first MPI task running
! on a node.  This can be used to create 
! MPI communicators which only contain tasks on
! a node.

*/
#include <mpi.h>
#include <string.h>
int node_color() {
int mycol;
MPI_Status status;
int xchng,i,n2,myid,numprocs;
int nlen;
int ie;
char *pch;
char name[MPI_MAX_PROCESSOR_NAME+1];
char nlist[MPI_MAX_PROCESSOR_NAME+1];
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&myid);
MPI_Get_processor_name(name,&nlen); 
pch=strrchr(name,' ');
if(pch) {
	ie=strlen(pch+1);
	memmove(&name[0],pch+1,ie+1);
	memmove(&nlist[0],pch+1,ie+1);
}
else {
	strcpy(nlist,name);
}
mycol=myid;
n2=1;
while (n2 < numprocs) {
	n2=n2*2;
}
    for(i=1;i<=n2-1;i++) {
		xchng=i^myid;
		if(xchng <= (numprocs-1)) {
			if(myid < xchng) {
				MPI_Send(name,MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345, MPI_COMM_WORLD);
				MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME,MPI_CHAR,xchng,12345, MPI_COMM_WORLD, &status);
			}
			else {
				MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME,MPI_CHAR,xchng,12345, MPI_COMM_WORLD, &status);
				MPI_Send(name,MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345, MPI_COMM_WORLD);			
			}
			if (strcmp(nlist,name) == 0 && xchng < mycol)mycol=xchng;
		}
		else {
		/* skip this stage */
		}
    }
return mycol;
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

