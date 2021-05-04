#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
/************************************************************
This is a simple send/receive program in MPI
************************************************************/

int main(int argc,char *argv[])
{
    int myid, numprocs;
    int tag,source,destination,count,resultlen;
    int buffer;
    MPI_Status status;
    char myname[MPI_MAX_PROCESSOR_NAME] ;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
    printf("C Hello from %s %d %d\n",myname,myid,numprocs);
    tag=1234;
    source=0;
    destination=1;
    count=1;
    if(myid == source){
      buffer=5678;
      MPI_Send(&buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD);
      printf(" C processor %d  sent %d\n",myid,buffer);
    }
    if(myid == destination){
        MPI_Recv(&buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&status);
        printf("C processor %d  got %d\n",myid,buffer);
    }
    MPI_Finalize();
}
