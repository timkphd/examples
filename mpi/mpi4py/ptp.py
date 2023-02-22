#!/usr/bin/env python3
from mpi4py import MPI
from numpy import *
from sys import argv

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
name = MPI.Get_processor_name()
numprocs=comm.Get_size()

second=True
data=None


too=-1
if rank == 0:
    lib=MPI.Get_library_version()
    version=str(MPI.Get_version())
    print("Tasks: ",numprocs)
    print(" MPI Version ",version)
    print("Running MPI libary ",lib)
    if len(argv) > 1:
        print(argv)
        too = int(argv[1])
    else:
        too = numprocs-1
    print("sending our data from 0 to ",too)
too=comm.bcast(too, root=0)

for ucase in [True,False] : 
    if rank == 0:
        if ucase :
            data=array([5678,1234],"i")
            comm.Send([data, 2,MPI.INT],dest=too, tag=10)
        else:
            comm.send(data,dest=too, tag=10)
    elif rank == too:
        if ucase :
            data=empty((2),"i")
            comm.Recv([data, MPI.INT],source=0, tag=10)
        else:
            data=comm.recv(source=0, tag=10)
    print(ucase,rank,name,data)

# from https://mpi4py.readthedocs.io/en/stable/tutorial.html
# This fails for Cray mpi4py with multiple nodes
if second :
    if rank == 0:
        data = {'a': 7, 'b': 3.14}
        comm.send(data, dest=too, tag=11)
        print("second send ",rank,name,data)
    elif rank == too:
        data=comm.recv(source=0, tag=11)
        print("second recv ",rank,name,data)


