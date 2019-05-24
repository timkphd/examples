default: helloc 

ifeq ($(HOSTNAME),mc2)

#for bgq
FLIBS=-L/opt/ibmcmp/xlf/bg/14.1/lib64 -lxlopt -lxl -lxlf90 -lxlfmath
PF=mpixlf90_r
PC=mpixlc_r -DNODE_COLOR=node_color
OMP=-qsmp=omp

else

#for openmpi on AuN
FLIBS=-lmpi_f90 -lmpi_f77
PF=mpif90
PC=mpicc -DNODE_COLOR=node_color_
OMP=-openmp
endif

ifeq ($(HOSTNAME),mio001)
#for IntelMPI on Mio001
FLIBS=-lifcore 
FLIBS=-lifcore -lmpi_mpifh
OMP=-openmp
endif

ifeq ($(MPI_SUFFIX),_openmpi)
#for openmpi
FLIBS=-lmpi_f90 -lmpi_f77
OMP=-openmp
endif

ifeq ($(MPI_SUFFIX),_intelmpi)
#for Intel mpi 
FLIBS=-lifcore
OMP=-openmp
endif

ifneq (,$(findstring ppc,$(HOSTNAME)))
FLIBS=-lgfortran -lmpi_mpifh
OMP=-fopenmp
endif

ifdef SLURM_JOB_PARTITION
FLIBS=-lgfortran -lmpi_mpifh
OMP=-fopenmp
endif

#If you want the program to print the environment
#on each compute node uncomment the next line.
#DO_ENV=-DDO_ENV

color.o: color.f90 makefile 
	echo $(HOSTNAME)
	$(PF) -c color.f90

docol: docol.f90 makefile 
	$(PF)  -o docol docol.f90
	rm -rf mympi.mod  numz.mod *.o

helloc: helloc.c color.o makefile 
	$(PC) $(DO_ENV) helloc.c color.o ${FLIBS} -o helloc
	rm -rf *.o

phostname: phostname.c color.o makefile 
	$(PC) $(OMP) phostname.c color.o ${FLIBS} -o phostname
	rm -rf *.o

phostone: phostone.c makefile 
	$(PC) $(OMP) phostone.c  -o phostone
	rm -rf *.o

clean:
	rm -rf color.o helloc docol mympi.mod  numz.mod phostname phostone

tgz: add.f90 aun_script color.f90 docol.f90 helloc.c info.html input makefile mc2_script mio1_script out.dat phostname.c phostone.c power_script set_alias simple simple_slurm slurm_script 
	tar -czf example.tgz add.f90 aun_script color.f90 docol.f90 helloc.c info.html input makefile mc2_script mio1_script out.dat phostname.c phostone.c power_script set_alias simple simple_slurm slurm_script 



populate: tgz
	scp example.tgz mc2:/opt/utility/quickstart/
	scp example.tgz aun:/opt/utility/quickstart/
	scp example.tgz mio001:/opt/utility/quickstart/
	scp example.tgz tkaiser@illuminate.mines.edu:/u/pa/ru/tkaiser/geco/prototype/How_do_I_do_a_simple_build_and_run

