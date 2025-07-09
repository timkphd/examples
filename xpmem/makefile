all: xpmem_master xpmem_proc2 xpmem_proc1 combined 
ARCH=-march=x86-64

xpmem_master: xpmem_master.c xpmem_test.h
	gcc -I.  -I/nopt/xpmem/include xpmem_master.c -L/nopt/xpmem/lib -lxpmem -o xpmem_master

xpmem_proc2: xpmem_proc2.c   xpmem_test.h
	gcc -I.  -I/nopt/xpmem/include xpmem_proc2.c  -L/nopt/xpmem/lib -lxpmem -o xpmem_proc2

xpmem_proc1: xpmem_proc1.c   xpmem_test.h
	gcc -I.  -I/nopt/xpmem/include xpmem_proc1.c  -L/nopt/xpmem/lib -lxpmem -o xpmem_proc1

combined: combined.c   xpmem_test.h
	cc -I. -I/nopt/xpmem/include -L/nopt/xpmem/lib -lxpmem combined.c -o combined $(ARCH)


clean:
	rm -rf xpmem_master xpmem_proc2 xpmem_proc1 combined

run: all
	./short.sh
#	make clean

tar:
	tar --exclude .git --exclude CVS --exclude .svn --exclude CVSROOT --exclude .DS_Store -czf xpmem.tgz \
	combined.c makefile short.sh xpmem_master.c xpmem_proc1.c xpmem_proc2.c xpmem_test.h 
