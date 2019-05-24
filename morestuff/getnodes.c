

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
/* everyone just prints their name */
    printf("Hello from %d of %d on %s\n",myid,numprocs,myname);
    MPI_Finalize();
}