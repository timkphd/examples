#!/usr/bin/env python3
from mpi4py import MPI
from numpy import *
from sys import argv

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
name = MPI.Get_processor_name()
numprocs=comm.Get_size()

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
if((rank == 0) or (rank == too)) :
    print(rank," is on ",name)

# from https://mpi4py.readthedocs.io/en/stable/tutorial.html
# This fails for Cray mpi4py with multiple nodes
if True:
    if rank == 0:
        data = {'a': 7, 'b': 3.14}
        comm.send(data, dest=too, tag=11)
        print("dictionary send ",rank,name,data)
    elif rank == too:
        data=comm.recv(source=0, tag=11)
        print("dictionary recv ",rank,name,data)


