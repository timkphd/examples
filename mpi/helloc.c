#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
void pass(int myid,int numprocs); 
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
int main(int argc, char **argv)
{
    int myid,numprocs,resultlen;
    char version[MPI_MAX_LIBRARY_VERSION_STRING];
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    int vlan;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
    printf(" Hello from %s %d of %d\n",myname,myid,numprocs);
    if(numprocs > 1)pass(myid,numprocs);
    if (myid == 0 ) {
	    MPI_Get_library_version(version, &vlan);
	    printf("%s\n",version);
	    printf(" SUCCESS\n");
    }
    MPI_Finalize();
}
void pass(int myid,int numprocs) {
#include <mpi.h>
	MPI_Status status;
	int my_tag,to,from,i,ierr;
	my_tag=1234;
	i=myid;
	to=myid+1;
	from=myid-1;
	ierr=MPI_Bcast(&i,1,MPI_INT,0, MPI_COMM_WORLD);
	if( i != 0)printf("bcast failed %d\n",myid);
	if (myid == 0){
		from=numprocs-1;
		ierr=MPI_Send(&i,1,MPI_INT,to,my_tag,MPI_COMM_WORLD);
		ierr=MPI_Recv(&i,1,MPI_INT,from,my_tag,MPI_COMM_WORLD,&status);
	}
	else {
		if (myid == numprocs-1)to=0;
		ierr=MPI_Recv(&i,1,MPI_INT,from,my_tag,MPI_COMM_WORLD,&status);
		ierr=MPI_Send(&i,1,MPI_INT,to,my_tag,MPI_COMM_WORLD);
	}
}

