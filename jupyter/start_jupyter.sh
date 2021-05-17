#!/bin/bash
#SBATCH --job-name="jupyter"
#SBATCH --nodes=2
#SBATCH --account=hpcapps
#SBATCH --time=01:00:00
##SBATCH --mail-type=ALL
##SBATCH --mail-user=tkaiser2@nrel.gov
#SBATCH --partition=debug


export MYVERSION=may11b
module load conda
source activate
source activate /scratch/$USER/$MYVERSION

module load mpt
module load cuda/11.2   cudnn/8.1.1/cuda-11.2   gcc/8.4.0


date      > ~/jupyter.log
hostname >> ~/jupyter.log
jupyter notebook --NotebookApp.password='' --no-browser  >> ~/jupyter.log 2>&1
