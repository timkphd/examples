all: fillmemlap fillmem fillmemnr



fillmemlap: pointer.f90 mymod.o
	ifort -O3  -L/opt/lib/lapack/3.2.1/intel pointer.f90 -openmp  -o fillmemlap  -llapack -lblas  -ltmglib  -lmkl_intel_lp64  -lmkl_sequential  -lmkl_core -static 

fillmem: pointer.f90 mymod.o
	ifort -O3 -mkl -openmp pointer.f90 -o fillmem

fillmemnr: pointernr.f90 mymod.o
	ifort -O3 -mkl -openmp pointernr.f90 -o fillmemnr

mymod.o: mymod.f90
	ifort -mkl -c mymod.f90

clean:
	rm -rf fillmemlap fillmem fillmemnr mymod.o *mod
