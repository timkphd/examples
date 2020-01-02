PETSC_DIR=/scratch/tkaiser2/petsc/3.12.2

ex16:ex16.c
	mpicc  ex16.c -Wall -Wwrite-strings -Wno-strict-aliasing -Wno-unknown-pragmas \
         -fopenmp -fPIC -fstack-protector -fvisibility=hidden -g -O \
         -I$(PETSC_DIR/g)/include -I$(PETSCDIR)/include \
         -Wl,-rpath,$(PETSC_DIR/g)/lib -L$(PETSCDIR)/lib  -lpetsc \
         -o ex16

clean:
	rm -rf ex16

tar:
	tar -czf petsc.tgz merge makefile pet02  postit  postit.py  tymer  buildit diff.py ex16.c getmin.py
