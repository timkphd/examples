#!/usr/bin/env python
# numpy is required
import numpy
from numpy import *
# mpi4py module
from mpi4py import MPI

# Initialize MPI
comm=MPI.COMM_WORLD

# Get information about this run
numprocs=comm.Get_size()
myid=comm.Get_rank()
name = MPI.Get_processor_name()
lib=MPI.Get_library_version()
version=MPI.Get_version()
version=str(version)
version=version.replace(",",".")
version=version.replace(" ","")

if myid == 0:
	print("Tasks: ",numprocs," MPI Version ",version)
	print("Running MPI libary ",lib)

print("xxxxxx Hello from ",myid," on ",name)

# Shut down MPI
MPI.Finalize()