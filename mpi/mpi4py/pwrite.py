#!/usr/bin/env python
import numpy
from numpy import *
from mpi4py import MPI
import sys
#from write_grid import write_extra as doit
from write_grid import plot_extra as doit


world=MPI.COMM_WORLD
numprocs=world.Get_size()
num_used=numprocs-1
old_group=world.Get_group()
will_use=numpy.zeros(num_used,"i")
for ijk in range(0, num_used):
	will_use[ijk]=ijk
new_group=old_group.Incl(will_use)

# create the new communicator
# note: this task may not be in the communicator
comm=world.Create(new_group)

myid=world.Get_rank()
numprocs=world.Get_size()

print("Hello from ",myid," in MPI.COMM_WORLD Numprocs is ",numprocs,)
print("Python is not about snakes.  Part of new group:",(new_group.Get_rank()!= MPI.UNDEFINED))
ip=1
while True:
	nxb=zeros(1,"i")
	nyb=zeros(1,"i")
	world.Bcast(nxb)
	world.Bcast(nyb)
	if nxb[0] == 0 :
		break
	print("ip=",ip)
	doit(nxb[0],nyb[0],world,ip);
	ip=ip+1
	world.barrier()
MPI.Finalize()
