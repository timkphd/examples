# module load GCC/5.2.1-at90 
# module load PrgEnv/devtoolset-3

default: fandc bin1 bin2 
all: default t90 t95


fandc: cpart_1.o cpart_2.o main.o simulation.o ftnc_mod.o

.SUFFIXES: f90 f

XLF90=xlf90
XLF95=xlf95 

%.o: %.f90
	gfortran -c $<

fandc: ftnc_mod.o simulation.o cpart_1.o cpart_2.o 
	gfortran main.f90 ftnc_mod.o simulation.o cpart_1.o cpart_2.o -o fandc 

	
fandc.f90: main.f90 simulation.f90 ftnc_mod.f90
	cat ftnc_mod.f90 simulation.f90 main.f90 > fandc.f90


bin1: bin.f90
	gfortran bin.f90 -o bin1

getit.o: getit.c

bin2: binary.f90 getit.o
	gfortran binary.f90 getit.o -o bin2

t90: test1.f90
	$(XLF90) test1.f90 -o t90

t95: test1.f90
	$(XLF95) test1.f90 -o t95

clean:
	rm -rf *.mod *o t95 t90 bin1 bin2 fandc a.out
	
	
backup: 
	tar -czf examples.tgz makefile \
	bin.f90 binary.f90 fandc.f90 ftnc_mod.f90 main.f90 simulation.f90 test1.f90  getit.f90 \
	link.f90 list.f90 ll.f90 \
	cpart_1.c cpart_2.c getit.c \
	dummy index.html \
	results2 results3
	zip   -r examples.zip   makefile \
	bin.f90 binary.f90 fandc.f90 ftnc_mod.f90 main.f90 simulation.f90 test1.f90 getit.f90 \
	link.f90 list.f90 ll.f90 \
	cpart_1.c cpart_2.c getit.c \
	dummy index.html \
	results2 results3 