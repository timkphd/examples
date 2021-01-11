#!/usr/bin/env python
# numpy is required
import numpy
from numpy import *

# mpi4py module
from mpi4py import MPI

# Initialize MPI
comm=MPI.COMM_WORLD

# What processor am I (what is my rank)?
myid=comm.Get_rank()

# How many processors (nPEs) are there?
numprocs=comm.Get_size()

# Processor name?
name = MPI.Get_processor_name()

print("Hello from ",myid," on",name," Numprocs is ",numprocs)

print("python is not about snakes")

# Shut down MPI
MPI.Finalize()

