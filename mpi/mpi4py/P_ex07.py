#!/usr/bin/env python3
#
# This program shows how to use MPI_Alltoall.  Each processor
# send/rec a different random number to/from other processors. 
#
# numpy is required
import numpy
from numpy import *

# mpi4py module
from mpi4py import MPI
import sys



def myquit(mes):
        MPI.Finalize()
        print(mes)
        sys.exit()


# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)


# We are going to send/recv a single value to/from
# each processor.  Here we allocate arrays
s_vals=zeros(numprocs,"i")
r_vals=zeros(numprocs,"i")

# Fill the send arrays with random numbers

random.seed(myid) 

for i in range(0, numprocs):
    s_vals[i]=random.randint(1,10)

print("myid=",myid,"s_vals=",s_vals)

# Send/recv to/from all
comm.Alltoall(s_vals, r_vals)

print("myid=",myid,"r_vals=",r_vals)

MPI.Finalize()


# Note, the sent values and the recv values are
# like a transpose of each other
#
# mpiexec -n 4 ./P_ex07.py | grep s_v | sort
# myid= 0 s_vals= [6 1 4 4]
# myid= 1 s_vals= [6 9 6 1]
# myid= 2 s_vals= [9 9 7 3]
# myid= 3 s_vals= [9 4 9 9]
# mpiexec -n 4 ./P_ex07.py | grep r_v | sort
# myid= 0 r_vals= [6 6 9 9]
# myid= 1 r_vals= [1 9 9 4]
# myid= 2 r_vals= [4 6 7 9]
# myid= 3 r_vals= [4 1 3 9]
