CUCOMP  = CC 
CULINK  = cc

CUFLAGS = -gpu=cc90  -cuda -target-accel=nvidia90

LIBRARIES =  -lcudart -lcuda

pp_cuda_aware: ping_pong_cuda_aware.o
	$(CULINK) $(CUFLAGS) $(LIBRARIES) ping_pong_cuda_aware.o -o pp_cuda_aware

ping_pong_cuda_aware.o: ping_pong_cuda_aware.cu
	$(CUCOMP) $(CUFLAGS) $(INCLUDES) -c ping_pong_cuda_aware.cu

.PHONY: clean

clean:
	rm -f pp_cuda_aware *.o

ping_pong_cuda_aware.cu:
	wget https://raw.githubusercontent.com/timkphd/examples/master/mpi/cuda/cuda_aware/ping_pong_cuda_aware.cu
