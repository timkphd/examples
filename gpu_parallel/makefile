#default: tmpi topenmp gpucount
default: topenmp gpucount mpitest

MPI=/opt/development/exp/mpi/builds/1.5.1/pg-11.5_posix/bin/mpif90
PRE=-Mpreprocess -Dmagma_devptr_t="integer(kind=8)"
INCLUDE=-I/opt/development/gpu/current/cuda/include -I$(BASE)/include
OPT=-O3

BASE=/opt/development/gpu/magma/1.0.0_pg
MAGMA=-L$(BASE)/lib -lmagma -lmagmablas -lmagma 
CUDA=-L/opt/development/gpu/current/cuda/lib64 -lcuda -lcublas 
ACML=-L/opt/pgi/linux86-64/2011/acml/4.4.0/lib -lacml 
BLAS=-L$(BASE)/cblas/CBLAS/lib -lcblas 
CUDAFOR=-lcudafor

tmpi.o: tmpi.f90
	$(MPI) $(OPT) $(PRE) $(INCLUDE) -c tmpi.f90

tmpi: tmpi.o
	$(MPI) tmpi.o $(BASE)/testing/fortran.o -o tmpi  $(MAGMA) $(CUDA) $(ACML) $(BLAS) $(CUDAFOR)
	rm *mod tmpi.o

gpucount: gpucount.c
	nvcc gpucount.c -o gpucount

clean:
	rm -f tmpi.o tmpi topenmp *mod gpucount stdout stderr *.o mpitest

tar:
	~/bin/backup makefile tmpi.f90 openmp.f90 gpucount.c script mface.c

CULA=-I/opt/development/gpu/current/cula/include -L/opt/development/gpu/current/cula/lib64 
CUDA2=-lcula_core -lcula_lapack  -lcublas -lcudart

topenmp: openmp.f90
	pgf90 -c /opt/development/gpu/current/cula/include/cula_status.f90
	pgf90 -c /opt/development/gpu/current/cula/include/cula_lapack.f90
	pgf90  -mp openmp.f90 -O3 cula_lapack.o  cula_status.o $(CULA) $(CUDA2) -o topenmp
	rm *mod *.o

mpitest: mpi.f90
	mpif90 -c /opt/development/gpu/current/cula/include/cula_lapack.f90
	mpif90 -c /opt/development/gpu/current/cula/include/cula_status.f90
	mpif90  mpi.f90 cula_lapack.o cula_status.o $(CULA) $(CUDA2) -o mpitest
	rm *mod *.o

