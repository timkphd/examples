#set the module and call make again
recurse: 
	source  $$MODULESHOME/init/bash ; module load mpt/2.23 gcc/10.1.0             ; export MPICC=mpicc  ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.mpt
	source  $$MODULESHOME/init/bash ; module load intel-mpi/2020.1.217 gcc/10.1.0 ; export MPICC=mpiicc ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.icc
	source  $$MODULESHOME/init/bash ; module load intel-mpi/2020.1.217 gcc/10.1.0 ; export MPICC=mpicc  ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.gcc
	
phostone.icc: phostone.c
	$(MPICC) -fopenmp phostone.c -o phostone.icc
	
phostone.gcc: phostone.c
	$(MPICC) -fopenmp phostone.c -o phostone.gcc
	
phostone.mpt: phostone.c
	$(MPICC) -fopenmp phostone.c -o phostone.mpt

clean:
	rm -rf phostone.icc phostone.gcc phostone.mpt

