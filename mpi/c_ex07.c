#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

/*
! This program shows how to use MPI_Alltoall.  Each processor
! send/rec a different  random number to/from other processors.  
*/
/* globals */
int numnodes,myid,mpi_err;
#define mpi_root 0
/* end module  */

void init_it(int  *argc, char ***argv);
void seed_random(int  id);
void random_number(float *z);

void init_it(int  *argc, char ***argv) {
	mpi_err = MPI_Init(argc,argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
}

int main(int argc,char *argv[]){
	int *sray,*rray;
	int *sdisp,*sc,*rdisp,*rc;
	int ssize,rsize,i,k,j;
	float z;

	init_it(&argc,&argv);
	sc=(int*)malloc(sizeof(int)*numnodes);
	rc=(int*)malloc(sizeof(int)*numnodes);
	sdisp=(int*)malloc(sizeof(int)*numnodes);
	rdisp=(int*)malloc(sizeof(int)*numnodes);
/*
! seed the random number generator with a
! different number on each processor
*/
	seed_random(myid+99);
/* find  data to send */
	for(i=0;i<numnodes;i++){
		random_number(&z);
		sc[i]=(int)(10.0*z)+1;
	}
	printf("myid= %3.3d sc=",myid);
	for(i=0;i<numnodes;i++)
		printf("%3d ",sc[i]);
	printf("\n");
/* send the data */
	mpi_err = MPI_Alltoall(	sc,1,MPI_INT,
						    rc,1,MPI_INT,
	                 	    MPI_COMM_WORLD);
	printf("myid= %3.3d rc=",myid);
	for(i=0;i<numnodes;i++)
		printf("%3d ",rc[i]);
	printf("\n");
    mpi_err = MPI_Finalize();
}

void seed_random(int  id){
	srand((unsigned int)id);
}
void random_number(float *z){
	int i;
	i=rand();
	*z=(float)i/RAND_MAX;
}
