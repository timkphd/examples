#!/bin/bash -e
#SBATCH --job-name="array_job"
#SBATCH --nodes=1
##SBATCH --ntasks-per-node=12
##SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=2
#SBATCH --time=00:05:00
###### sending output to /dev/null will suppress it
###### this is a good idea for array jobs lest it
###### create extra output for each subjob
##SBATCH -o /dev/null
#SBATCH --exclusive=user
#SBATCH --export=ALL
##SBATCH --partition=shas
#SBATCH --account=hpcapps

#SBATCH --mem=50000

#----------------------
# example invocation
# sbatch --array=1-24 array_simple



module purge
module load   gcc/7.3.0   comp-intel/2018.0.3 intel-mpi/2018.0.3 mkl/2018.3.222

#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=1
export OMP_NUM_THREADS=2


#run with either the C or python version of our program
export EXE=invertp.py
#export EXE=invertc
#export EXE="phostone"


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



# Get the name of our LIST, default to list
if [ -z ${LIST+x} ]; then echo "LIST is unset"; export LIST=list ; else echo "LIST is set to '$LIST'"; fi


# Here we assume that our LIST is is a set of directories
# under a "main" directory "inputs" each containing data sets.  
# For our current program we require each directory contain an 
# input file myinput.
#
#
# We get the directory from the list
	dir=`head -n $SUB_ID $SLURM_SUBMIT_DIR/$LIST | tail -1`
# Copy our input from the directory
	cp -r $SLURM_SUBMIT_DIR/inputs/$dir/* .
	printenv > envs

# Run our job
	$SLURM_SUBMIT_DIR/tymer timer start_time
	$SLURM_SUBMIT_DIR/$EXE `cat myinput` > output
	hostname > node
	echo $SLURM_SUBMIT_DIR/inputs/$dir > directory
	$SLURM_SUBMIT_DIR/tymer timer end_time

