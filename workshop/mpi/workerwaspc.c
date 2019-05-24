#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <unistd.h>
/****
! This program is designed to show how to set up a new communicator
! and to do the a manager/worker paradigm
!
! We set up a communicator that includes all but one of the processors,
! The last processor is not part of the new communicator, WORKER_WORLD.
! We use the routine MPI_Group_rank to find the rank within the new
! communicator.  For the last processor the rank is MPI_UNDEFINED because
! it is not part of the communicator.  For this processor we call manager.
! The manager waits results from the workers and then sends more work for
! them to do.
!
! The processors in WORKER_WORLD are the workers.  They get an input
! from the manager and send back the result.   This continues until the
! manager gets back "TODO" results.  It then tells the workers to quit.
!
! Note that the workers communicate to the manager via MPI_COMM_WORLD.  
! They could communicate amongst themselves via WORKER_WORLD.  This
! would enable multiple workers to work in parallel.  You could also
! set up communicators that are subsets of WORKER_WORLD.
*****/

/* global variables */
int numnodes,myid,mpi_err;
#define mpi_root 0
/* end of global variables  */

void worker(MPI_Comm THE_COMM_WORLD,int manangerid);
void init_it(int  *argc, char ***argv);
void manager(int num_used);

void init_it(int  *argc, char ***argv) {
	mpi_err = MPI_Init(argc,argv);
	mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &numnodes );
	mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
}

int main(int argc,char *argv[]){
	MPI_Comm WORKER_WORLD;
	int group;
	int ijk,num_used,used_id;
	int mannum;
	int new_id,worker_size;
	init_it(&argc,&argv);
	printf("hello from %d\n",myid);
/* num_used is the # of processors that are part of the new communicator */
/* for this case hardwire to not include 1 processor */
	num_used=numnodes-1;
	mannum=0;
    if(myid == mannum) {
      group=0;
    }
    else {
      group=1;
    }
    MPI_Comm_split(MPI_COMM_WORLD,group,myid,&WORKER_WORLD);
    MPI_Comm_rank( WORKER_WORLD, &new_id);
    MPI_Comm_size( WORKER_WORLD, &worker_size);
    printf("%d %d %d\n",myid,new_id,worker_size);
    if(group == 0){

/* if not part of the new group do management. */
		manager(num_used);
		printf("manager finished\n");
		mpi_err =  MPI_Barrier(MPI_COMM_WORLD);
		mpi_err =  MPI_Finalize();
		exit(0);
	}
	else {
/* part of the new group do work. */
		mannum=0;
		worker(WORKER_WORLD,mannum);
		printf("worker finished %d %d\n",myid,new_id);
		mpi_err = MPI_Barrier(MPI_COMM_WORLD);
		mpi_err = MPI_Finalize();
		exit(0);
	}
}

void worker(MPI_Comm THE_COMM_WORLD,int managerid) {
	float x;
	MPI_Status status;
	x=0.0;
	while(x > -1.0) {
/* send message says I am ready for data */
		mpi_err= MPI_Send((void*)&x,1,MPI_FLOAT,managerid,1234,MPI_COMM_WORLD);
/* get a message from the manager */
		mpi_err= MPI_Recv((void*)&x,1,MPI_FLOAT,managerid,2345,MPI_COMM_WORLD,&status);
/* process data */
		x=x*2.0;
		sleep(myid+1);
	}
}

#define TODO 10
void manager(int num_used){
	int igot,isent,gotfrom,sendto,i;
	float inputs[TODO];
	float x;
	MPI_Status status;
	int flag;
	igot=0;   isent=0;
	for(i=0;i<TODO;i++) {
		inputs[i]=i+1;
	}
	while(igot < TODO) {
/* wait for a request for work */
		mpi_err = MPI_Iprobe(MPI_ANY_SOURCE,MPI_ANY_TAG,MPI_COMM_WORLD,&flag,&status);
		if(flag){
/* where is it comming from */
			gotfrom=status.MPI_SOURCE;
			sendto=gotfrom;
			mpi_err = MPI_Recv((void*)&x,1,MPI_FLOAT,gotfrom,1234,MPI_COMM_WORLD,&status);
			printf("worker %d sent %g\n",gotfrom,x);
			if(x > 0.0) { igot++; }
			if(isent < TODO){
/* send real data */
				x=inputs[isent];
				mpi_err = MPI_Send((void*)&x,1, MPI_FLOAT,sendto,2345,MPI_COMM_WORLD);
				isent++;
			}
		}
	}
/* tell everyone to quit */
	for (i=1;i<=num_used;i++){
		x=-1000.0;
		mpi_err = MPI_Send((void*)&x,1, MPI_FLOAT,i,2345,MPI_COMM_WORLD);
	}	
}
