#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
 
/************************************************************
This is a simple send/receive program in MPI
************************************************************/

int main(int argc, char **argv ,char **envp)
{
    int myid, numprocs;
    int tag,source,destination,count;
    int buffer;
    int ierr;
    MPI_Status status;
 
    ierr=MPI_Init(&argc,&argv);
    ierr=MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    ierr=MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    tag=1234;
    source=0;
    destination=1;
    count=1;
    if(myid == source){
		buffer=5678;
		ierr=MPI_Send(&buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD);
		printf("processor %d  sent %d\n",myid,buffer);
    }
    if(myid == destination){
        ierr=MPI_Recv(&buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&status);
        printf("processor %d  got %d\n",myid,buffer);
    }
    ierr=MPI_Finalize();
}
