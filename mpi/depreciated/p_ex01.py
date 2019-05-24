#!/usr/bin/env python
import numpy
from numpy import *
import mpi
import sys

sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)


myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numprocs

tag=1234
source=0
destination=1
count=1
if myid == source:
    buffer=5678
    buffer=array(([5678]),"i")
    mpi.mpi_send(buffer, count, mpi.MPI_INT,destination,tag, mpi.MPI_COMM_WORLD)
    print "processor ",myid," sent ",buffer

if myid == destination:
    buffer=mpi.mpi_recv(count, mpi.MPI_INT,source,tag, mpi.MPI_COMM_WORLD)
    print "processor ",myid," got ",buffer



mpi.mpi_finalize()



