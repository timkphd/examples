#include <stdio.h>
#include "mpi.h"
int main(int argc,char *argv[])
{
/* "ID" related variables*/
  int myid, numprocs;
  int left,right;

/* Variables we are going to pass around */
  float value,newval;
  float sendl,sendr,recvl,recvr;
  float dv,gres;
  
  int iterations,iter;

  
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
    

recvl=-1000;
recvr=-1000;
value=10000;
/* Zeroth processor broadcasts # iterations to all the rest */
    int root=0;
    if (myid == root) iterations=5
    ;
    MPI_Bcast(&iterations,   1,MPI_INT,   root,MPI_COMM_WORLD);
    printf("proc %d got %6d %6d with bcast value %6d\n",myid,recvl,recvr,value); 

for (iter=0 ;iter< iterations;iter++) {
  sendl=value;
  sendr=value;
  if((myid % 2) == 0){
/* send to left */
      MPI_Send(&sendl,1,MPI_FLOAT,left,10, MPI_COMM_WORLD);
/* rec from left */
      MPI_Recv(&recvl,1,MPI_FLOAT,left,10,MPI_COMM_WORLD,&status);
/* rec from right */
      MPI_Recv(&recvr,1,MPI_FLOAT,right,10,MPI_COMM_WORLD,&status);
/* send to right */
      MPI_Send(&sendr,1,MPI_FLOAT,right,10, MPI_COMM_WORLD);
    }
  else{
/* rec from right */
      MPI_Recv(&recvr,1,MPI_FLOAT,right,10,MPI_COMM_WORLD,&status);
/* send to right */
      MPI_Send(&sendr,1,MPI_FLOAT,right,10,MPI_COMM_WORLD);
/* send to left */
      MPI_Send(&sendl,1,MPI_FLOAT,left,10,MPI_COMM_WORLD);
/* rec from left */
      MPI_Recv(&recvl,1,MPI_FLOAT,left,10,MPI_COMM_WORLD,&status);
    }

/* do some calculation */
  newval=value-(recvl+recvr)/2;
  dv=value-newval;
  value=newval;  
/* and a reduction to see what's happening */
  MPI_Allreduce(&dv, &gres, 1,MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD);
  printf("%d %d %g %g\n",myid,iter,gres,value);
}
/*  Stop MPI */  
  int ierr=MPI_Finalize();
  return(ierr);
}
