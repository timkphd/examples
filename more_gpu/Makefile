all:c_ex01  testinput cuda_pg

c_ex01: c_ex01.c
	mpicc c_ex01.c -o c_ex01

testinput: testinput.cu
	nvcc testinput.cu -o testinput

cuda_pg:cuda.cuf
	pgf90  -Mcuda -ta=nvidia -o cuda_pg cuda.cuf -Minfo

clean:
	rm -rf c_ex01 testinput cuda_pg
