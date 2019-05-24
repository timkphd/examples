all: invertc  pointer invertf workerbee

invertf: invertf.f90
	ifort -openmp -O3 invertf.f90 -o invertf
	rm -rf *mod

invertc: invertc.c
	icc -openmp -O3 invertc.c -o invertc

workerbee: workerbee.c
	mpicc workerbee.c -o workerbee

pointer: pointer.f90
	ifort -openmp -O3 pointer.f90 -mkl -o pointer
	rm -rf *mod

clean:
	rm -rf *mod invertc pointer *mio.mines.edu sum_input invertf workerbee

tar:
	tar -cf tricks.tar batch2  invertc.c  makefile  pointer.f90 invertf.f90 workerbee.c
