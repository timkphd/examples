#!/bin/bash
#SBATCH --job-name="ior"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=01:00:00
#SBATCH --partition=sm
##SBATCH --output=system_build
##SBATCH --error=system_build
 
module purge
export MODULEPATH=/nopt/nrel/apps/220525b/level01/modules/lmod/linux-rocky8-x86_64/gcc/12.1.0
#openmpi hdf5 version
module load openmpi
module use /nopt/nrel/apps/220525b/level03b/modules/lmod/linux-rocky8-x86_64/openmpi/4.1.3-bk6rlyg/gcc/12.1.0
module load ior
srun --mpi=pmi2 -n 2 ior > openmpi_hdf4_ior
 
# clean up modules 
module unload ior
module unload openmpi
module unuse /nopt/nrel/apps/220525b/level03b/modules/lmod/linux-rocky8-x86_64/openmpi/4.1.3-bk6rlyg/gcc/12.1.0
 
#intelmpi hdf5 version
module use /nopt/nrel/apps/220525b/level03b/modules/lmod/linux-rocky8-x86_64/intel-oneapi-mpi/2021.6.0-ghyk7n2/gcc/12.1.0
module load intel-oneapi-mpi
#export LD_LIBRARY_PATH=/nopt/nrel/apps/compilers/intel/2020.1.217/impi/2019.7.217/intel64/libfabric/lib:$LD_LIBRARY_PATH
module load ior
 
srun --mpi=pmi2 -n 2 ior > intel_hdf4_ior
 
# clean up modules 
module unload ior
module unload intel-oneapi-mpi
module unuse /nopt/nrel/apps/220525b/level03b/modules/lmod/linux-rocky8-x86_64/intel-oneapi-mpi/2021.6.0-ghyk7n2/gcc/12.1.0
