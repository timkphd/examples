#
#  f_laplace2d_acc.f90 c_laplace2d_acc.c 
#  Copyright 2012 NVIDIA Corporation
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

CC       = pgcc
NV       = nvcc
#NV       = pgcc
F90      = pgf90
ACCFLAGS = -acc -ta=nvidia -Minfo=accel -Mpreprocess
CUDAFLAGS= -Mcuda 
BIN =  f_laplace2d_acc c_laplace2d_acc simple_acc
CUD =  f_threads_cuda c_threads_cuda gpucount mult
OMP =  f_laplace2d_omp
all: $(BIN)
cuda: $(CUD)

c_laplace2d_acc: laplace2d.c
	$(CC) $(CCFLAGS) $(ACCFLAGS) -o $@ $<

f_laplace2d_acc: laplace2d.f90
	$(F90) $(CCFLAGS) $(ACCFLAGS) -o $@ $<

simple_acc: simple.f90
	$(F90) $(CCFLAGS) $(ACCFLAGS) -o $@ $<

f_laplace2d_omp: laplace2d.f90
	xlf90_r -qsmp=omp -O4  -o $@ $<

gpucount: gpucount.c
	$(NV) $(CCFLAGS) $(NVFLAGS) -o $@ $<

c_threads_cuda: testinput.cu
	$(NV) $(CCFLAGS) $(NVFLAGS) -o $@ $<

f_threads_cuda: testinput.f90
	$(F90) $(CCFLAGS) $(CUDAFLAGS) -o $@ $<

mult: multi.cu multi_cuda.cu multShare.h 
	nvcc -o mult multi.cu multi_cuda.cu
clean:
	$(RM) -f $(BIN) $(CUD) $(OMP) *out *mod deviceQuery *.o


tgz:
	tar -czf gpu.tgz \
buildit deviceQuery.cpp index.html input laplace2d.c \
laplace2d.f90 MakeFFT Makefile MakeQ multi.cu multi_cuda.cu \
multShare.h power_script simpleCUFFT.cu simple.f90 \
testinput.cu testinput.f90 timer.h 
