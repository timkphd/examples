#!/bin/bash
#SBATCH --job-name="quickStart"
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=4
#SBATCH --ntasks=8
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=00:10:00

module purge
module load python/3.6.5 intel impi R/3.5.0 


#Regular output goes to a file slurm-xxxxxx.out 
# where xxxxxx is the job number

ls

# Go to the directoy from which our job was launched
cd $SLURM_SUBMIT_DIR

# Run a MPI application in parallel on 2 nodes
echo "**** running our parallel Fortran example"
mpirun -n 8 ./hellof > hellof.out

# Run a MPI application in parallel on 2 nodes
echo "**** running our parallel C example"
mpirun -n 8 ./helloc > helloc.out

# Run a hybrid MPI/OpenMP application in parallel on 2 nodes
echo "**** running our hybrid MPI/OpenMP C example"
export OMP_NUM_THREADS=2
mpirun -n 8 ./phostone -F > phostone.out

# Run an OpenMP application on 1 node
echo "**** running our OpenMP Fortran example"
export OMP_NUM_THREADS=4
./invertf > invertf.out

# Run an OpenMP application on 1 node
echo "**** running our OpenMP C example"
export OMP_NUM_THREADS=4
./invertc > invertc.out

# Run our R matrix inversion program, we let output got to our
# default output file slurm-xxxxxx.out
# We are using our tymer routine instead of echo because it
# time stamps output.  See the web page for details.
./tymer timefile "**** running our R example"
Rscript invert.R

# update timer
./tymer timefile "end R"

# Run our python matrix inversion program, we let output got to our
# default output file slurm-xxxxxx.out
./tymer timefile "**** running our python example"
python3 invert.py

# update timer
./tymer timefile "end python"
