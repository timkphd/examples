#For Intel x86
CFLAGS=-DOMKL
PFC=mpif90
PCC=mpicc
LIBS=-mkl -L/opt/intel/mkl/lib/intel64 -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64
FLIBS=

