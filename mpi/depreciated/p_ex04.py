#!/usr/bin/env python
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


source=0
count=4;
buffer2=0;

if myid == source:
    buffer2=array(([1,2,3,4]),"i")

buffer=mpi.mpi_bcast(buffer2,count,mpi.MPI_INT,0,mpi.MPI_COMM_WORLD)

print "buffer=",buffer,myid;


myid =  mpi.mpi_finalize()
