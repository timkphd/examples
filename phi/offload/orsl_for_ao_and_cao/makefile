#from
# http://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-compiler-assisted-offload-and-automatic-offload-example
#

LIBS=-limf -lsvml -lirng -lintlc
both: t.sim t.out

OPT=-O0 -std=c99  -g -mkl -openmp -offload-option,mic,ld,"--no-undefined" $(LIBS)
#OPT=-O0 -std=c99  -g -mkl -openmp 

t.out: t.c
	icc $(OPT) t.c -o t.out

t.sim: t.simple.c
	icc $(OPT) t.simple.c -o t.sim

clean:
	rm -rf t.sim t.out
	rm -rf *hosts* 1_* 0_* *script* *slurm* *out*
