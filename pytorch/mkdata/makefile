data: rcs inorm stuff

rcs: less.f90
	gfortran -L/Users/tkaiser/lapack-3.12.1 -llapack -lrefblas -O4 less.f90 -o rcs
	
inorm: inorm.f90
	gfortran inorm.f90 -o inorm

#todo... add more shapes to noise.py
#should be able to go up to 0-9 

stuff: 
	python noise.py
	

mninst:
	rm -rf data/rcsout.norm ; \
	./inorm ; \
	cd data ; \
	split -b 47040000 rcsout.norm ; \
	cat ../head/train-images-idx3-ubyte.head xaa > train-images-idx3-ubyte ; \
	cat ../head/t10k-images-idx3-ubyte.head  xab > t10k-images-idx3-ubyte ; \
	split -b 60000 cfile ; \
	cat ../head/train-labels-idx1-ubyte.head xaa > train-labels-idx1-ubyte ; \
	cat ../head/t10k-labels-idx1-ubyte.head  xab > t10k-labels-idx1-ubyte ; \
	rm xaa xab ; \
	mkdir -p ../../data/MNIST/raw ; \
	cp *ubyte  ../../data/MNIST/raw

clean:
	rm -rf data inorm rcs
