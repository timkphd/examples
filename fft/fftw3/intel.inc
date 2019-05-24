#for Mio
#module purge ; module load Compiler/intel/18.0   MPI/impi/2018.1/intel   Lib/fftw3/mkl/2018/intel/intelmpi
#for AuN
#module purge ; module load PrgEnv/intel/18.0 impi/intel/latest PrgEnv/libs/fftw/fftw3/mkl/2018/intel/intelmpi
#module purge ; module load PrgEnv/intel/18.0 impi/intel/2018   PrgEnv/libs/fftw/fftw3/mkl/2018/intel/intelmpi

PLIBS=-lmkl_cdft_core  -lfftw3x_cdft_lp64 -lmkl_blacs_intelmpi_lp64 -lfftw3xc_intel -mkl
SLIBS=-lfftw3xc_intel -mkl
CC=icc
FC=ifort

