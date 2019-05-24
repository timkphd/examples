ALL= f03 mpiio

all: $(ALL)

MPICC=mpicc
MPIF90=mpif90
.SUFFIXES: .f90 .c

.c:
	$(MPICC) $(CFLAGS) $< -o $@


.f90:
	$(MPIF90) $(CFLAGS) $< -o $@


clean:
	rm -rf $(ALL) testIO*
	
tar:
	tar -cf data.tar *.f90 makefile script* *.c dummy.data 
