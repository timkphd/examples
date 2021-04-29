#!/usr/bin/env python3
#This is a simple isend/irecv program in MPI

# numpy is required
import numpy
from numpy import *

# mpi4py module
from mpi4py import MPI
import sys


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)

# Set up source, destination, tag, & count
mytag=1234
mysource=0
destination=1
count=1

# isend/Isend nad irecv/Irecv return a request.
# The request can be queried to determine when
# the call completes.

if myid == mysource:
# Recall that the upper case versions of calls
# work with numpy arrays.  The lower case versions
# pickel the data before sending.
	buffer=empty(1,"i")
	buffer[0]=5678
	#Isend(self, buf, int dest, int tag=0)
	#isend(self, obj, int dest, int tag=0)
	req=comm.Isend([buffer,MPI.INT], dest=destination, tag=mytag)

if myid == destination:
	buffer=empty(1,"i")
	#irecv(self, buf=None, int source=ANY_SOURCE, int tag=ANY_TAG)
	#Irecv(self, buf, int source=ANY_SOURCE, int tag=ANY_TAG)
# Here we get our request for the recv
# Note the upper case version of the call needs a buffer
	req=comm.Irecv(buffer,source=mysource,tag=mytag)

if myid == mysource:
	req.wait()
	print("processor ",mysource," sent ",buffer)
	
if myid == destination:
# For the upper case version of the call data is returned
# in a preallocated buffer.

	#buffer=req.wait()
	req.wait()
	print("processor ",destination," got ",buffer)
	
	

MPI.Finalize()



