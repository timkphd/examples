#!/usr/bin/env python3
from mpi4py import MPI
import h5py
import numpy as np
import sys
import os
from time import sleep
from time import time

comm=MPI.COMM_WORLD
rank=comm.Get_rank()
numprocs=comm.Get_size()
myname= MPI.Get_processor_name()
jid=int(os.getenv('SLURM_JOBID',"0"))
sub=int(os.getenv('SUB',"0"))
sub=comm.bcast(sub, root=0)
sub=int(os.getenv('SUB',"0"))
sub=comm.bcast(sub, root=0)
mb=128
#print(rank,myname)
if rank == 0 :
    size="64M"
    count="1"
    icommand="lfs setstripe -S 64M -c -1 CWD"
    for s in sys.argv:
        if s.find("size") > -1 :
             size=s.split("=")[1]
        if s.find("count=") > -1 :
             count=s.split("=")[1]
        if s.find("mb=") > -1 :
             mb=int(s.split("=")[1])
    icommand=icommand.replace('CWD',os.getcwd())
    icommand=icommand.replace('64M',size)
    icommand=icommand.replace('-1',count)
    doit=os.popen(icommand,"r")
    out=doit.read()
    print(out)
    print(icommand,"    file size=",mb," MB")
    sleep(5)
mb=comm.bcast(mb, root=0)
comm.Barrier()    
t=np.full(8,0.0)
t[6]=time()
t[0]=MPI.Wtime()
ilong=1024*1024*mb
rdat=np.full(ilong,rank,dtype=int)
t[1]=MPI.Wtime()
f = h5py.File('parallel_test.hdf5', 'w', driver='mpio', comm=MPI.COMM_WORLD)
t[2]=MPI.Wtime()
dset = f.create_dataset('test', (numprocs,ilong), dtype='i')
t[3]=MPI.Wtime()
dset[rank] = rdat
t[4]=MPI.Wtime()
f.close()
t[5]=MPI.Wtime()
t[7]=time()
fout="times_%2.2d_%7.7d_%2.2d" %(rank,jid,sub)
file=open(fout,"w")
k=0
outline=""
for x in t[1:6] :
     xout="%10.6f," % (x-t[k])
     outline=outline+xout
     k=k+1
xout="%f,%f,%10.6f" % (t[6],t[7],t[7]-t[6])
outline=outline+xout
file.write(outline+"\n")


