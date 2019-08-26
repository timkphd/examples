#!/bin/bash 
#SBATCH --job-name="invert"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
##SBATCH --ntasks=16
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=01:00:00

#export  "OMP_NUM_THREADS=12 "
export OMP_NUM_THREADS=1
module purge
module load matlab/R2017b
#module load gcc/8.2.0  This version of gcc is not supported by this version of matlab

# Go to the directoy from which our job was launched
cd $SLURM_SUBMIT_DIR


# We run the job in a new directory so we make it, go there, and copy files
mkdir $SLURM_JOBID
cd $SLURM_JOBID
cp ../hpc*m .
cp ../do_invert .
cp ../randRA.cpp .

# Compile our cpp routine
mex randRA.cpp

# Save a copy of our environment and script
cat $0 > script.$SLURM_JOBID
printenv  > env.$SLURM_JOBID

# Run the job with an external timer with values going in file "clock"
$SLURM_SUBMIT_DIR/tymer clock "starting the job"

./do_invert > $SLURM_JOB_ID.out

$SLURM_SUBMIT_DIR/tymer clock "job has finished"


# Copy output to this directory
cp ../slurm-$SLURM_JOB_ID* .

