all:f_ex01 stc_03 ccalc laser

.SUFFIXES: .html .py

f_ex01: f_ex01.f90
	mpif90 f_ex01.f90 -o f_ex01
	rm fmpi.mod

stc_03: stc_03.c
	mpicc -O3 -lm stc_03.c -o stc_03

ccalc: ccalc.c
	mpicc -DEXTRA -O3 -lm ccalc.c -o ccalc

laser:
	curl https://raw.githubusercontent.com/timkphd/examples/master/r/laser.tgz | tar -xz

clean:
	rm -rf *out out* f_ex01 stc_03 __pycache__ fmpi.mod ccalc laser mpi4py.tgz  $(PO) $(CO) $(FO) HTML *pyc
	
tar: clean HTML
	tar --exclude .svn --exclude CVS --exclude CVSROOT --exclude .DS_Store  -czf mpi4py.tgz *


PS=${wildcard *.py}
PO=${PS:.py=.html}

CS=${wildcard *.c}
CO=${CS:.c=.html}

FS=${wildcard *.f90}
FO=${FS:.f90=.html}

HTML: $(PO) $(CO) $(FO)
	rm -rf HTML
	mkdir HTML
	mv $(PO) $(CO) $(FO) HTML
# could use tree -H if you have it
#	cd HTML ; lshtml | grep -v index.html > index.html
	cd HTML ; /opt/bin/tree -r -H . > index.html
	

# pygmentize comes with the Intel version of Python
%.html: %.py
	pygmentize -f html -O full,style=emacs,linenos=1 -o $@  $<
#	pygmentize -f html -O full,style=emacs,linenos=1 -o $<.html  $<

%.html: %.f90
	pygmentize -f html -O full,style=emacs,linenos=1 -o $@  $<

%.html: %.c
	pygmentize -f html -O full,style=emacs,linenos=1 -o $@  $<


