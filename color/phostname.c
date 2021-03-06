#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <mpi.h>
#include <math.h>
char *trim ( char *s );
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

}
 
int main(int argc, char **argv,char *envp[])
{
    int myid,numprocs,resultlen;
    int mycolor,new_id,new_nodes;
    int i,k;
    MPI_Comm node_comm;
    char lname[MPI_MAX_PROCESSOR_NAME] ;
    char *myname;
    int full,envs,iarg,thr,tn,nt,help;

/* Format statements */
    char *f1234="%4.4d      %4.4d    %18s        %4.4d         %4.4d\n";
    char *f1235="%s %4.4d %4.4d\n";
    char *f1236="%s\n";

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(lname,&resultlen); 
/* Get rid of "stuff" from the processor name. */
    myname=trim(lname);
/* The next line is required for BGQ because the MPI task ID 
   is encoded in the processor name and we don't want it. */
    if (strrchr(myname,32))myname=strrchr(myname,32);
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
    	printf("task    thread             node name  first task    # on node\n");
    }
/*********/
/* The routine NODE_COLOR will return the same value for all mpi
   tasks that are running on the same node.  We use this to create
   a new communicator from which we get the numbering of tasks on
   a node. */
    NODE_COLOR(&mycolor);
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
				printf(f1234,myid,tn,trim(myname),mycolor,new_id);
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

    MPI_Finalize();
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

