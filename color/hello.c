#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
int node_color();
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
int main(int argc, char **argv)
{
    int myid,numprocs,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
    printf(" color=%4d Hello from %s on %s %d %d\n",node_color(),argv[0],myname,myid,numprocs);
    MPI_Finalize();
}

