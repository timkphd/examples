/*
Shows a short cut method to create a collection of communicators.
All processors with the "same color" will be in the same communicator.
In this case the color is either 0 or 1 for even or odd processors.
Index gives rank in new communicator.
*/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int main(int argc, char **argv ,char **envp)

{
    int myid, numprocs;
    int color,Zero_one,new_id,new_nodes;
    MPI_Comm split_comm; 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	color=myid % 2;
	MPI_Comm_split(MPI_COMM_WORLD,color,myid,&split_comm);
	MPI_Comm_rank( split_comm, &new_id);
	MPI_Comm_size( split_comm, &new_nodes);
	Zero_one = -1;
	if(new_id==0){
	printf("split_comm %3d  has %3d  tasks\n",color,new_nodes);
	}
	MPI_Barrier(MPI_COMM_WORLD);
	Zero_one = color;
	MPI_Bcast(&Zero_one,1,MPI_INT,0, split_comm);
	if(Zero_one==0)printf("old %3d is part of even processor communicator %3d\n",myid,new_id);
	if(Zero_one==1)printf("old %3d is part of  odd processor communicator %3d\n",myid,new_id);
	MPI_Barrier(MPI_COMM_WORLD);
	printf("old_id= %3d new_id= %3d color=%1d\n", myid, new_id,Zero_one);
    MPI_Finalize();
}

