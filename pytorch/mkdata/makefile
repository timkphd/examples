data: rcs inorm stuff

rcs: less.f90
	gfortran -L/Users/tkaiser2/lapack-3.12.0 -llapack -lrefblas -O4 less.f90 -o rcs
	
inorm: inorm.f90
	gfortran inorm.f90 -o inorm

stuff: 
	python noise.py
	

nminst:
	rm -rf data/rcsout.norm ; \
	./inorm ; \
	cd data ; \
	split -b 47040000 rcsout.norm ; \
	cat ../head/train-images-idx3-ubyte.head xaa > train-images-idx3-ubyte ; \
	cat ../head/t10k-images-idx3-ubyte.head  xab > t10k-images-idx3-ubyte ; \
	split -b 60000 cfile ; \
	cat ../head/train-labels-idx1-ubyte.head xaa > train-labels-idx1-ubyte ; \
	cat ../head/t10k-labels-idx1-ubyte.head  xab > t10k-labels-idx1-ubyte ; \
	rm xaa xab

clean:
	rm -rf data inorm rcs