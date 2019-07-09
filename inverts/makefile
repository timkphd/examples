all:lapack mine mkl mkl_c lapack_c post

LAP_BASE=/Users/timk/local/lapack
LAP_LIB_DIR=$(LAP_BASE)/lib
LAP_INC_DIR=$(LAP_BASE)/include
LAP_LIBS=-llapack -lrefblas
MKL_DIR=/opt/intel/mkl/lib
MKL_LIBS=-lmkl_core -lmkl_intel_lp64 -lmkl_blas95_lp64 -lmkl_intel_thread

.SUFFIXES: .f90
F90=gfortran

lapack:regt.f90
	$(F90) -cpp -O3 regt.f90 -L$(LAP_LIB_DIR) $(LAP_LIBS) -o lapack
	
mkl:regt.f90
	$(F90) -cpp -O3 regt.f90 -L$(MKL_DIR) $(MKL_LIBS) -o mkl

myover.o: myover.f90
	$(F90) -cpp  -DMINE -O3 -c myover.f90 

#mine: myover.o regt.f90
#	$(F90) -cpp -DMINE -O3 myover.o regt.f90 -o mine

mine:myover.f90 regt.f90
	$(F90) -cpp -DMINE -O3 myover.f90 regt.f90 -o mine
	
regt.o:regt.c
	gcc -O3 -I$(LAP_INC_DIR) -c regt.c

mkl_c:regt.o
	gcc regt.o -L$(MKL_DIR) $(MKL_LIBS) -o mkl_c

lapack_c:regt.o
	gfortran regt.o -L$(LAP_LIB_DIR) -llapacke $(LAP_LIBS) -o lapack_c


mine_c:regt.o
	gcc regt.o myover.c -o regt_c

clean:
	rm -rf mine mkl lapack *mod *.o mine_c mkl_c lapack_c input

post:
	rm -rf *mod *.o
	
backup:
	tar -czf invert.tgz tymer *.c *.f90 *R *py slurm.sh makefile

