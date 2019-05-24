#include <stdio.h>
#include "mpi.h"
int main(int argc,char *argv[])
{
  int myid, numprocs, tag,source,destination,count, buffer;
  MPI_Status status; 
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  tag=1234;    count=1;
  if(myid == 0){
    buffer=5678;
    MPI_Send(&buffer,count,MPI_INT,1,tag,MPI_COMM_WORLD);
    printf("processor %d  sent %d\n",myid,buffer);
  }
  if(myid == 1){
    MPI_Recv(&buffer,count,MPI_INT,0,tag,MPI_COMM_WORLD,&status);
    printf("processor %d  got %d\n",myid,buffer);
  }
  MPI_Finalize();
}
