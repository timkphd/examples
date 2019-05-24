default: docol.exe  hello.exe  ppong.exe

docol.exe: docol.F90
	mpixlf90_r -qsmp=omp docol.f90 -o docol.exe
	rm *mod

hello.exe: hello.c
	mpixlc_r -qsmp=omp hello.c -o hello.exe

ppong.exe: ppong.c
	mpixlc_r ppong.c -o ppong.exe

clean:
	rm -rf *mod docol.exe  hello.exe  ppong.exe

stuff: stuff.tgz stuff.zip

stuff.tgz:
	tar -czf stuff.tgz ascript_1970 ascript_s bscript_out.1971 cscript cscript_out.1972 \
		docol.f90 docol.F90 index.html makefile small.py ascript_out.1970 bscript_1971 \
		bscript_s cscript_1972 cscript_s hello.c  ppong.c

stuff.zip:
	zip   -r  stuff.zip ascript_1970 ascript_s bscript_out.1971 cscript cscript_out.1972 \
		docol.f90 docol.F90 index.html makefile small.py ascript_out.1970 bscript_1971 \
		bscript_s cscript_1972 cscript_s hello.c  ppong.c


