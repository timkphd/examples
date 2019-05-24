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

#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
#print "after ",len(sys.argv),sys.argv

myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numnodes=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numnodes


mpi_root=0

#each processor will get count elements from the root
count=4
# in python we do not need to preallocate the array myray
# we do need to assign a dummy value to the send_ray
send_ray=zeros(0,"d")
if myid == mpi_root:
    size=count*numnodes;
    send_ray=zeros(size,"d")
    for i in range(0, size):
        send_ray[i]=i

#send different data to each processor
myray= mpi.mpi_scatter(send_ray,count,mpi.MPI_DOUBLE,count,mpi.MPI_DOUBLE,mpi_root,mpi.MPI_COMM_WORLD)

#each processor does a local sum
total=0.0
for i in range(0, count):
	total=total+myray[i]
print "myid=",myid,"total=",total


#gather back to the root and sum/print
back_ray=mpi.mpi_gather(total,1,  mpi.MPI_DOUBLE,1,mpi.MPI_DOUBLE,mpi_root,mpi.MPI_COMM_WORLD)
if myid == mpi_root:
    total=0.0
    for i in range(0, numnodes):
        total=total+back_ray[i]
    print "results from all processors=",total

mpi.mpi_finalize()


