#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
int main(int argc, char **argv){
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    int mpi_err,np,myid,nlength;
    mpi_err = MPI_Init(&argc,&argv);
    mpi_err = MPI_Comm_size( MPI_COMM_WORLD, &np );
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
    MPI_Get_processor_name(myname,&nlength);
    printf("%4d of %4d on %s running %s\n",myid,np,myname,argv[0]);
    mpi_err = MPI_Finalize();
}

