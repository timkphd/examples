#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
 
/************************************************************
This is a simple hello world program. Each processor prints out 
it's rank and the size of the current MPI run (Total number of
processors).
************************************************************/
int main(int argc, char **argv ,char **envp)
{
    int ierr, myid, numprocs;
 
    ierr=MPI_Init(&argc,&argv);
    ierr=MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    ierr=MPI_Comm_rank(MPI_COMM_WORLD,&myid);

/* print out my rank and this run's  size */
    printf("Hello from task %d of %d\n",myid,numprocs);

    ierr=MPI_Finalize();
    
}

