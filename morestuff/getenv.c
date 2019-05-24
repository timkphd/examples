#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
int main(int argc, char **argv, char **env)
{
    int myid, numprocs,mylen,i;
    char myname[MPI_MAX_PROCESSOR_NAME];
    char *astr;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&mylen);
    if(myid == numprocs-1){
/* the last process prints in name and environmental variables*/
      printf("Hello from %d of %d on %s\n",myid,numprocs,myname);
      i=0;
      astr=env[i];
      while(astr) {
	    printf("%s\n",astr);
	    i++;
	    astr=env[i];
      }
   } 
   MPI_Finalize();
}

