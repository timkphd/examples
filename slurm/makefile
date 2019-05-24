all: stc_01 stf_01 phostone helloc hellof hello invertf

FC=gfortran
CC=gcc

# verified with the following modules:
# module purge ; module load PrgEnv/devtoolset-6 PrgEnv/mpi/openmpi/gcc/3.0.0


helloc: helloc.c
	mpicc helloc.c -o helloc

hellof:hellof.f90
	mpif90 hellof.f90 -o hellof

hello:helloc
	cp helloc hello

stc_01: stc_01.c
	mpicc -O3 stc_01.c -lm -o stc_01

stf_01:stf_01.f90
	mpif90 -O3 stf_01.f90 -o stf_01
	rm *mod

phostone:phostone.c
	mpicc -fopenmp phostone.c -o phostone

invertf:invertf.f90
	$(FC) -O3 -fopenmp invertf.f90 -o invertf
	rm *mod

dat:
	./makedat

clean:
	rm -rf invertf stf.out stc_01 stf_01 phostone helloc \
               hellof hello  *mod slurm-* pars list outz-*   \
               dir_* *error *out two four eight rm -rf [0-9]* \
               slurm.tgz README slurm-*.out hostlist applist \
               appfile shortlist nodes.* out2.*

backup: 
	tar --exclude .svn --exclude CVS --exclude CVSROOT --exclude .DS_Store -czf ./slurm.tgz \
helloc.c hellof.f90 index.html invertf.f90 makedat makefile p_array phostone.c README.html \
slurm_array slurm_basic slurm_openmp slurm_record slurm_simple stc_01.c stf_01.f90 st.in heterogen

README:README.html
	awk '{gsub("<[^>]*>", "")}1'  README.html | egrep -v "DOCTYPE|strict.dtd" | fold -w 80 -s > README
