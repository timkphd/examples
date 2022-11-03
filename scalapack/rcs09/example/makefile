all: mklc mklf fourd.mkl

mklc: mkl.c
	icc -O3 -o mklc mkl.c -mkl

mklf: mkl.f90
	ifort -O3 -o mklf mkl.f90 -mkl

fourd.mkl:fourd.f90
	ifort   -O3 -o fourd.mkl fourd.f90  -mkl
	rm -rf *mod


clean:
	rm -rf mklc mklf fourd.mkl *mod rm out.dat

run: all
	./mklc
	./mklf
	./fourd.mkl

