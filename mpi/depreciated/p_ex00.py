#!/usr/bin/env python
import numpy
from numpy import *
import mpi
from mpi import *
import sys

#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
print "after ",len(sys.argv),sys.argv

myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)

print "Hello from ",myid
print "Numprocs is ",numprocs

print "python is not about snakes"

###print sys.executable,sys.path

mpi.mpi_finalize()

