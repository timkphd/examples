#!/usr/bin/env python
#
# This program shows how to use MPI_Gatherv.  Each processor sends a
# different amount of data to the root processor.  We use MPI_Gather
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
myray=zeros(mysize,"i")
for i in range(0, mysize):
	myray[i]=myid+1

if myid == mpi_root :
    displacements=zeros(numnodes,"i")
else :
    displacements=zeros(0,"i")
#myray[0] contains the number of values we will send in the gatherv
counts=mpi.mpi_gather(myray[0],1,mpi.MPI_INT,1,mpi.MPI_INT, mpi_root,mpi.MPI_COMM_WORLD)

if myid == mpi_root:
    displacements[0]=0
    for i in range(1, numnodes):
        displacements[i]=counts[i-1]+displacements[i-1]
    size=0
    for i in range(0, numnodes):
        size=size+counts[i]


allray=mpi.mpi_gatherv(myray, mysize,mpi.MPI_INT,counts,displacements,mpi.MPI_INT,mpi_root,mpi.MPI_COMM_WORLD)

	                
if myid == mpi_root:
    print "allrray= ",allray

mpi.mpi_finalize()

