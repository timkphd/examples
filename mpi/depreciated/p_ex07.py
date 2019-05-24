#!/usr/bin/env python
#
# This program shows how to use MPI_Alltoall.  Each processor
# send/rec a different  random number to/from other processors. 
#
import numpy
from numpy import *
import mpi
import sys
import random

#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
#print "after ",len(sys.argv),sys.argv

myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numnodes=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numnodes



scounts=zeros(numnodes,"i")
rcounts=zeros(numnodes,"i")
sdisp=zeros(numnodes,"i")
rdisp=zeros(numnodes,"i")
random.seed(myid) 

for i in range(0, numnodes):
    scounts[i]=random.randint(1,10)

print "myid=",myid,"scounts=",scounts

rcounts=mpi.mpi_alltoall(scounts,1,mpi.MPI_INT,1,mpi.MPI_INT,mpi.MPI_COMM_WORLD)

print "myid=",myid,"rcounts=",rcounts

mpi.mpi_finalize()
