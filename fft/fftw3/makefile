serial: simp simpf testf

all: serial mpi_ex2

ifdef VERSION
-include ${VERSION}.inc
else
-include gcc.inc
endif

mpi_ex2:mpi_ex2.c
	mpicc mpi_ex2.c   $(PLIBS) -lm -o mpi_ex2

simp: simp.c
	$(CC)  -fopenmp simp.c $(SLIBS) -lm -o simp

simpf: simpf.c
	$(CC)  -fopenmp simpf.c $(SLIBS) -lm -o simpf

testf: test.f90
	$(FC) test.f90 $(SLIBS) -o testf

clean:
	rm -rf mpi_ex2 simp simpf testf fftout.*

