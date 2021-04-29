#!/usr/bin/env python3
#
# This program shows how to use mpi_comm_split
#
import numpy
from numpy import *
from mpi4py import MPI
import sys

def myquit(mes):
        MPI.Finalize()
        print(mes)
        sys.exit()



comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)

# Map colors to integers
col_to_int={'blue  ': 0, 'green ': 1, 'red   ': 2, 'yellow': 3}

# Reverse col_index ot give integers to colors
index_to_color= {v: k for k, v in col_to_int.items()}

if(myid == 0) :
	print("color to integer=",col_to_int," and ","integer to color=",index_to_color)


# select_val is either     0     or   1     depending odd/even value of myid
select_val=myid % 2

# color_str is either      red   or   green depending odd/even value of 
# select_val, that is myid
color_str=index_to_color[select_val]

# Get an integer representation of our color Note: this will be the same at select_val
color=col_to_int[color_str]

print("myid= %d    color integer = %d     color name = %s" %(myid,color,color_str))

#MPI.Finalize()
#exit()

# Split will create a set of communicators.  All of the
# tasks with the same value of color will be in the same
# communicator.  In this case we get two sets one for 
# odd tasks and one for even tasks.  Note they have the
# same name on all tasks, new_comm, but there are actually
# two different values (sets of tasks) in each one.

new_comm=comm.Split(color,myid)
# Get the new id and number of tasks in the communicator
new_id=new_comm.Get_rank()
new_nodes=new_comm.Get_size()


# Here we do a bcast from the new roots to show we can use the communicator

bcast_val=None
if new_id == 0 : bcast_val=myid

bcast_val=new_comm.bcast(bcast_val)

# Iterate through the colors and each processor will print its information
for k in col_to_int.keys():
	if( k == color_str):
		print("new id is %d in the %s communicator or %d.%s \
original id is %d  \
id bcast from root %d" %(new_id,k,new_id,k,myid,bcast_val))


MPI.Finalize()

