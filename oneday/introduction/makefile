all: c_ex01 f_ex01 pointer invertc

c_ex01 : c_ex01.c
	mpicc -o c_ex01 c_ex01.c

f_ex01: f_ex01.f90
	mpif90 -o f_ex01 f_ex01.f90

pointer: pointer.f90
	ifort -openmp  pointer.f90 -mkl -o pointer

invertc: invertc.c
	icc -openmp  invertc.c -o invertc

clean:
	rm -rf c_ex01 f_ex01 *mod err* out* mynodes* pointer invertc

tar:
	tar -cf introduction.tar makefile batch1 c_ex01.c f_ex01.f90 pointer.f90 invertc.c batch2


