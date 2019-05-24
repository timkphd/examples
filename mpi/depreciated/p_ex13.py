#!/usr/bin/env python
#
# This program shows how to use MPI_scatterv.  Each processor gets a
# different amount of data from the root processor.  We use MPI_Gather
# first to tell the root how much data is going to be sent.
#
import numpy
from numpy import *
import mpi
import sys
import random

#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
#print "after ",len(sys.argv),sys.argv

mpi_root=0
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numnodes=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numnodes


mysize=myid+1

#mysize contains the number of values we will send in the scatterv
counts=mpi.mpi_gather(mysize,1,mpi.MPI_INT,1,mpi.MPI_INT, mpi_root,mpi.MPI_COMM_WORLD)

if myid != mpi_root:
    displacements=zeros(0,"i")
    sray=zeros(0,"i")
if myid == mpi_root:
    print "counts=",counts
    displacements=zeros(numnodes,"i")
    displacements[0]=0
    for i in range(1, numnodes):
        displacements[i]=counts[i-1]+displacements[i-1]
    size=0
    for i in range(0, numnodes):
        size=size+counts[i]
    sray=zeros(size,"i")
    for i in range(0, size):
        sray[i]=i


allray=mpi.mpi_scatterv(sray,counts,displacements,mpi.MPI_INT,mysize,mpi.MPI_INT,mpi_root,mpi.MPI_COMM_WORLD)

print myid,"allrray= ",allray

mpi.mpi_finalize()
