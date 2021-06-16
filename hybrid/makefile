#set the module and call make again
recurse: 
	source  $$MODULESHOME/init/bash ; module load mpt/2.23 gcc/10.1.0             ; export MPICC=mpicc  ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.mpt
	source  $$MODULESHOME/init/bash ; module load intel-mpi/2020.1.217 gcc/10.1.0 ; export MPICC=mpiicc ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.icc
	source  $$MODULESHOME/init/bash ; module load intel-mpi/2020.1.217 gcc/10.1.0 ; export MPICC=mpicc  ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.gcc
	source  $$MODULESHOME/init/bash ; module load openmpi/4.1.0/gcc-8.4.0  comp-intel/2020.1.217  ; export OMPI_MPICC=icc; export MPICC=mpicc  ; $(MAKE) -f $(firstword $(MAKEFILE_LIST)) phostone.oin

TARGETS=phostone.mpt phostone.gcc phostone.oin phostone.icc	

$(TARGETS) : phostone.c
	$(MPICC) -fopenmp $< -o $@

clean:
	rm -rf $(TARGETS)

