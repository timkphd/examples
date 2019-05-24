default: helloc 

ifeq ($(HOSTNAME),mc2)

#for bgq
FLIBS=-L/opt/ibmcmp/xlf/bg/14.1/lib64 -lxlopt -lxl -lxlf90 -lxlfmath
PF=mpixlf90_r
PC=mpixlc_r -DNODE_COLOR=node_color
OMP=-qsmp=omp

else

#for openmpi/intel 
#note:  might need different libs for openmpi1.6
#FLIBS=-lmpi_f90 -lmpi_f77
FLIBS=-lmpi_mpifh  -lifcore
PF=mpif90
PC=mpicc -DNODE_COLOR=node_color_
OMP=-openmp

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

hello: hello.c node_color.c makefile
	$(PC)  node_color.c hello.c   -o hello
	rm -rf *.o

phostname: phostname.c color.o makefile
	$(PC) $(OMP) phostname.c color.o ${FLIBS} -o phostname
	rm -rf *.o


clean:
	rm -rf color.o helloc docol mympi.mod  numz.mod phostname

tgz: color.f90 docol.f90 helloc.c aun_script mc2_script makefile
	tar -czf example.tgz color.f90 docol.f90 helloc.c aun_script mc2_script makefile

