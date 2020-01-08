PETSC_DIR=/lustre/eaglefs/scratch/$(USER)/base/petsc-3.12.2

ex16:ex16.c
	mpicc ex16.c -Wall -Wwrite-strings -Wno-strict-aliasing -Wno-unknown-pragmas \
         -fopenmp -fPIC -fstack-protector -fvisibility=hidden -g -O \
         -I$(PETSC_DIR)/include  \
         -I$(PETSC_DIR)/arch-linux-c-opt/include  \
         -Wl,-rpath,$(PETSC_DIR)/arch-linux-c-opt/lib \
         -L$(PETSC_DIR)/arch-linux-c-opt/lib -lpetsc \
         -o ex16

clean:
	rm -rf ex16

tar:
	tar -czf petsc.tgz merge makefile pet02 postit postit.py buildit diff.py ex16.c getmin.py bin pre02
