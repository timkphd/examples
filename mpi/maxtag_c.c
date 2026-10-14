#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
#include <stdbool.h>

#define getuniverse true
/************************************************************
This is a simple send/receive program in MPI to which was
added a call to find the maxtag.
************************************************************/
/*
PMPI_Send(97).: Invalid tag, value is 1196597
In: PMI_Abort(537515524, Fatal error in PMPI_Send: Invalid tag, error stack:
PMPI_Send(159): MPI_Send(buf=0x63ec7e0, count=60, MPI_INTEGER, dest=597, tag=1196597, MPI_COMM_WORLD) failed
PMPI_Send(97).: Invalid tag, value is 1196597)
*/

int main(int argc, char **argv ,char **envp)
{
    int myid, numprocs;
    int tag,source,destination,count;
    int buffer;
    MPI_Status status;
    int *maxtag;
    int flag;
    int ierr;
    int *val;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    
          if (getuniverse){
		  ierr=MPI_Comm_get_attr(MPI_COMM_WORLD, MPI_UNIVERSE_SIZE, &val, &flag);
		  // val should be equal to numprocs or more and no error
		  if (ierr != 0 || (val == 0 && myid == 0)) {
			printf("Somthing wrong with call to MPI_COMM_GET_ATTR with\n");
			printf("             MPI_UNIVERSE_SIZE\n");
			printf("It might need to be set outside of this program\n");
			printf("For example:\n");    
			printf("mpirun -usize 6 -n 4 ./maxtag_f\n");  
		  } 
		  if(myid == 0){
		      ierr=MPI_Comm_get_attr(MPI_COMM_WORLD, MPI_UNIVERSE_SIZE,   &val, &flag);
		      printf("MPI_UNIVERSE_SIZE returned    %14d flag %4d ierr %4d\n",*val, flag, ierr);
		      ierr=MPI_Comm_get_attr(MPI_COMM_WORLD, MPI_WTIME_IS_GLOBAL, &val, &flag);
		      printf("MPI_WTIME_IS_GLOBAL returned %14d flag %4d ierr %4d\n",*val, flag, ierr);
		      printf("Timer resolution: %14.8f\n",MPI_Wtick());
		  }
		  }



    ierr=MPI_Comm_get_attr(MPI_COMM_WORLD, MPI_TAG_UB, &maxtag, &flag);
    if(myid == 0)printf("maxtag %14d flag %4d ierr %4d\n",*maxtag,flag,ierr);
    tag=1422709;
    if (tag > *maxtag ) {
      printf("warning maxtag is %d tag is %d\n",*maxtag,tag);
    }

    source=0;
    destination=1;
    count=1;
    if(myid == source){
      buffer=5678;
      MPI_Send(&buffer,count,MPI_INT,destination,tag,MPI_COMM_WORLD);
      printf("processor %d  sent %d\n",myid,buffer);
    }
    if(myid == destination){
        MPI_Recv(&buffer,count,MPI_INT,source,tag,MPI_COMM_WORLD,&status);
        printf("processor %d   got %d\n",myid,buffer);
    }
    MPI_Finalize();
}
