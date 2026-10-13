#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc,char *argv[]){
int sendbuf[4],recvbuf[4];
int powers[6];
int i,numnodes,myid;

MPI_Init(&argc,&argv);
MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
MPI_Comm_rank(MPI_COMM_WORLD, &myid);

powers[0]=0;    powers[1]=10;    powers[2]=100;
powers[3]=1000; powers[4]=10000; powers[5]=100000;

for (i=0; i<4;i++) {
	sendbuf[i]=i+powers[myid];
} 

printf("sendbuf for %2d     ",myid);
for (i=0; i<4;i++)
   printf("%8d",sendbuf[i]);
printf("\n");

MPI_Allreduce(sendbuf, recvbuf, 4, MPI_INT, MPI_SUM,MPI_COMM_WORLD);

printf("recvbuf for %2d     ",myid);
for (i=0; i<4;i++)
   printf("%8d",recvbuf[i]);
printf("\n");
MPI_Finalize();
}

