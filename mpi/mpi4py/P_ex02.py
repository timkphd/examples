#!/usr/bin/env python3
# Program shows how to use probe and get_count to find the size
# of an incomming message
import numpy
from numpy import *
from mpi4py import MPI
import sys


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)

# Tag identifies a message
mytag=123

# Process 0 is going to send the data
if myid == 0:
    i=array(([1234,5678]),"i")
    icount=2
    comm.Send([i, MPI.INT], dest=1, tag=mytag)

# Process 1 is going to get the data
if myid == 1:
# We create a status to use int the probe command
    mystat=MPI.Status()
# Call probe to find out about the incoming message
    comm.probe(source=0, tag=mytag, status=mystat)
# We find out how big the incoming message is and allocate space
    icount=mystat.Get_count(MPI.INT)
    print("getting ", icount)
    i=empty((icount),"i")
# We are receiving an array of integers
    comm.Recv([i, MPI.INT], source=0, tag=mytag)
    print("i=",i)

MPI.Finalize()



