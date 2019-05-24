#!/bin/bash -e
#SBATCH --job-name="array_job"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --time=02:00
#SBATCH -o outz-%j
##SBATCH -e errz-%j
##SBATCH --exclusive
#SBATCH --share
#SBATCH --export=ALL

##SBATCH --mem=1000

#----------------------
# example invocation
# sbatch --array=0-19 array

cd $SLURM_SUBMIT_DIR

module purge
module load StdEnv
module load PrgEnv/python/gcc/2.7.11

if [[ $SLURM_ARRAY_JOB_ID ]] ; then
	JOB_ID=$SLURM_ARRAY_JOB_ID
	SUB_ID=$SLURM_ARRAY_TASK_ID
else
	JOB_ID=$SLURM_JOB_ID
	SUB_ID=0
	SLURM_ARRAY_TASK_MAX=-1
	SLURM_ARRAY_TASK_MIN=-2
fi
mkdir -p $JOB_ID/$SUB_ID
cd $JOB_ID/$SUB_ID

srun $SLURM_SUBMIT_DIR/p_array $SLURM_ARRAY_TASK_MAX $SLURM_ARRAY_TASK_MIN > with_p.$SUB_ID  2>&1 
srun $SLURM_SUBMIT_DIR/c_array $SLURM_ARRAY_TASK_MAX $SLURM_ARRAY_TASK_MIN > with_c.$SUB_ID  2>&1 
srun $SLURM_SUBMIT_DIR/f_array $SLURM_ARRAY_TASK_MAX $SLURM_ARRAY_TASK_MIN > with_f.$SUB_ID  2>&1 



