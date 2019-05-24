##### build commands #####
#export CAF=intel
#  or
#export CAF=g95
#  or
#export CAF=cray
#make

include intel.inc
include $(CAF).inc

default: pi hello bug

pi:pi.f90 myenv.o makefile
	$(FORT) $(FOPT) pi.f90 myenv.o -o pi

clean:
	rm -f pi err* out* mynodes* *.o *.mod hello bug

myenv.o: $(ENVFILE) makefile
	$(FORT) -c $(ENVFILE)  -o myenv.o


hello:hello.f90
	$(FORT) $(FOPT) hello.f90 -o hello

bug:bug.f90
	$(FORT) $(FOPT) bug.f90 -o bug

##### Mio Compilers #####
#which ifort
#/opt/intel/2011/composerxe-2011.0.084/bin/intel64/ifort
#which g95
#/opt/development/g95/g95-install/bin/g95

##### Cray Compilers #####
#module unload PrgEnv-pgi
#module load PrgEnv-cray

##### launch commands inside your pbs script #####
##### g95
#./pi  --g95 images=8 < input
#
##### intel
#mpdboot --totalnum=2 --file=mynodes.$PBS_JOBID
#export FOR_COARRAY_NUM_IMAGES=16
#./pi < input
#mpdallexit
#
##### cray
#aprun -n 12 pi < input

