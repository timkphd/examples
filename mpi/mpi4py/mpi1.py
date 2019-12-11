#!/usr/bin/env python
from mpi4py import MPI
# A very simple send/recv example from the page:
# http://mpi4py.scipy.org/docs/usrman/tutorial.html
# See this page for other examples.
#
# Shows auto pickling of data.
comm = MPI.COMM_WORLD
rank = comm.Get_rank()

if rank == 0:
    data = {'a': 7, 'b': 3.14}
    comm.send(data, dest=1, tag=11)
elif rank == 1:
    data = comm.recv(source=0, tag=11)
    print(data)
