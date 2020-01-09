#!/usr/bin/env python
BUFSIZE=10000000
BSIZE=7
RCOUNT=10

from time import time as TIMER

# numpy is required
import numpy as np

# mpi4py module
from mpi4py import MPI

from math import log as log
from math import exp as exp
# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
myname= MPI.Get_processor_name()
ver=MPI.Get_library_version()
print(myid,myname,ver,MPI.Wtick())
buffer=np.zeros(BUFSIZE,dtype="a")
tag=1234;
log10=log(10)
total=np.zeros(20)
maxtime=np.zeros(20)
mintime=np.zeros(20)
for isource in range(0,numprocs):
	for ir in range(isource+1,numprocs):
		comm.Barrier()
		if(myid == isource or myid == ir):
			for mysize in range(0,BSIZE+1):
				isize=int(exp(log10*mysize))
				if isize > BUFSIZE : isize=BUFSIZE
				total[mysize]=0
				mintime[mysize]=1e6;
				maxtime[mysize]=0.0;
				for repeat in range(1,RCOUNT+1) :
					if myid == isource :
						st=TIMER()
						comm.Send([buffer[0:isize],MPI.CHAR], dest=ir, tag=1234)
						comm.Recv([buffer[0:isize],MPI.CHAR], source=ir, tag=1234)
						et=TIMER();
						dt=et-st;
						total[mysize]=total[mysize]+dt;
						if(dt > maxtime[mysize]) : maxtime[mysize]=dt
						if(dt < mintime[mysize]) : mintime[mysize]=dt
					if myid == ir :
						comm.Recv([buffer[0:isize],MPI.CHAR], source=isource, tag=1234)
						comm.Send([buffer[0:isize],MPI.CHAR], dest=isource, tag=1234)
		if (myid == isource):
			for mysize in range(0,BSIZE+1):
				isize=int(exp(log10*mysize))
				if isize > BUFSIZE : isize=BUFSIZE
				print('{0:4d} {1:4d} {2:10d} {3:10.4g} {4:10.4g} {5:10.4g} {6:15.1f}'.format(isource,ir,isize,mintime[mysize],total[mysize]/RCOUNT,maxtime[mysize],isize/mintime[mysize]))
MPI.Finalize();




