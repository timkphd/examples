#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int getcount(int task, char* node  );
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
    printf("Hello from %s %d %d\n",myname,myid,numprocs);
//nvcc -c subcount.c 
//nvcc -L/nopt/nrel/apps/210928a/level01/gcc-9.4.0/openmpi-4.1.1/lib -I/nopt/nrel/apps/210928a/level01/gcc-9.4.0/openmpi-4.1.1/include helloc.c  subcount.o  -lmpi
    getcount(myid,myname);
    MPI_Finalize();
}

