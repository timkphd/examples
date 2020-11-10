#!/usr/bin/env python3
BUFSIZE=10737418241
BSIZE=15
RCOUNT=200
TMAX=0.5
repcount=10
import sys

try:
    from time import time_ns as ns
    def TIMER():
        return ns()*1e-9
except:
    from time import time as ts
    def TIMER():
        return ts()

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
#TIMER=MPI.Wtick
t1=TIMER()
t2=TIMER()

print(myid,myname,ver,MPI.Wtick(),t2-t1)
buffer=np.zeros(BUFSIZE,dtype="a")
tag=1234;
step=4
logs=log(step)
total=np.zeros(20)
count=np.zeros(20,dtype="int")
maxtime=np.zeros(20)
mintime=np.zeros(20)

try:
    f=open("BSIZE","r")
    dat=f.readlines()
    BSIZE=int(dat[0])
except:
    pass
print(myid,BSIZE)

if myid == 0:
    print("Times - Seconds for round Trip")
    print("Bandwidth - BS Bytes/Second for round Trip")
    print('{0:4s} {1:4s} {2:10s} {3:10s} {4:10s} {5:10s} {6:15s} {7:7s}'.format("PIDs","PIDr","      Size","     T-min","     T-ave","     T-max"," Best Bandwidth","  Count"))
    
for isource in range(0,numprocs):
	for ir in range(isource+1,numprocs):
		comm.Barrier()
		if(myid == isource or myid == ir):
			total=np.zeros(20)
			count=np.zeros(20,dtype="int")
			maxtime=np.zeros(20)
			mintime=np.zeros(20)
			for mysize in range(0,BSIZE+1):
				isize=round(exp(logs*mysize))
				if isize > BUFSIZE : isize=BUFSIZE
				total[mysize]=0
				mintime[mysize]=1e6;
				maxtime[mysize]=0.0;
				buffer[0]='a'
				for repeat in range(1,RCOUNT+1) :
					if myid == isource :
						#print(total[mysize])
						if total[mysize] > TMAX :
						    buffer[0]='b'
						    #print(buffer[0])
						count[mysize]=count[mysize]+1
						st=TIMER()
						for irep in range(0,repcount):
							comm.Send([buffer[0:isize],MPI.CHAR], dest=ir, tag=1234)
							comm.Recv([buffer[0:isize],MPI.CHAR], source=ir, tag=1234)
						#print("back",buffer[0],buffer[0] == b'b')
						et=TIMER();
						dt=et-st;
						dt=dt/repcount
						total[mysize]=total[mysize]+dt;
						if(dt > maxtime[mysize]) : maxtime[mysize]=dt
						if(dt < mintime[mysize]) : mintime[mysize]=dt
					if myid == ir :
						for irep in range(0,10):
							comm.Recv([buffer[0:isize],MPI.CHAR], source=isource, tag=1234)
							comm.Send([buffer[0:isize],MPI.CHAR], dest=isource, tag=1234)
					if buffer[0] == b'b':
						    #print(myid,"doing break")
						    break
		if (myid == isource):
			for mysize in range(0,BSIZE+1):
				isize=round(exp(logs*mysize))
				if isize > BUFSIZE : isize=BUFSIZE
				print('{0:4d} {1:4d} {2:10d} {3:10.4g} {4:10.4g} {5:10.4g} {6:15.1f} {7:7d}'.format(isource,ir,isize,mintime[mysize],total[mysize]/count[mysize],maxtime[mysize],isize/mintime[mysize],count[mysize]))
MPI.Finalize();




