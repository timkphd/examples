all: allc allf
allc: ex1_c lin_c          pdpttr_c
allf: ex1_f lin_f psgesv_f pdpttr_f

#required modules for Mc2
#module load PrgEnv/IBM/XLF/14.1.bgq
#module load PrgEnv/IBM/VACPP/12.1.bgq
#module load PrgEnv/libs/essl-5.1
#module load PrgEnv/libs/lapack-3.5_xl-O2
#module load PrgEnv/libs/scalapack-2.0.2_xl

ARCH=x86
include $(ARCH).inc
# The include file defines the following:
#CFLAGS=
#FFLAGS=
#PFC=
#PCC=
#LIBS=
#FLIBS=


ex1_c: ex1.c
	$(PCC) $(CFLAGS) ex1.c $(LIBS) $(FLIBS) -o ex1_c

lin_c: linsolve.c
	$(PCC) $(CFLAGS) linsolve.c $(LIBS) $(FLIBS) -o lin_c

pdpttr_c: pdpttr_2.c
	$(PCC) $(CFLAGS) pdpttr_2.c $(LIBS) $(FLIBS) -o pdpttr_c

ex1_f: ex1.c
	$(PFC) $(FFLAGS) ex1.f90 $(LIBS) $(FLIBS) -o ex1_f

lin_f: linsolve.c
	$(PFC) $(FFLAGS) linsolve.f90 $(LIBS) $(FLIBS) -o lin_f

pdpttr_f: pdpttr_2.f90
	$(PFC) $(FFLAGS) pdpttr_2.f90 $(LIBS) $(FLIBS) -o pdpttr_f

psgesv_f: psgesv.f90
	$(PFC) $(FFLAGS) psgesv.f90 $(LIBS) $(FLIBS) -o psgesv_f

clean:
	rm -rf ex1_c lin_c pdpttr_c ex1_f lin_f psgesv_f pdpttr_f

tar:
	tar -czf  example.tgz  casestudy  ex1.c  ex1.f90  in.dat  linsolve.c  linsolve.f90  linsolve.h  Makefile  pbsfile  pdpttr_2.c  pdpttr_2.f90  psgesv.f90  rcs09 index.html Readme bgq.inc x86.inc slurmfile

