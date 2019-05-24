/*
! return a integer which is unique to all mpi
! tasks running on a particular node.  It is
! equal to the id of the first MPI task running
! on a node.  This can be used to create 
! MPI communicators which only contain tasks on
! a node.

*/
#include <mpi.h>
#include <string.h>
int node_color() {
int mycol;
MPI_Status status;
int xchng,i,n2,myid,numprocs;
int ierr,nlen;
int ie;
char *pch;
char name[MPI_MAX_PROCESSOR_NAME+1];
char nlist[MPI_MAX_PROCESSOR_NAME+1];
MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
MPI_Comm_rank(MPI_COMM_WORLD,&myid);
MPI_Get_processor_name(name,&nlen); 
pch=strrchr(name,' ');
if(pch) {
	ie=strlen(pch+1);
	memmove(&name[0],pch+1,ie+1);
	memmove(&nlist[0],pch+1,ie+1);
}
else {
	strcpy(nlist,name);
}
mycol=myid;
n2=1;
while (n2 < numprocs) {
	n2=n2*2;
}
    for(i=1;i<=n2-1;i++) {
		xchng=i^myid;
		if(xchng <= (numprocs-1)) {
			if(myid < xchng) {
				ierr=MPI_Send(name,MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345, MPI_COMM_WORLD);
				ierr=MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME,MPI_CHAR,xchng,12345, MPI_COMM_WORLD, &status);
			}
			else {
				ierr=MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME,MPI_CHAR,xchng,12345, MPI_COMM_WORLD, &status);
				ierr=MPI_Send(name,MPI_MAX_PROCESSOR_NAME, MPI_CHAR, xchng, 12345, MPI_COMM_WORLD);			
			}
			if (strcmp(nlist,name) == 0 && xchng < mycol)mycol=xchng;
		}
		else {
		/* skip this stage */
		}
    }
return mycol;
}

