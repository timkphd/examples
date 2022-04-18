#include <stdio.h>
#include "mpi.h"
int main(int argc,char *argv[])
{
/* "ID" related variables*/
  int myid, numprocs;
  int left,right;

/* Variables we are going to pass around */
  int value;
  int sendl,sendr,recvl,recvr;
  int iterations,iter;
  int res,gres;
  

  
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
    right=myid+1;
    if (right > numprocs-1) {
      right=MPI_PROC_NULL;
    }
    
    left=myid-1;
    if (left < 0) {
      left=MPI_PROC_NULL;
    }
    

sendl= 100+myid;
sendr= 200+myid; 
recvl=-1000;
recvr=-1000;
/* Zeroth processor broadcasts # iterations to all the rest */
    int root=0;
    if (myid == root) iterations=3;
    MPI_Bcast(&iterations,   1,MPI_INT,   root,MPI_COMM_WORLD);
    printf("proc %d got %6d %6d with bcast value %6d\n",myid,recvl,recvr,value); 

for (iter=0 ;iter< iterations;iter++) {
  if((myid % 2) == 0){
/* send to left */
      MPI_Send(&sendl,1,MPI_INT,left,10, MPI_COMM_WORLD);
/* rec from left */
      MPI_Recv(&recvl,1,MPI_INT,left,10,MPI_COMM_WORLD,&status);
/* rec from right */
      MPI_Recv(&recvr,1,MPI_INT,right,10,MPI_COMM_WORLD,&status);
/* send to right */
      MPI_Send(&sendr,1,MPI_INT,right,10, MPI_COMM_WORLD);
    }
  else{
/* rec from right */
      MPI_Recv(&recvr,1,MPI_INT,right,10,MPI_COMM_WORLD,&status);
/* send to right */
      MPI_Send(&sendr,1,MPI_INT,right,10,MPI_COMM_WORLD);
/* send to left */
      MPI_Send(&sendl,1,MPI_INT,left,10,MPI_COMM_WORLD);
/* rec from left */
      MPI_Recv(&recvl,1,MPI_INT,left,10,MPI_COMM_WORLD,&status);
    }

  res=recvl+recvr+iter;
  MPI_Allreduce(&res, &gres, 1,MPI_INT, MPI_SUM, MPI_COMM_WORLD);
  printf("%d %d\n",myid,gres);
}
/*  Stop MPI */  
  int ierr=MPI_Finalize();
  return(ierr);
}
