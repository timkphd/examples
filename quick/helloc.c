#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <mpi.h>
#include <math.h>
void NODE_COLOR(); 
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
int main(int argc, char **argv,char *envp[])
{
    int myid,numprocs,resultlen;
    int mycolor,new_id,new_nodes;
    int i,k;
    MPI_Comm node_comm;
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
/*********/
    NODE_COLOR(&mycolor);
    MPI_Comm_split(MPI_COMM_WORLD,mycolor,myid,&node_comm);
    MPI_Comm_rank( node_comm, &new_id );
    MPI_Comm_size( node_comm, &new_nodes);

    printf("everyone %s %d %d %d\n",myname,myid,numprocs,mycolor);
    for (i=0;i<numprocs;i++) {
	MPI_Barrier(MPI_COMM_WORLD);
	if(new_id < 1 && i == myid){
        if(rindex(myname, 32))
		printf("\n*********************  Hello from %s %d %d %d\n",rindex(myname, 32),myid,numprocs,mycolor);
	else
		printf("\n*********************  Hello from %s %d %d %d\n",myname,myid,numprocs,mycolor);
#ifdef DO_ENV
		k=0;
		while(envp[k]) {
			printf("%s\n",envp[k]);
			k++;
		}
#endif
	}
    }
    MPI_Finalize();
}

