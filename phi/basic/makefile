default: helloc  hellof

helloc:helloc.c
	mpicc helloc.c -o helloc

hellof:hellof.f90
	mpif90 hellof.f90 -o hellof

clean:
	rm -rf  helloc  hellof *out *script hosts*

tar: helloc.c  hellof.f90  makefile  runintel  runit  runopenmpi  silly.conf  sub.conf
	tar -czf basic.tgz helloc.c  hellof.f90  makefile  runintel  runit  runopenmpi  silly.conf  sub.conf
