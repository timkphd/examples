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
	$(SCC) $(CFLAGS) plotit.c -o plotit 

stc_00:  stc_00.c
	$(SCC) $(CFLAGS) stc_00.c -o stc_00

stf_00:  stf_00.f90
	$(SFC) $(FFLAGS) stf_00.f90 -o stf_00

.SUFFIXES: .f90

.c: 
	$(CC) $(CFLAGS)  $< -o $*

.f90: 
	$(FC) $(FFLAGS)  $< -o $*


clean_c:
	/bin/rm -f $(ALLC) plotit

clean_f:
	/bin/rm -f $(ALLF) *mod

clean:
	/bin/rm -f *mod $(ALLF) $(ALLC) plotit

DATA=st.in st.short
LL =runf runc 
tar:
	tar --exclude .svn -cf stommel.tar stf*f90 stc*c $(DATA) $(LL) pbsfile pbsfile.qtf makefile notes python index.html plotit.c


