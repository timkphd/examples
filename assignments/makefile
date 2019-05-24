both: fint cint

fint: doint.f90
	ifort doint.f90 -o fint

cint: doint.c
	icc doint.c -o cint

tar:
	tar -cf assignment.tar assignment1  assignment2  doint.c  doint.f90  index.html  input

clean:
	rm -rf *mod cint fint


