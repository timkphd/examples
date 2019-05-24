#module purge

phostone.ibm:phostone.c
	mpcc -qsmp=omp phostone.c -o phostone.ibm

#module purge
#module load GCC/4.8.5-system
#module load OpenMPI

phostone.old:phostone.c
	mpicc -fopenmp phostone.c  -o phostone.old


#module purge
#module load StdEnv

phostone.new:phostone.c
	mpicc -fopenmp phostone.c  -o phostone.new

#module purge
#module load StdEnv

phostone.pgi:phostone.c
	mpicc -mp phostone.c -g  -o phostone.pgi

#module purge
#module load XL
#module load OpenMPI

phostone.xlc:phostone.c
	mpicc -qsmp=omp phostone.c -o phostone.xlc

clean:
	rm -f phostone.pgi phostone.ibm phostone.old phostone.new phostone.xlc pgi* new* old* ibm* xlc* *out *list
