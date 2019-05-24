#Run the Simple eigenvalue program
run: eigen
	./eigen 3.0 7.0 8 < sort2.in

#Build the Simple eigenvalue program
eigen: eigen.f90 sort.o timer.o
	ifort eigen.f90 sort.o timer.o $(FLAGS) -o eigen
	
#Compressed Row Storage subroutine
sort.o: sort.f90
	ifort -c sort.f90

timer.o: timer.f90
	ifort -c timer.f90

#Compressed Row Storage example program
sorttest: driver.f90 sort.o
	ifort driver.f90 sort.o -o sorttest

#MKL example
example: dexample_sparse_f.f
	ifort dexample_sparse_f.f $(FLAGS) -o example

clean:
	rm -rf sort.o timer.o eigen sorttest example *.mod

rmmod:
	rm -rf *.mod  timer.o sort.o

tar: 
	tar -czf eigen.tgz eigen.f90 sort.f90 timer.f90 script \
	         driver.f90 dexample_sparse_f.f sort2.in makefile notes

FLAGS=-m64  -w -fpp -liomp5 -lpthread -lm -ldl -mkl
