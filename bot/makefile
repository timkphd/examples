all: f_array c_array dummy
ALL: all spam.so
CC=mpicc
FC=mpif90
CFLAGS=-O3
# path to python include directory
PYFLAGS=-I/bgsys/tools/Python-2.7/include/python2.7
LDFLAGS=
.SUFFIXES: .f90

#f_array: f_array.f90
#c_array: c_array.c

    
.c:
	$(CC) $(CFLAGS) $< -o $@

.f90:
	$(FC) $(CFLAGS) $< -o $@

spam.o: spam.c
	gcc $(PYFLAGS) -c spam.c

spam.so: spam.o
	gcc -shared spam.o -o spam.so

clean:
	rm -rf f_array c_array spam.o spam.so dummy
