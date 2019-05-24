/************************************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank, number of tasks, and processor name. 
************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
void dostuff(int myid,int argc,char *argv[]);

int main(int argc,char *argv[])
{
    int myid, numprocs;
    FILE *f1;
    int i,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME];
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
    printf("C %4d of %4d says Hello from %s\n",myid, numprocs ,myname);
    MPI_Finalize();
}
