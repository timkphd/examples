#mio
#module purge ;module load PrgEnv/devtoolset-6    MPI/openmpi/3.0.0/gcc  Lib/fftw3/3.3.7/gcc
#aun
#module purge ;module load PrgEnv/devtoolset-6    PrgEnv/mpi/openmpi/gcc/3.0.0 PrgEnv/libs/fftw/gcc/3.3.7_openmpi

PLIBS=-lfftw3_mpi -lfftw3 
SLIBS=-lfftw3 -lfftw3f
CC=gcc
FC=gfortran -I$(CPATH)

