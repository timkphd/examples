:<<++++

Author: Tim Kaiser

Build a new version of python with and Intel MPI version of mpi4py
Works with OpenMPI, just change the module load commands.


USAGE:
    source jupyter.sh

 To use the new version after the initial Install
   module load conda
   source activate
   source activate $MYVERSION
   module load intel-mpi/2020.1.217

++++

### Build a new version of python with and Intel MPI version of mpi4py
CWD=`pwd`
export MYVERSION=dompi
cd ~
module load conda 2> /dev/null || echo "module load conda failed"
conda create --name $MYVERSION python=3.8 jupyter matplotlib scipy pandas xlwt -y

### Don't do conda init
### Just do source activate
source activate 
source activate $MYVERSION

### Install mpi4py
module load intel-mpi/2020.1.217  2> /dev/null || echo "module load intel-mpi/2020.1.217 failed"
pip --no-cache-dir install mpi4py


### Install slurm magic commands 
pip install git+git://github.com/NERSC/slurm-magic.git

:<<++++
In a jupyter activate slurm_magix with 
%load_ext slurm_magic
++++

cd $CWD
