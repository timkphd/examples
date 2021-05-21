#!/usr/bin/env python3
# numpy is required
import numpy
from numpy import *
import sys

# mpi4py module
from mpi4py import MPI


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
name = MPI.Get_processor_name()
print("Python hello from %s # %d of %d" % (name,myid,numprocs))



# Tag identifies a message
mytag=1234

# Process 0 is going to send the data
mysource=0

# Process 1 is going to get the data
mydestination=1

times=zeros(1,"i")
count=zeros(1,"i")
# Do the send and recv a number of times
times[0]=3
# Sending a this many values each time
count[0]=4
# these can be on the command line
#srun -n 2 ./P_ex01.py 3 4


if (myid == 0):
    if len(sys.argv) > 1 :
     times[0]=int(sys.argv[1])   
    if len(sys.argv) > 2 :
     count[0]=int(sys.argv[2])   
comm.Bcast(times)
comm.Bcast(count)
times=times[0]
count=count[0]

for k in range(1,times+1):
	if myid == mysource:
# For the upper case calls we need to send/recv numpy arrays	
		buffer=empty((count),"i")
		for ic in range(0,count):
			buffer[ic]=5678+1000*(ic+1)+k
# We are sending a integer, count is optional, to mydestination	
		for mydestination in range(1,numprocs):
			print("dest",mydestination)
			comm.Send([buffer, count,MPI.INT],dest=mydestination, tag=mytag)
		print("Python processor ",myid," sent ",buffer)

	if myid != mysource:
# We are receiving an integer, size is optional, from mysource	
# For the upper case versions of routines data is returned in a buffer
# Not as the return value for the function
		if(k == 1) : buffer=empty((count),"i")
		comm.Recv([buffer, MPI.INT], source=mysource, tag=mytag)
		print("Python processor ",myid," got ",buffer)

MPI.Finalize()



