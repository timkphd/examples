#!/usr/bin/env python3
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

# Process 1 is going to get the data
mydestination=1

# Sending a single value each time
count=4
# Do the send and recv a number of times
for k in range(1,4):
	if myid == mysource:
# For the upper case calls we need to send/recv numpy arrays	
		buffer=empty((count),"i")
		for ic in range(0,count):
			buffer[ic]=5678+1000*(ic+1)
# We are sending a integer, count is optional, to mydestination	
		comm.Send([buffer, count,MPI.INT],dest=mydestination, tag=mytag)
		print("Python processor ",myid," sent ",buffer)

	if myid == mydestination:
# We are receiving an integer, size is optional, from mysource	
# For the upper case versions of routines data is returned in a buffer
# Not as the return value for the function
		if(k == 1) : buffer=empty((count),"i")
		comm.Recv([buffer, MPI.INT], source=mysource, tag=mytag)
		print("Python processor ",myid," got ",buffer)

MPI.Finalize()



