HDF=/Users/tkaiser2/local/lib/hdf5/gcc

doq: doq.f90
	gfortran -Wall -I$(HDF)/include -L$(HDF)/lib -lhdf5 -lhdf5_fortran doq.f90 -o doq

clean:
	rm -f quake.h5 doq
	
quake.h5:doq
	./doq

redo: clean doq
	./doq
	
dump: quake.h5
	$(HDF)/bin/h5dump quake.h5
