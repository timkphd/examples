all : impi  cray  gnu  intel dmod

impi: makeimpi
	make -f makeimpi 

cray: makeprgcray
	make -f makeprgcray

gnu: makeprggnu
	make -f makeprggnu

intel: makeprgintel
	make -f makeprgintel

clean:
	make -f makeimpi clean
	make -f makeprgintel clean
	make -f makeprggnu clean
	make -f makeprgcray clean
	make -f make1api clean
	make -f makeopen clean

dmod:
	rm -rf *.o *mod

pp: pp.impi pp.cray pp.gnu pp.intel

pp.impi: makeimpi
	make -f makeimpi pp.impi

pp.cray: makeprgcray
	make -f makeprgcray pp.cray

pp.gnu: makeprggnu
	make -f makeprggnu pp.gnu

pp.intel: makeprgintel
	make -f makeprgintel pp.intel

tar:
	tar -czf runall.tgz \
             cases eagle ecases fhostone.F90 getcore.c make1api Makefile makefile.include \
             makeimpi makeopen makeprgcray makeprggnu makeprgintel maskgenerator.py masks.txt \
             phostone.c post ppong.c readme.md runall runpp subsweep sweep todo.py tymer \
	     scases array

