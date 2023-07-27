#include <stdio.h>
#include <mpi.h>
#include <omp.h>
int sched_getcpu();
/************************************************************
This is a simple hybrid hello world program.
Prints MPI information 
For each task/thread
  task id
  node name for task
  thread id
  # of threads for the task
  core on which the thread is running
************************************************************/
int main(int argc, char **argv)
{
    int myid,numtasks,resultlen;
    char version[MPI_MAX_LIBRARY_VERSION_STRING];
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    int vlan;
    int myt,nt,mycore;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numtasks);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
    if (myid == 0 ) {
	    printf(" C MPI TASKS %d\n",numtasks);
	    MPI_Get_library_version(version, &vlan);
	    printf("%s\n",version);
    }
#pragma omp parallel
  {
    nt = omp_get_num_threads();
    myt= omp_get_thread_num();
    mycore=sched_getcpu();
#pragma omp critical
    printf("task %d running on %s  thread %d of %d on core %d\n",
		    myid,myname,myt,nt,mycore);
  }
    MPI_Finalize();
}

