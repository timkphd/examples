CUCOMP  = nvcc -arch=sm_80
CULINK  = mpicc

CUFLAGS = -arch=sm_70
CUFLAGS = 


INCLUDES  = -I/nopt/nrel/apps/compilers/02-23/spack/opt/spack/linux-rocky8-zen2/gcc-10.1.0/nvhpc-23.9-z37vdi3iyrnjnm7r4cqgr774vm6brvrp/Linux_x86_64/23.9/comm_libs/12.2/openmpi4/openmpi-4.1.5/include
LIBRARIES = -L/nopt/nrel/apps/compilers/02-23/spack/opt/spack/linux-rocky8-zen2/gcc-10.1.0/nvhpc-23.9-z37vdi3iyrnjnm7r4cqgr774vm6brvrp/Linux_x86_64/23.9/REDIST/cuda/12.2/targets/x86_64-linux/lib -lcudart


pp_cuda_aware: ping_pong_cuda_aware.o
	OMPI_CC=nvc $(CULINK) $(CUFLAGS) $(LIBRARIES) ping_pong_cuda_aware.o -o pp_cuda_aware

ping_pong_cuda_aware.o: ping_pong_cuda_aware.cu
	$(CUCOMP) $(CUFLAGS) $(INCLUDES) -c ping_pong_cuda_aware.cu

.PHONY: clean

clean:
	rm -f pp_cuda_aware *.o
