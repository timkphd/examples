#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
/************************************************************
This is a simple hello world program. Each processor prints out 
it's rank and the size of the current MPI run (Total number of
processors).
************************************************************/
int main(argc,argv)
int argc;
char *argv[];
{
    int myid, numprocs;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
 

    /* print out my rank and this run's PE size */
    printf("Hello from task %d of %d\n",myid,numprocs);

    MPI_Finalize();
    
}

