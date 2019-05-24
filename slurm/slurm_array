#!/bin/bash -e
### sample invocation
###   make dat
###   sbatch --array=1-16 slurm_array


#SBATCH --job-name="array_job"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=48:00:00
##SBATCH -o outz-%j
#SBATCH -o /dev/null
##SBATCH -e errz-%j
##SBATCH --exclusive
#SBATCH --share
#SBATCH --export=ALL

#SBATCH --mem=1000


#supress warning message for some versions of MPI
export LD_LIBRARY_PATH=/opt/lib/extras:$LD_LIBRARY_PATH

cd $SLURM_SUBMIT_DIR

if [[ $SLURM_ARRAY_JOB_ID ]] ; then
	JOB_ID=$SLURM_ARRAY_JOB_ID
	SUB_ID=$SLURM_ARRAY_TASK_ID
else
	JOB_ID=$SLURM_JOB_ID
	SUB_ID=1
fi

#The following line creates a file that contains a parameter space, a set of integers on each line.
#This should be run before the script.
#rm -rf pars ; for a in `seq 0 2 10` ; do for b in `seq 1 5` ; do for c in `seq 5 5 55` ; do echo $a $b $c >> pars; done; done; done

if [ -e pars ] ; then
export ARGS=`head -n $SUB_ID pars | tail -1`
else
export ARGS=`date`
fi

#The following line creates a file that contains a parameter space, a set of integers on each line.
#This should be run before the script.
#rm -rf list ; for a in `seq -w 1 1 32` ; do echo dir_$a >> list ;done

if [ -e list ] ; then
export dir=`head -n $SUB_ID list | tail -1`
else
export dir=mysub_$SUB_ID
fi


#Make our directory for our subrun and go there
mkdir -p $dir
cd $dir

srun -n 1 $SLURM_SUBMIT_DIR/p_array $ARGS > out.dat





