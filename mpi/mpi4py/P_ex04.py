#!/usr/bin/env python3
# Example of using the broadcast commands.
# numpy is required
import numpy
from numpy import *

# mpi4py module
from mpi4py import MPI


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)

source=0
count=4 #not needed

# We have both upper and lower case versions
# of the broadcast commands show here to see
# the differences.

if myid == source:
    buffer2=array(([10,200,3000,40000]),"i")
else:
	buffer2=None
# For the lower case version we get the results
# from the procedure call
buffer=comm.bcast(buffer2, root=0)

print("buffer=",buffer,myid)

if myid == source:
    buffer3=array(['abcd'],"str")
else:
	# The buffers should be the same length
	# lest strange things happen. Here we will 
	# get extra characters, 5678, not overwritten.
	# This would normally be a bug in your program.
	buffer3=array(["1234"],"str")

# For the upper case version we get the results
# returned in a buffer which is an argument to the call
comm.Bcast([buffer3,MPI.CHAR], root=0)

print("buffer3=",buffer3,myid)


MPI.Finalize()
