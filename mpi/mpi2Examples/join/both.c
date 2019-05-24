#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int s2(int argc, char *argv[]);
int cs3(int argc, char *argv[]);

 
/************************************************************
This is a simple hello world program. Each processor prints out 
it's rank and the size of the current MPI run (Total number of
processors).
************************************************************/
int main(int argc,char **argv)
{
    int myid, numprocs;
    FILE *f1;
    int i,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME];
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
    printf("C says Hello from %4d on %s\n",myid,myname);
    if(myid  == 0) {
    	cs3(0, (char**)(0));
    }
    else {
    	s2(0, (char**)(0));
    }
/*    printf("Numprocs is %d\n",numprocs); */
    MPI_Finalize();
    
}
