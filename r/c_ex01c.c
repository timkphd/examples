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
    int buffer[4];
    int ic;
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
    count=4;
    for (ic=1;ic<4;ic++){
    if(myid == source){
      buffer[0]=100+ic;
      buffer[1]=200+ic;
      buffer[2]=300+ic;
      buffer[3]=400+ic;
      MPI_Send(&buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD);
        printf("C processor %d  send %d %d %d %d\n",myid,buffer[0],
                                                        buffer[1],
                                                        buffer[2],
                                                        buffer[3]);

    }
    if(myid == destination){
        MPI_Recv(&buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&status);
        printf("C processor %d   got %d %d %d %d\n",myid,buffer[0],
                                                        buffer[1],
                                                        buffer[2],
                                                        buffer[3]);
    }
    }
    MPI_Finalize();
}
