#!/bin/bash -e
#SBATCH --job-name="array_job"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
##SBATCH -o outz-%j
###### Sending output to /dev/null will surpress it.
###### This is a good idea for array jobs lest it
###### create extra output for each subjob.
###### However for testing the next line should be removed.
#SBATCH -o /dev/null
#SBATCH --share
#SBATCH --export=ALL
#SBATCH --partition=shas

#SBATCH --mem=1000

#----------------------
# example invocation
# sbatch --array=1-24 run_matlab



module purge
module load matlab/R2017b
export _OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK


# go to our starting directory
cd $SLURM_SUBMIT_DIR

# get the JOB and SUBJOB ID
if [[ $SLURM_ARRAY_JOB_ID ]] ; then
	export JOB_ID=$SLURM_ARRAY_JOB_ID
	export SUB_ID=$SLURM_ARRAY_TASK_ID
else
	export JOB_ID=$SLURM_JOB_ID
	export SUB_ID=1
fi

# make a top level directory for the job 
# if it does not already exist
mkdir -p $JOB_ID
cd $JOB_ID


# make a directory for the subjob and go there
mkdir -p $SUB_ID
cd $SUB_ID
# Make a copy of our script
cat $0 > myscript
printenv > env

# set our seed to the $SLURM_JOB_ID
# this will be unique for each run
export MYSEED=$SLURM_JOB_ID

# copy our "stuff" to here
cp $SLURM_SUBMIT_DIR/bunch.m .


# Run our job
#	$SLURM_SUBMIT_DIR/tymer timer start_time
	matlab -r bunch > bunch.out
	hostname > node
#	$SLURM_SUBMIT_DIR/tymer timer end_time
