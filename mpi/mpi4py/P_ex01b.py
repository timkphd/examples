#!/usr/bin/env python3
# numpy is required
import numpy
from numpy import *

# mpi4py module
from mpi4py import MPI

def utf8len(s):
    return len(s.encode('utf-8'))

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
count=18
#count=5
gcount=count
print(utf8len('hello'))
# Do the send and recv a number of times
for k in range(1,4):
	if myid == mysource:
# For the upper case calls we need to send/recv numpy arrays	
		#buffer=array(['hello'], dtype=str)
		buffer=array('hello', dtype=str)
		#buffer='hello'
# We are sending a string, count is optional, to mydestination	
		comm.Send([buffer,count,MPI.CHAR], dest=mydestination, tag=mytag)
		#comm.Send(buffer, dest=mydestination, tag=mytag)
		print("Python processor ",myid," sent ",buffer)

	if myid == mydestination:
		#if(k == 1) : buffer=array(['xxxxx'], dtype=str)
		if(k == 1) : buffer=array('xxxxx', dtype=str)
# We are receiving an string, size is optional, from mysource	
# For the upper case versions of routines data is returned in a buffer
# Not as the return value for the function
		comm.Recv([buffer,gcount,MPI.CHAR], source=mysource, tag=mytag)
		#comm.Recv([buffer], source=mysource, tag=mytag)
		print("Python processor ",myid," got ",buffer)

MPI.Finalize()



