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
    int tag,source,destination,count,resultlen,times;
    int *buffer;
    int ic;
    MPI_Status status;
    char myname[MPI_MAX_PROCESSOR_NAME] ;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
    printf("C Hello from %s # %d of %d\n",myname,myid,numprocs);
    tag=1234;
    source=0;
    destination=1;
// number of times we will exchange data
    times=3;
// length of the vector to exchange
    count=4;
// these can be on the command line
//srun -n 2 ./c_ex01c 3 4
    if (myid == 0){
        if (argc > 1) {
            times=atoi(argv[1]);
        }
        if (argc > 2) {
            count=atoi(argv[2]);
        }
    }
      MPI_Bcast(&times,1,MPI_INT,0, MPI_COMM_WORLD);
      MPI_Bcast(&count,1,MPI_INT,0, MPI_COMM_WORLD);

    buffer=(int*)malloc(count*sizeof(int));
    for (ic=1;ic<=times;ic++){
    if(myid == source){
        for(int i=0;i<count;i++) {
            buffer[i]=100*i+ic;
        }
      MPI_Send(buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD);

printf("C processor %d  send",myid);
         for(int i=0;i<count;i++) {
             printf(" %d ",buffer[i]);
         }
printf("\n");
    }
    if(myid == destination){
        MPI_Recv(buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&status);

printf("C processor %d   got",myid);
         for(int i=0;i<count;i++) {
             printf(" %d ",buffer[i]);
         }
printf("\n");

    }
    }
    MPI_Finalize();
}
