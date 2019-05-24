#Location of compiler version 10 and 11.x of MKL.
#Use one or the other.  These will change in the
#future. 11.x should set MKLROOT

ifdef MKLROOT
LIBPATH=$(MKLROOT)/lib/em64t
INCPATH=$(MKLROOT)/include
else
LIBPATH=/opt/intel/mkl/10.0.1.014/lib/em64t
INCPATH=/opt/intel/mkl/10.0.1.014/include
endif

#For old RA
LIBPATH=/opt/intel/Compiler/11.0/081/mkl/lib/em64t
INCPATH=/opt/intel/Compiler/11.0/081/mkl/include

#For RA5
LIBPATH=/opt/intel/Compiler/11.1/069/mkl/lib/em64t
INCPATH=/opt/intel/Compiler/11.1/069/mkl/include


#There is a bug in the Intel 10 compiler that
#prevents psgesv.f90 from working correctly at
#optimization greater than -O1
OPT=-O1 

all: psgesv ex1_f ex1_c pdpttr_2c pdpttr_2f  lin_f lin_c

#For dynamic linking use the next setting for LIBS.
#You will need to set your LD_LIBRARY_PATH environmental
#variable to point to LIBPATH or you might get an error
#message about "cannot open shared object file"
LIBS= \
  -L$(LIBPATH) \
  -lmkl_scalapack_lp64 \
  -lmkl_intel_lp64 \
  -lmkl_blacs_openmpi_lp64 \
  -lmkl_sequential \
  -lmkl_core \
  -lpthread

#For static linking use the next line for LIBS.
LIBS= \
  $(LIBPATH)/libmkl_scalapack_lp64.a \
  $(LIBPATH)/libmkl_intel_lp64.a \
  $(LIBPATH)/libmkl_blacs_openmpi_lp64.a \
  $(LIBPATH)/libmkl_sequential.a \
  $(LIBPATH)/libmkl_core.a  \
  $(LIBPATH)/libmkl_sequential.a \
  $(LIBPATH)/libmkl_core.a \
  -lpthread $(SUPPRESS)


#surpress warning: feupdateenv is not implemented and will always fail
#this causes problems with some programs
SUPPRESS=-i_dynamic

LIBS=-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -mkl
#LIBS=-lmkl_scalapack_lp64 -lmkl_blacs_lp64 -mkl $(SUPPRESS)


psgesv:psgesv.f90 Makefile
	mpif90 $(OPT) -o psgesv psgesv.f90 $(LIBS)
        
ex1_f:ex1.f90 Makefile
	mpif90 $(OPT) -o ex1_f ex1.f90 $(LIBS)

pdpttr_2c:pdpttr_2.c Makefile
	mpicc $(OPT) -o pdpttr_2c -I$(INCPATH) pdpttr_2.c $(LIBS)

ex1_c:ex1.c Makefile
	mpicc $(OPT) -o ex1_c -I$(INCPATH) ex1.c $(LIBS)

pdpttr_2f:pdpttr_2.f90 Makefile
	mpif90 $(OPT) -o pdpttr_2f pdpttr_2.f90 $(LIBS)

lin_f:linsolve.f90 Makefile
	mpif90 $(OPT) -o lin_f linsolve.f90 $(LIBS)

lin_c:linsolve.c linsolve.h Makefile
	mpicc $(OPT) -o lin_c -I$(INCPATH) linsolve.c $(LIBS)

clean:
	rm -rf *o *ra.local ex1_c ex1_f lin_c lin_f pdpttr_2c pdpttr_2f psgesv *mio.mines.edu wget.out

tar:
	tar -cf  libs.tar   ex1.c  ex1.f90  in.dat  linsolve.c  linsolve.f90  linsolve.h  Makefile  pbsfile  pdpttr_2.c  pdpttr_2.f90  psgesv.f90


