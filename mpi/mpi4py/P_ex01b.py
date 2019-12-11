#!/usr/bin/env python
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

# Tag identifies a message
mytag=1234

# Process 0 is going to send the data
mysource=0

# Process 1 is going to send the data
mydestination=1

# Sending a single value each time
count=1
# Do the send and recv a number of times
for k in range(1,4):
	if myid == mysource:
# For the upper case calls we need to send/recv numpy arrays	
		buffer=array(['hello '+str(k)], dtype=str)
# We are sending a string, count is optional, to mydestination	
		comm.Send([buffer,count,MPI.CHAR], dest=mydestination, tag=mytag)
		print("Python processor ",myid," sent ",buffer)

	if myid == mydestination:
		if(k == 1) : buffer=array((1), dtype=str)
# We are receiving an string, size is optional, from mysource	
# For the upper case versions of routines data is returned in a buffer
# Not as the return value for the function
		comm.Recv([buffer,MPI.CHAR], source=mysource, tag=mytag)
		print("Python processor ",myid," got ",buffer)

MPI.Finalize()



