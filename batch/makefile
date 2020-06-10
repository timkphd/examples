all: c_ex00 f_ex00 info_c info_f info_p fillmem sink helloc hellof hybrid
	rm *o *mod

c_ex00 : c_ex00.c
	mpicc -o c_ex00 c_ex00.c

f_ex00: f_ex00.f
	mpif90 -o f_ex00 f_ex00.f
	rm -rf fmpi.mod

helloc: helloc.c
	mpicc -o helloc helloc.c

hellof: hellof.f
	mpif90 -o hellof hellof.f

hybrid:hybrid.f90
	mpif90 -fopenmp hybrid.f90 -o hybrid	

info_c:
	cc info.c -o info_c

info_f:info.f90
	gfortran info.f90 -o info_f

info_p:info.py
	cp info.py info_p
	chmod 700 info_p

fillmem:pointer.f90
	ifort -O3 -mkl -fopenmp pointer.f90 -o fillmem

clean:
	rm -rf c_ex00 f_ex00 info_c info_f info_p fmpi.mod fillmem *o *mod
	rm -rf n*_* errx8* outx8* mynodes* allmynodes* *.edu
	rm -rf segment sinkf sinkfile sinkfile.o fmpi.mod data.tgz
	rm -rf scripts1.tar *mio.mines.edu* *ra.mines.edu*
	rm -rf helloc hellof hybrid

tar:
	tar -cf scripts1.tar \
	basic c_ex00.c dir docd env1 env2 info.c info.f90 \
	info.py inputenv local makefile  multiwait \
	mymod.f90 nodes notify number pointer.f90 redirect \
	serial sinkf.f90 sinkfile.c sinput1 sinput2 sinput3 \
	sinput4 stdout

sink: segment sinkf sinkfile

sinkf: sinkfile.o sinkf.f90
	mpif90 sinkf.f90 sinkfile.o -o sinkf

sinkfile.o: sinkfile.c
	#mpicc -DDO_LOCAL_FILE_TEST -c sinkfile.c
	mpicc -c sinkfile.c

sinkfile:sinkfile.c
	#mpicc -DDO_LOCAL_FILE_TEST -DDO_C_TEST sinkfile.c -o sinkfile
	mpicc                      -DDO_C_TEST sinkfile.c -o sinkfile

segment:
	od -vAn -d -N1048576 < /dev/urandom > segment
	tar -czf data.tgz segment
	rm -rf segment*

