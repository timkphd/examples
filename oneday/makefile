all: exe
DIRS=introduction scripts1 scripts2 data tricks libs/fft libs/solvers 

exe:
	-for d in $(DIRS); do (cd $$d; $(MAKE) ); done

clean:
	-for d in $(DIRS); do (cd $$d; $(MAKE) clean ); done

tar:
	-for d in $(DIRS); do (cd $$d; $(MAKE) tar ); done

introduction: force
	cd introduction; make

scripts1: force
	cd scripts1 ; make

scripts2: force
	cd scripts2 ; make

data: force
	cd data; make

fft: force
	cd libs/fft ; make

solvers: force
	cd libs/solvers ; make

tricks: force
	cd tricks ; make
force:
	true

