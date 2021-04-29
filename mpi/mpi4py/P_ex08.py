#!/usr/bin/env python3
#
# This program shows how to use MPI_Gatherv.  Each processor sends a
# different amount of data to the root processor.  We use MPI_Gather
# first to tell the root how much data is going to be sent.
#
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


mpi_root=0

# Three step process for setting up the call to Gatherv
# Each processor sends different amounts of data in
# the Gatherv
# Step 1
# Here we set up the amount of data each will send.
mysize=2*myid+2
myray=zeros(mysize,"i")
for i in range(0, mysize):
	myray[i]=myid+1
print(myid,myray)


# Step 2
# Send the different numbers of values from each processor to the
# root
# mysize contains the number of values we will send in the gatherv
counts=comm.gather(mysize,root=mpi_root)
# counts will only be defined on the root, None elsewhere
print(myid,counts)


if myid == mpi_root :
    displacements=zeros(numprocs,"i")
else :
    displacements=zeros(0,"i")

# Step 3
# We set up the displacement array.  This says where in our
# final array each processor will put its data.  For the 
# normal simple case this is just a running total of the 
# counts array

if myid == mpi_root:
    displacements[0]=0
    for i in range(1, numprocs):
        displacements[i]=counts[i-1]+displacements[i-1]
    size=0
    for i in range(0, numprocs):
        size=size+counts[i]
#myquit("almost")
allray=empty(sum(counts),"i")

# Here we need to includ the counts and displacements array 
comm.Gatherv(sendbuf=[myray, MPI.INT], recvbuf=[allray, (counts,displacements), MPI.INT], root=mpi_root) 

	                
if myid == mpi_root:
    print("allrray= ",allray)

MPI.Finalize()

