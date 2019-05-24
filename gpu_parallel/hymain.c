#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int cumain(int myid, int gx, int gy,int bx, int by, int bz);

 
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
int main(int argc, char **argv)
{
    int myid,numprocs,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME] ;
	int gx,gy;
	int bx,by,bz;

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
    printf("C-> Hello from %s # %d of %d\n",myname,myid,numprocs);
    if (myid == 0) {
		scanf("%d %d",&gx,&gy);
		scanf("%d %d %d",&bx,&by,&bz);
	}

	MPI_Bcast(&gx,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Bcast(&gy,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Bcast(&bx,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Bcast(&by,1,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Bcast(&bz,1,MPI_INT,0,MPI_COMM_WORLD);

    cumain(myid,gx,gy,bx,by,bz);
   
    MPI_Finalize();
}
