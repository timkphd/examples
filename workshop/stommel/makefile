ALLF=stf_00  stf_01  stf_02  stf_03  stf_04  stf_05  stf_06  stf_07
ALLC=stc_00 stc_01 stc_02 stc_03 stc_04 stc_05 stc_06 stc_07
dafault: $(ALLF) $(ALLC) plotit
c:  $(ALLC)
f:  $(ALLF)



SFC=ifort
FC=mpif90
FFLAGS=-O3

SCC=icc
CC=mpicc
CFLAGS= -O3 -lm

plotit:  plotit.c
	$(SCC) plotit.c -o plotit $(CFLAGS) 

stc_00:  stc_00.c
	$(SCC) stc_00.c -o stc_00 $(CFLAGS) 

stf_00:  stf_00.f90
	$(SFC) $(FFLAGS) stf_00.f90 -o stf_00

.SUFFIXES: .f90

.c: 
	$(CC)   $< -o $* $(CFLAGS) 

.f90: 
	$(FC) $(FFLAGS)  $< -o $*


clean_c:
	/bin/rm -f $(ALLC) plotit

clean_f:
	/bin/rm -f $(ALLF) *mod

clean:
	/bin/rm -f *mod $(ALLF) $(ALLC) plotit *out*



