#!/usr/bin/env python
#
# This program shows how to use mpi_comm_split
#
import numpy
from numpy import *
import mpi
import sys
import math

#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
#print "after ",len(sys.argv),sys.argv
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numnodes=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numnodes

color=myid % 2
new_comm=mpi.mpi_comm_split(mpi.MPI_COMM_WORLD,color,myid)
new_id=mpi.mpi_comm_rank(new_comm)
new_nodes=mpi.mpi_comm_size(new_comm)
zero_one=-1
if new_id == 0 :
    zero_one=color

zero_one=mpi.mpi_bcast(zero_one,1,mpi.MPI_INT,0,new_comm)
if zero_one == 0 :
    print myid," part of even processor communicator ",new_id

if zero_one == 1 :
    print myid," part of odd processor communicator ",new_id
    
print "old_id=", myid, "new_id=", new_id

mpi.mpi_finalize()
