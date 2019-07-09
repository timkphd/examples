#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=12:00:00
##SBATCH --qos=testing
#SBATCH --output=sample-%j.out

export DYLD_LIBRARY_PATH=/opt/intel/mkl/lib:/opt/intel/lib

export EXE=$1

if [ -n "$2" ]; then export OMP_NUM_THREADS=$2 ; fi

# Go to starting directory
MY_SUBMIT_DIR=`pwd`
cd $MY_SUBMIT_DIR

# Get short version of our jobid
export MY_JOB_ID=`date +"%g%m%d%H%M"`
JOBID=`echo $MY_JOB_ID`


# Make a directory for this run and go there
mkdir $JOBID
cd $JOBID

# Copy our input data and our script
cp $MY_SUBMIT_DIR/makefile .
cp $MY_SUBMIT_DIR/*f90 .
cp $MY_SUBMIT_DIR/*c .
cat $MY_SUBMIT_DIR/$0 > script.$JOBID

make $EXE

# Get a list of our nodes
echo hostname > nodes

# save our environment
echo "RUNNING $EXE" > environment
printenv >> environment


# Do the runs

make $EXE
for n in 500 1000 1500 2000 2500 3000 ; do
	echo $n > input
# Start Tim's timer
	$MY_SUBMIT_DIR/tymer times "start of run $n"
	./$EXE < input > out.$n
# Stop Tim's timer
	$MY_SUBMIT_DIR/tymer times "end of run $n"
done
	

