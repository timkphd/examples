both: trackit track_g

trackit: track.o domem.o

INC=-I/bgsys/drivers/V1R2M4/ppc64 -I/bgsys/drivers/V1R2M4/ppc64/spi/include/kernel/cnk
GF=/bgsys/drivers/ppcfloor/gnu-linux-4.7.2/powerpc64-bgq-linux/bin/gfortran

track.o: track.c
	bgxlc_r $(INC) -c track.c

domem.o:domem.f90
	bgxlf90_r -qsmp=omp -c domem.f90

trackit:
	bgxlf90_r -qsmp=omp -O3 domem.o track.o -o trackit
	rm -rf *mod 

track_g:track.o
	$(GF) -g -fopenmp -O3 domem.f90 track.o -o track_g	
	rm *mod 

	rm -rf *mod *o

clean:
	rm -rf  domem.o track.o trackit* time* slurm* *mod track_g core.* \
                track_g.backtrace  track_g.core  track_g.stack

