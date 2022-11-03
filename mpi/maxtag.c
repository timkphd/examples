#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
/************************************************************
This is a simple send/receive program in MPI
************************************************************/
/*
PMPI_Send(97).: Invalid tag, value is 1196597
In: PMI_Abort(537515524, Fatal error in PMPI_Send: Invalid tag, error stack:
PMPI_Send(159): MPI_Send(buf=0x63ec7e0, count=60, MPI_INTEGER, dest=597, tag=1196597, MPI_COMM_WORLD) failed
PMPI_Send(97).: Invalid tag, value is 1196597)
*/

int main(argc,argv)
int argc;
char *argv[];
{
    int myid, numprocs;
    int tag,source,destination,count;
    int buffer;
    MPI_Status status;
    int *maxtag;
    int flag;
    int ierr;
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    ierr=MPI_Comm_get_attr(MPI_COMM_WORLD, MPI_TAG_UB, &maxtag, &flag);
    printf("%d %d %d\n",*maxtag,flag,ierr);
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
        printf("processor %d  got %d\n",myid,buffer);
    }
    MPI_Finalize();
}
