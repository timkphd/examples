#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <stdbool.h>
/*
! Our example will show you how to create a new communicator
! called SUB_COMM_WORLD. This communicator will include all
! the tasks except the last one.
! 
! First, we call MPI_Comm_group with the input communicator,
! MPI_COMM_WORLD. This gives us the associated group,
! old_group. Next, we create an array called will_use that
! contains all the task IDs except the last one. We then pass
! this array and old_group to MPI_Group_incl to create a new
! group called new_group. Finally, we pass new_group and
! MPI_COMM_WORLD to MPI_Comm_create to get a new communicator
! called SUB_COMM_WORLD.
! 
! Then we use the MPI_Group_rank routine to find the rank
! within the new communicator. For the last task, the rank is
! MPI_UNDEFINED because it’s not part of the communicator. The
! last task calls the get_input routine to read data from a
! file, an integer. This integer is then sent to task 0 using
! MPI_COMM_WORLD. If the value is greater than 100, the
! program stops.
! 
! The tasks in SUB_COMM_WORLD pass a token between themselves
! using the pass_token routine. The token starts at task 0.
! Task 0 receives the token from the last task using
! MPI_COMM_WORLD, as mentioned earlier. All other tasks only
! use SUB_COMM_WORLD.
*/



/* global variables */
int numnodes,myid,mpi_err,old_id,old_nodes,ierror;
#define mpi_root 0
#define verbose false
/* end of global variables  */

void pass_token(MPI_Comm THE_COMM_WORLD);
void init_it(int  *argc, char ***argv);
void get_input();

void init_it(int  *argc, char ***argv) {
	mpi_err = MPI_Init(argc,argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &old_nodes );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &old_id);
}

int main(int argc,char *argv[]){
/* poe a.out -procs 3 -rmpool 1 */
	int *will_use;
	MPI_Comm SUB_COMM_WORLD;
	MPI_Group new_group,old_group;
	int ijk,num_used,used_id;
	init_it(&argc,&argv);
	printf("hello from %4d\n",old_id);
	
	
/* num_used is the # of processors that are part of the new communicator */
/* for this case hardwire to not include 1 processor */
    num_used=old_nodes-1;
    if(old_nodes > num_used){
/* get our old group from MPI_COMM_WORLD */
        mpi_err = MPI_Comm_group(MPI_COMM_WORLD,&old_group);
/* create a new group from the old group */
/* that will contain a subset of the  processors */
		will_use=(int*)malloc(num_used*sizeof(int));
		for (ijk=0;ijk <= num_used-1;ijk++){
			will_use[ijk]=ijk;
		}
        mpi_err =  MPI_Group_incl(old_group,num_used,will_use,&new_group);
/* create the new communicator */
        mpi_err =  MPI_Comm_create(MPI_COMM_WORLD,new_group,&SUB_COMM_WORLD);
/* test to see if I am part of new_group. */
        mpi_err =  MPI_Group_rank(new_group,&used_id);
        if(used_id == MPI_UNDEFINED){
/* if not part of the new group do keyboard i/o. */
			get_input();
			mpi_err =  MPI_Barrier(MPI_COMM_WORLD);
			mpi_err =  MPI_Finalize();
 			exit(0);
        }
    }
    else {
        printf("need to set aside 1 task for input\n");
       mpi_err = MPI_Abort(MPI_COMM_WORLD, ierror);
    }
    mpi_err = MPI_Comm_rank( SUB_COMM_WORLD, &myid );
    mpi_err = MPI_Comm_size( SUB_COMM_WORLD, &numnodes );
    if(myid == 0) {
		printf("MPI_COMM_WORLD task %4d of %4d\n",old_id,old_nodes);
		printf("SUB_COMM_WORLD task %4d of %4d\n",myid,numnodes);
	}

    pass_token(SUB_COMM_WORLD);
    printf("back from pass_token %4d\n",old_id);
    mpi_err = MPI_Barrier(MPI_COMM_WORLD);
    mpi_err = MPI_Finalize();
    exit(0);
}



void get_input(){
   int to,my_tag,i;
   FILE *IN;
   to=0;
   my_tag=0;
   i=0;
   IN=fopen("ex10.in","r");
   while(i < 100) {
   		printf("waiting for input:\n");
   		fscanf(IN,"%d",&i);
   		printf("read i %3d\n",i);
   		mpi_err = MPI_Send((void*)&i,1, MPI_INT,to,my_tag,MPI_COMM_WORLD);
   }
}



void pass_token(MPI_Comm THE_COMM_WORLD) {
	int my_tag,j,i,to,from,ierr;
	MPI_Status status;
	int flag;
    my_tag=1234;
    j=0;
    flag=1;
    to=myid+1;
    if(to == numnodes)to=0;
    from=myid-1;
    if(from < 0)from=numnodes-1;
    i=0;
	while(i < 100) {
		if(myid == j){
			ierr = MPI_Iprobe(MPI_ANY_SOURCE,MPI_ANY_TAG,
	    	                  MPI_COMM_WORLD,&flag,&status);
	    	if(flag){
	    		ierr = MPI_Recv((void*)&i,1,MPI_INT,MPI_ANY_SOURCE,MPI_ANY_TAG,
	    		                MPI_COMM_WORLD,&status);
	    	    printf("got i %d\n",i);
	    	}
	    	if(verbose)printf("%d sending %d to %d\n",myid,i,to);
	    	ierr = MPI_Send((void*)&i,1, MPI_INT,to,my_tag,THE_COMM_WORLD);
	    	j=-1;
	    }
	    else {
	    	ierr = MPI_Recv((void*)&i,1,MPI_INT,from,my_tag,THE_COMM_WORLD,&status);
	    	j=myid;
	    }
    }
    if(myid < numnodes-1) {
        if(verbose)printf("%d sending %d to %d\n",myid,i,to);
    	ierr = MPI_Send((void*)&i,1, MPI_INT,to,my_tag,THE_COMM_WORLD);
    	}
}
    
