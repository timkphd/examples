#for mio
#module load Compiler/intel/18.0   MPI/impi/2018.1/intel   Lib/fftw3/mkl/2018/intel/intelmpi
#for aun
#module purge ; module load PrgEnv/intel/18.0 impi/intel/2018   PrgEnv/libs/fftw/fftw3/mkl/2018/intel/intelmpi
serial: test2c test2f


CC=icc
FC=ifort


test2c:test2.c
	$(CC) test2.c -lfftw2xc_double_intel -mkl -o test2c

test2f:test2.f
	$(FC) test2.f -lfftw2xf_double_intel -mkl -o test2f


clean:
	rm -rf test2f test2c

