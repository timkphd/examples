#!/usr/bin/env python
import numpy
from numpy import *
import mpi
import sys
from time import sleep

sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)

print "hello from python main0   myid= ",myid

port_name=input("port_name>")
print "port=",port_name
server=mpi.mpi_comm_connect(port_name,mpi.MPI_INFO_NULL,0,mpi.MPI_COMM_WORLD)

back=array([100],"i")
mpi.mpi_send(back,1,mpi.MPI_INT,0,5678,server)
back=mpi.mpi_recv(1,mpi.MPI_INT,0,1234,server)
print "got back=",back

sleep(10)
mpi.mpi_comm_disconnect(server);
mpi.mpi_finalize()
