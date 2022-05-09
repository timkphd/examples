#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
/************************************************************
This is a simple send/receive program in MPI
************************************************************/

int main(argc,argv)
int argc;
char *argv[];
{
    int myid, numprocs;
    int tag,source,destination,count;
    int buffer;
    MPI_Status status;
    int *maxtag;
    int flag;
    int ierr;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    tag=1422709;
    ierr=MPI_Comm_get_attr(MPI_COMM_WORLD, MPI_TAG_UB, &maxtag, &flag);
    printf("%d %d %d\n",*maxtag,flag,ierr);
    printf("warning maxtag is %d tag is %d\n",*maxtag,tag);
    source=0;
    destination=1;
    count=1;
    if(myid == source){
      buffer=5678;
      MPI_Send(&buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD);
      printf("processor %d  sent %d\n",myid,buffer);
    }
    if(myid == destination){
        MPI_Recv(&buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&status);
        printf("processor %d  got %d\n",myid,buffer);
    }
    MPI_Finalize();
}
