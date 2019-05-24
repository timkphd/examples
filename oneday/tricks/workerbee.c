#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
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
	int *will_use;
	MPI_Comm WORKER_WORLD;
	MPI_Group new_group,old_group;
	int ijk,num_used,used_id;
	int mannum;
	init_it(&argc,&argv);
	printf("hello from %d\n",myid);
/* num_used is the # of processors that are part of the new communicator */
/* for this case hardwire to not include 1 processor */
	num_used=numnodes-1;
/* get our old group from MPI_COMM_WORLD */
	mpi_err = MPI_Comm_group(MPI_COMM_WORLD,&old_group);
/* create a new group from the old group that */
/* will contain a subset of the  processors   */
	will_use=(int*)malloc(num_used*sizeof(int));
	for (ijk=0;ijk <= num_used-1;ijk++){
		will_use[ijk]=ijk;
	}
	mpi_err =  MPI_Group_incl(old_group,num_used,will_use,&new_group);
/* create the new communicator */
	mpi_err =  MPI_Comm_create(MPI_COMM_WORLD,new_group,&WORKER_WORLD);
/* test to see if I am part of new_group. */
	mpi_err =  MPI_Group_rank(new_group,&used_id);
	if(used_id == MPI_UNDEFINED){
/* if not part of the new group do management. */
		manager(num_used);
		printf("manager finished\n");
		mpi_err =  MPI_Barrier(MPI_COMM_WORLD);
		mpi_err =  MPI_Finalize();
		exit(0);
	}
	else {
/* part of the new group do work. */
		mannum=numnodes-1;
		worker(WORKER_WORLD,mannum);
		printf("worker finished\n");
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

#define TODO 100
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
	for (i=0;i<num_used;i++){
		x=-1000.0;
		mpi_err = MPI_Send((void*)&x,1, MPI_FLOAT,i,2345,MPI_COMM_WORLD);
	}	
}
