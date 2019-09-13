PF90 = mpif90 
PCC  = mpicc 
# We are using Intel compileres instead of gcc and gfortran
F90  = ifort
CC   = icc
all: phostone hellof helloc invertf invertc

CFLAGS = -O3
FFLAGS = -O3
F90FLAGS = -O3

.SUFFIXES: .f90

# The three recipies below give us our parallel compilers
# by default, PF90 and PCC.  You might not want this for
# other codes.
.f:
	$(PF90) $(FFLAGS) $< -o $@

.f90:
	$(PF90) $(F90FLAGS) $< -o $@

.c:
	$(PCC) $(CFLAGS) $< -o $@

# Hybrid MPI/OpenMP
phostone: phostone.c
	$(PCC) $(CFLAGS) -fopenmp $< -o $@
	
# Pure OpenMP
invertc: invertc.c
	$(CC) $(CFLAGS) -fopenmp $< -o $@
	
# Pure OpenMP
invertf: invertf.f90
	$(F90) $(F90FLAGS) -fopenmp $< -o $@
	
clean:
	rm -f *mod  phostone hellof helloc invertf invertc *.err *.out


tar: clean
	rm -f quick.tar
	tar -cf  quick.tar tymer helloc.c index.html invert.R simple \
	hellof.f90 invert.py makefile phostone.c invertf.f90 invertc.c
