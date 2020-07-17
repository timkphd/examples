# A relatively simple makefile for two programs, one Fortran the 
# other C.   The Fortran files have a dependency on the mods.o 
# file and the C files on headers.h
#
# This file also shows how you can have a single makefile build
# multiple programs.  If you enter  just "make" the target is 
# both which causes both stc_00 and stf_00 to be built
# you can also enter
# make stc_00
#     or
# make stf_00
# which will build only one fo the programs.

both:stc_00 stf_00

stc_00: utility.o calculate.o output.o stc_00.o
	$(CC) $(OPT) utility.o calculate.o output.o stc_00.o -lm -o stc_00

stf_00: utilityf.o calculatef.o outputf.o stf_00.o mods.o
	$(F90) $(OPT) utilityf.o calculatef.o outputf.o stf_00.o mods.o -o stf_00

CC=gcc
# Next F90 line assumes that we have the pgf90 Fortran compiler.  This can
# be changed to gfortran or ifort   
######  ml pgi64 ######
F90=pgf90
OPT=-O3 -g

utility.o: utility.c headers.h
	$(CC) $(OPT) -c utility.c

calculate.o: calculate.c headers.h
	$(CC) $(OPT) -c calculate.c

output.o: output.c headers.h
	$(CC) $(OPT) -c output.c

# For the stc_00.o file we rely on the default build procedure for c files
# You will note that this gives your different compile line options.
stc_00.o: stc_00.c headers.h


mods.o: mods.f90
	$(F90) $(OPT) -c mods.f90

utilityf.o: utilityf.f90 mods.o
	$(F90) $(OPT) -c utilityf.f90

calculatef.o: calculatef.f90 mods.o
	$(F90) $(OPT) -c calculatef.f90

outputf.o: outputf.f90 mods.o
	$(F90) $(OPT) -c outputf.f90

stf_00.o: stf_00.f90 mods.o
	$(F90) $(OPT) -c stf_00.f90


clean:
	rm -rf utility.o  calculate.o  output.o  stc_00.o        stc_00 \
	       utilityf.o calculatef.o outputf.o stf_00.o mods.o stf_00 *.mod
