ALL=c01 c02 f01 f02 f03

all: $(ALL)

MPICC=mpicc
MPIF90=mpif90
.SUFFIXES: .f90 .c

.c:
	$(MPICC) $(CFLAGS) $< -o $@


.f90:
	$(MPIF90) $(CFLAGS) $< -o $@


clean:
	rm -rf $(ALL)
	
tar:
	tar -cf escripts.tar *.c *.f90 makefile script* match
