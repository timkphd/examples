#!/usr/bin/env python
#
# This program shows how to use MPI_Scatter and MPI_Gather
# Each processor gets different data from the root processor
# by way of mpi_scatter.  The data is summed and then sent back
# to the root processor using MPI_Gather.  The root processor
# then prints the global sum. 
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

sdisp[0]=0
for i in range(1, numnodes):
	sdisp[i]=scounts[i-1]+sdisp[i-1]

rdisp[0]=0
for i in range(1, numnodes):
	rdisp[i]=rcounts[i-1]+rdisp[i-1]

ssize=0
for i in range(0, numnodes):
    ssize=ssize+scounts[i]

# allocate send array
sray=zeros(ssize,"i")
for i in range(0, ssize):
    sray[i]=myid
# send/rec different amounts of data to/from each processor 
rray= mpi.mpi_alltoallv(sray,scounts,sdisp,mpi.MPI_INT,rcounts,rdisp,mpi.MPI_INT, mpi.MPI_COMM_WORLD)
	                
print "myid= ",myid,"    rray= ",rray

mpi.mpi_finalize()
