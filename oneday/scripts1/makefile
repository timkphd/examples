all: c_ex00 f_ex00 info_c info_f info_p

c_ex00 : c_ex00.c
	mpicc -o c_ex00 c_ex00.c

f_ex00: f_ex00.f
	mpif90 -o f_ex00 f_ex00.f
	rm -rf fmpi.mod

info_c:
	icc info.c -o info_c

info_f:info.f90
	ifort info.f90 -o info_f

info_p:info.py
	cp info.py info_p
	chmod 700 info_p


clean:
	rm -rf c_ex00 f_ex00 info_c info_f info_p fmpi.mod
	rm -rf n*_* errx8* outx8* mynodes* allmynodes* mio* *mio.mines.edu

tar:
	tar -cf scripts1.tar c_ex00.c  f_ex00.f  info.c  info.f90  info.py  makefile  batch1 batch2 batch0 batch1b

