#include <stdio.h>
#include "mpi.h"
int main(int argc,char *argv[])
{
/* "ID" related variables*/
  int myid, numprocs;
  int source,destination,root;

/* variable we are going to pass around */
  int value;
  
/* some variables required by MPI */
  MPI_Status status; 
  int tag;
  tag=1234;
  
/*  Start MPI */  
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  
/*  value we are going to send is only defined on processor 0 */  
    if (myid== 0) value=0;
  
/* 
   we send/rec from processor left/right 
   at the ends it's a null opp
*/
    destination=myid+1;
    if (destination > numprocs) {
      destination=MPI_PROC_NULL;
    }
    
    soruce=myid-1;
    if (source < 0) {
      source=MPI_PROC_NULL;
    }
    
/* rec the value and incement it */
    MPI_Recv(&value,1,MPI_INT,source,tag,MPI_COMM_WORLD,&status);
    printf("processor %d  got %d from %d\n",myid,value,source);
    value=value+1;
    
/* send it on */
    MPI_Send(&value,1,MPI_INT,destination,tag,MPI_COMM_WORLD);
    printf("processor %d  sent %d to\n",myid,value,destination);

/* last processor broadcasts it to all the rest */
    root=numprocs-1;
    MPI_Bcast(&value,   1,MPI_INT,   root,MPI_COMM_WORLD);

  MPI_Finalize();
}