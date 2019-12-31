doq: doq.f90
	gfortran -Wall -I/Users/tkaiser/hdf5/include -L/Users/tkaiser/hdf5/lib -lhdf5 -lhdf5_fortran doq.f90 -o doq

clean:
	rm -f quake.h5 doq
	
quake.h5:doq
	./doq

redo: clean doq
	./doq
	
dump: quake.h5
	/Users/tkaiser/hdf5/bin/h5dump quake.h5
