#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=2
#SBATCH --partition=test:w
#SBATCH --account=hpcapps
#SBATCH --time=01:00:00
#SBATCH --exclusive
#SBATCH --cpus-per-task=128


export I_MPI_FABRICS=shm:ofi
export OMP_PROC_BIND=spread
export OMP_NUM_THREADS=128
cat $0 > script.$SLURM_JOBID
printenv > env.$SLURM_JOBID

rm -rf stf_ii stf_ig
ml gcc
ml intel-oneapi-mpi
ml intel-oneapi-compilers

export n1=`scontrol show hostnames | tail -1`
export n0=`scontrol show hostnames | head -1`
touch waiting
rm wait.out
srun --nodelist=$n0 --nodes=1-1  -n 1 domonitor $SLURM_JOB_ID > wait.out &

#Intel
ifort  -O3 -fopenmp StomOmpf_00d.f90 -o ./stf_ii
rm *mod
srun --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ii < st.in

#gfortran
gfortran -O3 -fopenmp StomOmpf_00d.f90 -o ./stf_ig
rm *mod
srun --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ig < st.in

rm waiting
wait

