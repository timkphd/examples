#!/usr/bin/env python3
#
# This program shows how to use Alltoallv
# Each processor gets amounts of data from each other processor.
# It is an extension to example P_ex07.py.  In mpi4py the 
# displacement array can be calculated automatically from 
# the rcounts array.  We show how it would be done in 
# "normal" MPI.  See also P_ex08.py for how this can be 
# done
#
# numpy is required
import numpy
from numpy import *

# mpi4py module
from mpi4py import MPI
import sys

def myquit(mes):
        MPI.Finalize()
        print(mes)
        sys.exit()


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)


scounts=zeros(numprocs,"i")
rcounts=zeros(numprocs,"i")
sdisp=zeros(numprocs,"i")
rdisp=zeros(numprocs,"i")

random.seed(myid) 

# The first step is to set the number of
# values each processor will send 

for i in range(0, numprocs):
    scounts[i]=random.randint(1,10)

print("myid=",myid,"scounts=",scounts)

# All processors exchange the counts.  rcounts
# will contain the number of values to be received
# from other processors
comm.Alltoall(scounts, rcounts)


print("myid=",myid,"rcounts=",rcounts)

# We set up the displacement arrays.  On the receive side
# this says where in our final array each processor will 
# put its data.  For the normal simple case this is just 
# a running total of the counts array.  On the send side
# this where we will get the data to be sent form the
# send array.  Note in the simple case the displacement
# arrays are optional.

sdisp[0]=0
for i in range(1, numprocs):
	sdisp[i]=scounts[i-1]+sdisp[i-1]

rdisp[0]=0
rc=rcounts[0]
for i in range(1, numprocs):
	rdisp[i]=rcounts[i-1]+rdisp[i-1]

# We do need to know how much data we are sending so we
# can allocated and fill the sray vector
ssize=0
for i in range(0, numprocs):
    ssize=ssize+scounts[i]

# Allocate send array
sray=zeros(ssize,"i")

# Fill it.
for i in range(0, ssize):
    sray[i]=myid

# We do need to know how much data we are getting so we
# can allocated rray 

rsize=0
for i in range(0, numprocs):
    rsize=rsize+rcounts[i]
rec=empty(rsize,"i")

# send/rec different amounts of data to/from each processor 
# Here we need th scounts and rcounts arrays

comm.Alltoallv(sendbuf=[sray,scounts,MPI.INT], recvbuf=[rec,rcounts,MPI.INT])
	                
print("myid= ",myid,"    rray= ",rec)

MPI.Finalize()
