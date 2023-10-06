SHELL:=/usr/bin/bash

recurse:
	. /nopt/nrel/apps/csso/env.sh               ; \
	module purge                                ; \
	ml intel-oneapi-compilers/2022.1.0          ; \
	ml intel-oneapi-mpi/2021.8.0-intel          ; \
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) both

both: ser_man par_man


ser_man: MandelbrotImage.cpp
	icpx    -O3 -xCore-AVX512 -qopt-zmm-usage=high         MandelbrotImage.cpp -o ser_man


par_man: MandelbrotImage.cpp
	export I_MPI_CXX=icpx
	mpiicpc -O3 -xCore-AVX512 -qopt-zmm-usage=high -DDOMPI MandelbrotImage.cpp -o par_man


clean:
	rm -rf ser_man par_man

