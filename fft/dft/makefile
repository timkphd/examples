all: segment  test.dat fft.out

segment: segment.f90
		ifort -mkl $(MKLROOT)/include/mkl_dfti.f90 -Wa -O3 segment.f90 -o segment
		rm -rf *mod

spec: rand.py
	python rand.py > spec

test.dat:	dosig spec
	./dosig < spec

dosig:	dosig.f90
	ifort -O3 dosig.f90 -o dosig
	rm -rf *mod

fft.out: segment test.dat drive.in
	./segment < drive.in

clean:
	rm -rf *mod dosig spec segment test.dat fft.out mkl_fft.tgz *.png


tgz:
	tar -czf mkl_fft.tgz dosig.f90 drive.in imagej_setup index.html makefile \
                 notes rand.py segment.f90 simple.html test.spec tfft.f90 wind.f90 window.f90 mkview.py


