#!/bin/bash
#SBATCH --job-name="runpi"
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --export=ALL
#SBATCH --time=04:00:00
#SBATCH --partition=shared

cat $0 > script.$SLURM_JOBID

source /nopt/nrel/apps/env.sh

CRAY=true
INTEL=true
OPENMPI=true
MPICH=true

PY09=python-3.9.0-gcc-12.1.0-5itvzw5
PY11=python-3.11.2-gcc-12.1.0-y2z47rv

#CONNECT=--mpi=pmi2

for VERSION in 9 11 ; do

if $CRAY ; then
echo
echo
echo "++++++++++++++++++++" $VERSION
module purge
module load PrgEnv-cray
module load gcc
module use /nopt/nrel/apps/pythons/041323_a/tcl/linux-rhel8-icelake
if [[ $VERSION ==  9 ]] ; then module load $PY09 ; fi
if [[ $VERSION == 11 ]] ; then module load $PY11 ; fi
which python
which mpicc
export LD_PRELOAD=/usr/lib64/libcrypto.so.1.1
srun $CONNECT -n 4  ./ptp.py 
unset LD_PRELOAD
module purge
module unuse /nopt/nrel/apps/pythons/041323_a/tcl/linux-rhel8-icelake
fi

if $INTEL ; then
echo
echo
echo "++++++++++++++++++++" $VERSION
module use /nopt/nrel/apps/pythons/041323_b/tcl/linux-rhel8-icelake
module purge
module load intel-oneapi-mpi/2021.8.0-intel
module load gcc
if [[ $VERSION ==  9 ]] ; then module load $PY09 ; fi
if [[ $VERSION == 11 ]] ; then module load $PY11 ; fi
which python
which mpicc
srun $CONNECT -n 4 ./ptp.py
module purge
module unuse /nopt/nrel/apps/pythons/041323_b/tcl/linux-rhel8-icelake
fi

if $OPENMPI ; then
echo
echo
echo "++++++++++++++++++++" $VERSION
module use /nopt/nrel/apps/pythons/041323_c/tcl/linux-rhel8-icelake
module purge
module load openmpi/4.1.5-gcc
module load gcc
if [[ $VERSION ==  9 ]] ; then module load $PY09 ; fi
if [[ $VERSION == 11 ]] ; then module load $PY11 ; fi
which python
which mpicc
export OMPI_MCA_opal_cuda_support=0
srun $CONNECT -n 4 ./ptp.py
unset OMPI_MCA_opal_cuda_support
module purge
module unuse /nopt/nrel/apps/pythons/041323_c/tcl/linux-rhel8-icelake
fi

if $MPICH ; then
echo
echo
echo "++++++++++++++++++++" $VERSION
module use /nopt/nrel/apps/pythons/041323_d/tcl/linux-rhel8-icelake
module purge
module load mpich/4.1-gcc
module load gcc
if [[ $VERSION ==  9 ]] ; then module load $PY09 ; fi
if [[ $VERSION == 11 ]] ; then module load $PY11 ; fi
which python
which mpicc
export UCX_NET_DEVICES=bond0
srun $CONNECT -n 4 ./ptp.py
unset UCX_NET_DEVICES
module purge
module unuse /nopt/nrel/apps/pythons/041323_d/tcl/linux-rhel8-icelake
echo
echo
fi
done

:<<++++
++++




