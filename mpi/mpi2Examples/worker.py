#!/usr/bin/env python
import numpy
from numpy import *
import mpi
import sys
from time import gmtime, time,sleep


def stamp():
	timeTuple = gmtime(time())[1:6]
	return "%02d%02d%02d%02d%02d" % timeTuple


sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
parent=mpi.mpi_comm_get_parent()
parentSize=mpi.mpi_comm_size(parent)
print "parentSize",parentSize

tod=stamp()
s=sys.argv[1]+"%2.2d" % myid
print "hello from python worker",myid," writing to ",s

x=array([5,3,4,2],'i')
print "starting bcast"
buffer=mpi.mpi_bcast(x,4,mpi.MPI_INT,0,parent)
out = open(s, "w")
out.write(str(buffer))
out.write(tod+"\n")
out.close()

print myid," got ",buffer
junk=mpi.mpi_scatter(x,1,mpi.MPI_INT,1,mpi.MPI_INT,0,parent)
print myid," got scatter ",junk


back=mpi.mpi_recv(1,mpi.MPI_INT,0,1234,parent)
back[0]=back[0]+1
mpi.mpi_send(back,1,mpi.MPI_INT,0,5678,parent)

dummy=myid
final=mpi.mpi_reduce(dummy,1,mpi.MPI_INT,mpi.MPI_SUM,0,parent)

sleep(10)
mpi.mpi_comm_free(parent)
mpi.mpi_finalize()
