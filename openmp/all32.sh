#!/bin/bash
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --partition=lg
#SBATCH --account=hpcapps
#SBATCH --time=01:00:00
#SBATCH --exclusive
#SBATCH --cpus-per-task=32
##SBATCH --output=/tmp/timsstuff


export I_MPI_FABRICS=shm:ofi
export OMP_PROC_BIND=spread
export OMP_NUM_THREADS=32
#export OMP_PLACES=threads
#export OMP_PLACES={`seq -s, 0 31`}
echo $OMP_PLACES
cat $0 > script.$SLURM_JOBID
printenv > env.$SLURM_JOBID

#rm -rf stf_ii stf_ig
#ifort  -O3 -fopenmp StomOmpf_00d.f90 -o ./stf_ii
#gfortran -O3 -fopenmp StomOmpf_00d.f90 -o ./stf_ig
ml gcc
ml intel-oneapi-mpi
ml intel-oneapi-compilers

export n1=`scontrol show hostnames | tail -1`
export n0=`scontrol show hostnames | head -1`
touch waiting
rm wait.out
#srun --nodelist=$n0 --nodes=1-1  -n 1 domonitor $SLURM_JOB_ID > wait.out &

#Intel
rm *mod
unset OMP_PLACES
echo intel srun
printenv | grep OMP
srun --cpu-bind=none --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ii < st.in
echo intel raw
printenv | grep OMP
./stf_ii < st.in

export OMP_PLACES=threads
echo intel srun
printenv | grep OMP
srun --cpu-bind=none --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ii < st.in
echo intel raw
printenv | grep OMP
./stf_ii < st.in

export OMP_PLACES={`seq -s, 0 31`}
echo intel srun
printenv | grep OMP
srun --cpu-bind=none --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ii < st.in
echo intel raw
printenv | grep OMP
./stf_ii < st.in

#gfortran
unset OMP_PLACES
echo gfortran srun
printenv | grep OMP
srun --cpu-bind=none --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ig < st.in
echo gfortran raw
printenv | grep OMP
./stf_ig < st.in

export OMP_PLACES=threads
echo gfortran srun
printenv | grep OMP
srun --cpu-bind=none --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ig < st.in
echo gfortran raw
printenv | grep OMP
./stf_ig < st.in
export OMP_PLACES={`seq -s, 0 31`}

echo gfortran srun
printenv | grep OMP
srun --cpu-bind=none --nodelist=$n1 --nodes=1-1 -n 1 ./stf_ig < st.in
echo gfortran raw
printenv | grep OMP
./stf_ig < st.in


rm waiting
wait

#od /tmp/timsstuff | grep "000000 000000 000000 000000 000000 000000" > timsod.$SLURM_JOBID
#cp /tmp/out.$SLURM_JOBID .
#cp /tmp/timsstuff .timsstuff.$SLURM_JOBID
rm waiting
wait

