#Set MPI version and commands.  These can be overloaded by command line options
MOD=intel-mpi/2020.1.217 cuda
MPICC=mpiicc
MPIFC=mpiifort

#set the module and call make again
recurse: 
	source $$MODULESHOME/init/bash ; ml $(MOD)  ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) programs

#here we list the real targets
programs: phostone stf_01 f_ex02 c_ex02 mpigpu

phostone: phostone.c 
	$(MPICC) -fopenmp phostone.c -o phostone

stf_01: stf_01.f90 
	$(MPIFC)  stf_01.f90 -o stf_01

f_ex02: f_ex02.f90
	$(MPIFC)  f_ex02.f90 -o f_ex02


c_ex02: c_ex02.c
	$(MPICC)  c_ex02.c -o c_ex02

mpigpu: hysub.cu hymain.c
	nvcc -c hysub.cu
	$(MPICC) hymain.c hysub.o -lcudart -o mpigpu

clean:
	rm -rf phostone stf_01 f_ex02 c_ex02 mpigpu *mod

install: recurse
	cp phostone stf_01 f_ex02 c_ex02 mpigpu doarray.py report.py tymer ..

dist-clean: clean
	rm -rf ../phostone ../stf_01 ../f_ex02 ../c_ex02 ../mpigpu ../doarray.py ../report.py ../tymer


