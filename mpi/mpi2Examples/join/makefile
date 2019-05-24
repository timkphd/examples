
ARC=osage
ARC=aun
CC=gcc
MPICC=mpicc
#MPICC=/opt/pgi/linux86-64/2014/mpi/mpich/bin/mpicc
#MPICC=/opt/pgi/osx86-64/2014/mpi/mpich/bin/mpicc
ifeq ($(HOSTNAME),mc2)
 ARC=$(HOSTNAME)
 CC=bgxlc_r
 MPICC=mpixlc_r
 MPICC=/opt/mpich3/3.1.3a/bin/mpicc
endif
ifeq ($(HOSTNAME),mork)
 ARC=$(HOSTNAME)
endif
#MPICC=mpicc

all: server_$(ARC) client_$(ARC) example2_$(ARC) sl_$(ARC) cl_$(ARC)

.$(ARC) : cs3_mpi.c
	$(CC) cs3_mpi.c -o cs3_org.$(ARC)

server_$(ARC) : server_mpi.c
	$(MPICC) server_mpi.c -o server_$(ARC)

client_$(ARC) : client_mpi.c
	$(MPICC) client_mpi.c -o client_$(ARC)

example_$(ARC) : example.c
	$(MPICC) example.c -o example_$(ARC)

sl_$(ARC) : sl.c
	$(MPICC) sl.c -o sl_$(ARC)

cl_$(ARC) : cl.c
	$(MPICC) cl.c -o cl_$(ARC)

example2_$(ARC) : example.c
	$(MPICC) example2.c -o example2_$(ARC)

s2fix_org.$(ARC) : s2fix_mpi.c
	$(CC) s2fix_mpi.c -o s2fix_org.$(ARC)

cs3_mpi.$(ARC) : cs3_mpi.c
	$(MPICC) -DDO_MPI cs3_mpi.c -o cs3_mpi.$(ARC)

s2fix_mpi.$(ARC) : s2fix_mpi.c
	$(MPICC) -DDO_MPI s2fix_mpi.c -o s2fix_mpi.$(ARC)

clean:
	rm -f s2fix_org.$(ARC) cs3_org.$(ARC) server_$(ARC) client_$(ARC)
	rm -f s2fix_mpi.$(ARC) cs3_mpi.$(ARC) sl_$(ARC) cl_$(ARC) example_$(ARC) example2_$(ARC)
	rm -f *.o


