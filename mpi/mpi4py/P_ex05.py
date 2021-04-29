#!/usr/bin/env python3
#
# This program shows how to use MPI_Scatter and MPI_Gather
# Each processor gets different data from the root processor
# by way of mpi_scatter.  The data is summed and then sent back
# to the root processor using MPI_Gather.  The root processor
# then prints the global sum. 
#
import numpy
from numpy import *
from mpi4py import MPI
from os import environ as env


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)


mpi_root=0

#each processor will get count elements from the root
count=4
# in python we do not need to preallocate the array myray
# we do need to assign a dummy value to the send_ray

# This next section of code is showing a bit of a 
# feature, not really MPI.  For example purposes
# we want to show how to use both the upper and 
# lower case versions of gather.  The choice is 
# determined by the value of the variable "bigg".
# By default bigg is false.  However, if it is 
# set to "True" in you environment this will get
# picked up by mpi task 0 and be sent to the 
# the rest via a bcast.  If you are running bash
# as your shell then export bigg=True will do the
# trick.
bigg=False
if myid == mpi_root:
	bigg=env.get("bigg","")
	print(bigg)
	if len(bigg) > 0 :
		if bigg.find("rue") > -1 :
			bigg=True
		else:
			bigg=False
	if bigg:
		print("doing Gather")
	else:
		print("doing gather")
		
# bcast the choice of using the upper case gather
bigg=comm.bcast(bigg, root=0)


# We are using the uppder cast Scatter so we need
# to make numpy arrays for our data.

send_ray=zeros(0,"d")

# Send different data to each processor stuffed in
# the array
if myid == mpi_root:
	size=count*numprocs;
	send_ray=zeros(size,"d")
	for i in range(0, size):
		send_ray[i]=i
# Do the scatter with each task getting its data in myray
myray=empty(count,"d")
comm.Scatter(send_ray, myray, root=0)

#each processor does a local sum
total=0.0
for i in range(0, count):
	total=total+myray[i]
print("myid=",myid,"total=",total)

bigg=True
#gather back to the root and sum/print
if bigg :
# For the upper case Gather we need to create
# our recv array.
	if(myid == mpi_root):
		back_ray=empty(numprocs,"d")
	else:
		back_ray=None
	comm.Gather(total,back_ray,root=mpi_root)
else:
	back_ray=comm.gather(total,root=mpi_root)

if myid == mpi_root:
    total=0.0
    for i in range(0, numprocs):
        total=total+back_ray[i]
    print("results from all processors=",total)

MPI.Finalize()


