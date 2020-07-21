# We are making the program nbody that depends on these *.o files
nbody: acc.o steps.o evolve.o output.o input.o main.o

# Here are are compiler options.  This program works with any of the 
# listed compilers.  If you want to use pgf90 or ifort comment out the
# other lines or use the -e FC=gfortran command line option to specify
# the gfortran compiler.
#OPT= -C -g -traceback
OPT= -C -g 
FC= ifort $(OPT)
FC= pgf90 $(OPT)
FC= gfortran $(OPT)

# We have explicit instructions for each object file so we don't
# need to use the SUFFIXES option or set up default instructions
# for building using the Fortran compiler.
# Note that each build depends on face.mod getting built first.  For
# an example of how to "automate" this dependency see the "C" example
acc.o: acc.f90 face.mod
	$(FC) -c acc.f90
	
steps.o: steps.f90 face.mod
	$(FC) -c steps.f90
	
face.mod : mods.f90
	$(FC) -c mods.f90

evolve.o: evolve.f90 face.mod
	$(FC) -c evolve.f90
	
output.o: output.f90 face.mod
	$(FC) -c output.f90

input.o: input.f90 face.mod
	$(FC) -c input.f90

main.o: main.f90 face.mod
	$(FC) -c main.f90
	
# Our final build combines the *.o files.
nbody:
	$(FC) -o nbody acc.o steps.o evolve.o output.o input.o main.o mods.o

tidy:
	rm -rf *.o *.mod 

clean:
	rm -rf *.o *.mod nbody


