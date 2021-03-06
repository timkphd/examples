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
    int myid, numprocs,aflag;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Comm_test_inter(MPI_COMM_WORLD, &aflag);

    /* print out my rank and this run's PE size */
    printf("Hello from task %d of %d %d \n",myid,numprocs,aflag);

    MPI_Finalize();
    
}

