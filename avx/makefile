SHELL:=/usr/bin/bash

recurse:
	module purge                                ; \
	ml intel-oneapi-compilers          ; \
	ml intel-oneapi-mpi          ; \
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) both

both: ser_man par_man


ser_man: MandelbrotImage.cpp
	icpx    -O3 -xCore-AVX512 -qopt-zmm-usage=high         MandelbrotImage.cpp -o ser_man


par_man: MandelbrotImage.cpp
	export I_MPI_CXX=icpx
	mpiicpc -O3 -xCore-AVX512 -qopt-zmm-usage=high -DDOMPI MandelbrotImage.cpp -o par_man


clean:
	rm -rf ser_man par_man

