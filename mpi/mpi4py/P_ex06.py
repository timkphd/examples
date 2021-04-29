#!/usr/bin/env python3
#
# This program shows how to use MPI_Scatter and MPI_Reduce
# Each processor gets different data from the root processor
# by way of mpi_scatter.  The data is summed and then sent back
# to the root processor using MPI_Reduce.  The root processor
# then prints the global sum. 
#
import numpy
from numpy import *
from mpi4py import MPI
import sys

# This function just calls Finalize and
# prints out a message.  Good for debugging
def myquit(mes):
        MPI.Finalize()
        print(mes)
        sys.exit()



# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)


mpi_root=0

# Each processor will get count elements from the root
count=4
# We need to preallocate the array myray for the
# upper case version of Scatter
# we do need to assign a dummy value to the send_ray
myray=empty(count,"i")
send_ray=None
if myid == mpi_root:
    size=count*numprocs;
    send_ray=empty(size,"i")
    for i in range(0, size):
        send_ray[i]=i

#send different data to each processor
#Scatter(self, sendbuf, recvbuf, int root=0)
comm.Scatter(send_ray,myray,root=mpi_root)

#each processor does a local sum
total=0
for i in range(0, count):
	total=total+myray[i]
print("myid=",myid,"total=",total)

#reduce  back to the root and print
#reduce(self, sendobj, op=SUM, int root=0)
#Reduce(self, sendbuf, recvbuf, Op op=SUM, int root=0)
if False :
	back_ray=comm.reduce(total)
else:
	back_ray=empty(2,"i")  # Why does this need to be 2?
	                       # Maybe to support the max_loc operation?
	                       # However, MAXLOC does not work?
	comm.Reduce(total,back_ray,op=MPI.SUM,root=mpi_root)
if myid == mpi_root:
    print("results from all processors=",back_ray)


MPI.Finalize()


