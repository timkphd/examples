all: cexam fexam

CC=icc
FC=ifort
OMP=-qopenmp

CEXES =atomic  invertc  private  schedule  singleSubsectionc  sortc

FEXES =commonInModMaintain2 withoutcrit singleSubsectionf \
       commonMaintain invertf omp_fft sortf \
       critical module withprivate withcrit task ranmod

cexam: $(CEXES)

fexam: $(FEXES)

%:%.c
	$(CC) $(OMP)  $< -o $@
%:%.f90
	$(FC) $(OMP)  $< -o $@
	rm -f *mod

task:task.f90
#	ifort -qopenmp -O3 -liompprof5 task.f90 -o task
	ifort -qopenmp -O3             task.f90 -o task

clean:
	rm -rf $(CEXES) $(FEXES) err.pbs out.pbs a.out *mod

tar:
	make clean
	tar --exclude .svn -cf openmp.tar *c *f90 *rpbs makefile index.html openmp.pdf


