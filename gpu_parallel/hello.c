#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
/************************************************************
 * This is a simple hello world program. Each processor prints out 
 * it's rank and the size of the current MPI run (Total number of
 * processors).
 * ************************************************************/
int main(int argc,char **argv)
{
    int myid, numprocs;
    FILE *f1;
	int num_devices;
    int i,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME];
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
	cudaGetDeviceCount(&num_devices);
    printf("C says Hello from %4d on %s with %d gpus\n",myid,myname,num_devices);
/*    printf("Numprocs is %d\n",numprocs); */
    MPI_Finalize();
    
}

