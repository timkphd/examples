SHELL=/usr/bin/bash

recurse:
	ml PrgEnv-nvhpc
	$(MAKE) -f -f $(firstword $(MAKEFILE_LIST)) mstream

mstream: mstream.cu
	CC mstream.cu -o mstream

clean:
	rm -rf strm.00*  mstream  mstream.out  slurm*out gpuinfo `find . -type d | grep "/"`

