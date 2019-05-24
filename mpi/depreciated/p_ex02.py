#!/usr/bin/env python
# Program shows how to use probe and get_count to find the size
# of an incomming message
import numpy
from numpy import *
import mpi

import sys

#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
#print "after ",len(sys.argv),sys.argv

myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numprocs


mytag=123

if myid == 0:
    print "arg_str",sys.argv
    i=array(([1234,5678]),"i")
    icount=2
    mpi.mpi_send(i, icount, mpi.MPI_INT,1,mytag, mpi.MPI_COMM_WORLD)

if myid == 1:
    mpi.mpi_probe(0,mytag,mpi.MPI_COMM_WORLD)
    icount=mpi.mpi_get_count(mpi.MPI_INT)
    print "getting ", icount
    i=mpi.mpi_recv(icount, mpi.MPI_INT,0,mytag, mpi.MPI_COMM_WORLD)
    print "i=",i

mpi.mpi_finalize()



