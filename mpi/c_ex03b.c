#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
 
/************************************************************
This is a simple isend/ireceive program in MPI
************************************************************/

int idosomething(int i) {
	int j;
    j=i+1;
    return(j);
}

int main(int argc, char **argv ,char **envp)
{
    int myid, numprocs;
    int tag,source,destination,count;
    int *buffer;
    int ic;
    int flag;
    MPI_Status status;
    MPI_Request request;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    ic=0;
    tag=1234;
    source=0;
    destination=1;
    count=100000;
    request=MPI_REQUEST_NULL;
    if(myid == source)printf("vector size %d\n",count);
    buffer=(int*)malloc(((size_t)count)*sizeof(int));
    if(myid == source){
      for(int i=0 ; i< count; i++)buffer[i]=5678;
      printf("%d\n",buffer[0]);
      MPI_Isend(buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD,&request);
    }
    if(myid == destination){
        MPI_Irecv(buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&request);
    }
    MPI_Test (&request, &flag, &status);
    while (! flag) {
    	ic=idosomething(ic);
    	MPI_Test (&request, &flag, &status);
    }
    if(myid == source){
      printf("processor %d  sent %d called idosomething %d times\n",myid,buffer[0],ic);
      
    }
    if(myid == destination){
      printf("processor %d  got  %d called idosomething %d times\n",myid,buffer[0],ic);
    }
    MPI_Finalize();
}

