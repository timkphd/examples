# Simplistic Makefile for malloc_count example

<<<<<<< HEAD
CC = gcc
FC = gfortran
#CC=icc
#FC=ifort
=======
>>>>>>> 931f75b3d58c25d6c0242fdf280a367d0fd19160
CFLAGS = -g  -I..
LIBS = -ldl
OBJS = test.o ../malloc_count.o ../stack_count.o
FOBJS = ftest.o ../malloc_count.o ../stack_count.o

all: test ftest

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.f90
	$(FC) $(FFLAGS) -c -o $@ $<

test: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

ftest: $(FOBJS)
	$(FC) $(FFLAGS) $(LDFLAGS) -o $@ $(FOBJS) $(LIBS)
	rm -rf *o *mod

.PHONY: clean

clean:
	rm -rf *.o *.mod test ftest $(OBJS) $(FOBJS) *out* time* build spam*.so mem.py

python:
	python setup.py build
	cp build/*/spam*.so .
	sed -n '/PYTHON_START/,/PYTHON_END/p;/PYTHON_END/q' spam.c > mem.py

