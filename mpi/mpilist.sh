#!/bin/bash
#SBATCH --job-name="hello"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=00:20:00
#SBATCH --partition=shared
#SBATCH --account=hpcapps
cat << HERE > testc.c
#include <stdio.h>
#include <mpi.h>
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
int main(int argc, char **argv)
{
    int myid,numprocs,resultlen;
    char version[MPI_MAX_LIBRARY_VERSION_STRING];
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    int vlan;
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
    printf("Hello from %s %d %d\n",myname,myid,numprocs);
    if (myid == 0 ) {
	    MPI_Get_library_version(version, &vlan);
	    printf("%s\n",version);
    }
    MPI_Finalize();
}
HERE


module use /nopt/nrel/apps/pythons/041323_b/tcl/linux-rhel8-icelake
source /nopt/nrel/apps/env.sh
module load gcc
export OMPI_MCA_opal_cuda_support=0

for c in "intel-oneapi-compilers/2021.8.0-intel" "cray-mpich/8.1.20" intel-oneapi-mpi-2021.9.0-gcc-12.1.0-ps7cg34 "mpich/4.1-gcc" "openmpi/4.1.4-gcc" "intel-oneapi-mpi/2021.8.0-intel" "intel-oneapi-compilers/2021.8.0-intel" ; do
  echo loading: $c
  module load $c
  echo "I_MPI_PMI_LIBRARY=" $I_MPI_PMI_LIBRARY
  module list
  which mpicc
  mpicc testc.c
  srun -n 2 ./a.out | sort
  module unload $c
  printf "\n\n"
done


printf "\n\n\n"
module load intel-oneapi-compilers/2021.8.0-intel
echo "###### prepend /opt/cray/libfabric/1.15.2.0/lib64 to LD_LIBRARY_PATH"
echo
export LD_LIBRARY_PATH=/opt/cray/libfabric/1.15.2.0/lib64:$LD_LIBRARY_PATH
srun -n 2 ./a.out
module unload intel-oneapi-compilers/2021.8.0-intel




