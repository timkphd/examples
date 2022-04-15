#include <stdio.h>
#include "mpi.h"
int main(int argc,char *argv[])
{
/* "ID" related variables*/
  int myid, numprocs;
  int source,destination;

/* Variable we are going to pass around */
  int value;
  
/* Some variables required by MPI */
  MPI_Status status; 
  
/*  Start MPI */  
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  
/*  Value we are going to send is only defined on processor 0 */  
    if (myid== 0) value=0;
  
/* 
   We rec/send from processor left/right; at the ends it's a null opp
*/
    destination=myid+1;
    if (destination > numprocs-1) {
      destination=MPI_PROC_NULL;
    }
    
    source=myid-1;
    if (source < 0) {
      source=MPI_PROC_NULL;
    }
    
/* Rec the value and increment it */
    MPI_Recv(&value,1,MPI_INT,source,1234,MPI_COMM_WORLD,&status);
    printf("processor %d  got %d from %d\n",myid,value,source);
    value=value+1;
    
/* Send it on */
    MPI_Send(&value,1,MPI_INT,destination,1234,MPI_COMM_WORLD);
    printf("processor %d  sent %d to %d\n",myid,value,destination);

/* Last processor broadcasts it to all the rest */
    int root=numprocs-1;
    MPI_Bcast(&value,   1,MPI_INT,   root,MPI_COMM_WORLD);
    printf("final value %d\n",value);

/*  Stop MPI */  
  int ierr=MPI_Finalize();
  return(ierr);
}
