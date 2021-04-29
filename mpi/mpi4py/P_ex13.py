#!/usr/bin/env python3
#
# This program shows how to use Scatterv.  Each processor gets a
# different amount of data from the root processor.  We use MPI_Gather
# first to tell the root how much data is going to be sent.
#
import numpy
from numpy import *
from mpi4py import MPI
import sys


comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)

mpi_root=0


# Three step process for setting up the call to Scatterv
# Each processor gets different amounts of data in
# the Scatterv
# Step 1
# Here we set up the amount of data each will get.

mysize=2*myid+2

# Step 2
# Send the different numbers of values from each processor to the
# root
#mysize contains the number of values we will send in the scatterv
counts=comm.gather(mysize,root=mpi_root)


if myid != mpi_root:
    displacements=None
    sray=None
else:
# Step 3
# We set up the displacement array.  This says where in our
# final array each processor will get its data.  For the 
# normal simple case this is just a running total of the 
# counts array and thus is optional.  See P_ex08.py for
# usage of the displacements array

    print("counts=",counts)
    displacements=zeros(numprocs,"i")
    displacements[0]=0
    for i in range(1, numprocs):
        displacements[i]=counts[i-1]+displacements[i-1]
    size=0
    for i in range(0, numprocs):
        size=size+counts[i]
    sray=zeros(size,"i")
    for i in range(0, size):
        sray[i]=i

allray=empty(mysize,"i")
comm.Scatterv(sendbuf=[sray, (counts)], recvbuf=[allray, (mysize)], root=mpi_root) 

print(myid,"allrray= ",allray)

MPI.Finalize()
