#!/usr/bin/env python
import numpy
from numpy import *
import mpi
import sys
from time import sleep

sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)

print "hello from python main1   myid= ",myid

port_name=mpi.mpi_open_port(mpi.MPI_INFO_NULL);
print "port=",port_name
client=mpi.mpi_comm_accept(port_name,mpi.MPI_INFO_NULL,0,mpi.MPI_COMM_WORLD)

back=mpi.mpi_recv(1,mpi.MPI_INT,0,5678,client)
print "back=",back
back[0]=back[0]+1
mpi.mpi_send(back,1,mpi.MPI_INT,0,1234,client)

sleep(10)
mpi.mpi_close_port(port_name);
mpi.mpi_comm_disconnect(client);
mpi.mpi_finalize()
