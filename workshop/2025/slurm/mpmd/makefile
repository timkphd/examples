both: helloF helloc

helloF:hellof.f90
	mpif90 hellof.f90 -o helloF

helloc:helloc.c
	mpicc helloc.c -o helloc

clean:
	rm -rf helloF helloc run_* std* apps hlist
