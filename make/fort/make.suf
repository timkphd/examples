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

# We tell make that we are compiling *.f90 files.
.SUFFIXES: .f90 .mod

# This is the default way we build .o file from .f90 files.
.f90.o:
	$(FC) $(OPT) -c $<

# This is how we build .mod file from .f90 files.
.f90.mod:
	$(FC) $(OPT) -c $<

# face.mod is one of the *.mod files that get created from mods.f90
# In this case we ask that only face.mod get build but we actually
# get all of the *.mod files from mods.f90.
face.mod : mods.f90
	$(FC) $(OPT) -c mods.f90

# Here are the list of the rest of the *f90 build commands.  We are
# using the default command given above to do the build.
# Note that each build depends on face.mod getting built first.  For
# an example of how to "automate" this dependency see the "C" example
acc.o: acc.f90 face.mod

steps.o: steps.f90 face.mod

evolve.o: evolve.f90 face.mod

output.o: output.f90 face.mod

input.o: input.f90 face.mod

main.o: main.f90 face.mod

# Our final build combines the *.o files.
nbody:
	$(FC) -o nbody acc.o steps.o evolve.o output.o input.o main.o mods.o

tidy:
	rm -rf *.o *.mod 

clean:
	rm -rf *.o *.mod nbody


