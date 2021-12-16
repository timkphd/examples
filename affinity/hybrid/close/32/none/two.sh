#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=2
#SBATCH --partition=test
#SBATCH --account=hpcapps
#SBATCH --time=01:00:00
#SBATCH --exclusive
#SBATCH --cpus-per-task=2

export I_MPI_FABRICS=shm:ofi
export OMP_PROC_BIND=close
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
cat $0 > script.$SLURM_JOBID
printenv > env.$SLURM_JOBID

export n1=`scontrol show hostnames | tail -1`
export n0=`scontrol show hostnames | head -1`
export WD=`pwd`
touch waiting
rm wait.out
srun --nodelist=$n0 --nodes=1-1  -n 1 domonitor $SLURM_JOB_ID > wait.out &


rm -rf stf_ii stf_ig stf_og stf_oi
ml gcc
ml intel-oneapi-mpi
ml intel-oneapi-compilers

#Intel MPI Intel compiler
mpiifort  -O3 -fopenmp StomOmpf_02d.f90 -o ./stf_ii
srun --nodelist=$n1 --nodes=1-1     -n 32  ./stf_ii < st.in

#Intel MPI gfortran
mpif90  -O3 -fopenmp StomOmpf_02d.f90 -o ./stf_ig
srun --nodelist=$n1 --nodes=1-1     -n 32  ./stf_ig < st.in

#OpenMPI gfortran
module unload  intel-oneapi-mpi
ml openmpi
export OMPI_FC=gfortran
mpifort -O3 -fopenmp StomOmpf_02d.f90 -o ./stf_og
srun --nodelist=$n1 --nodes=1-1    -n 32  ./stf_og < st.in

#OpenMPI Intel compiler
export OMPI_FC=ifort
mpifort -O3 -fopenmp StomOmpf_02d.f90 -o ./stf_oi
srun --nodelist=$n1 --nodes=1-1    -n 32  ./stf_oi < st.in

rm *mod

rm waiting

wait

