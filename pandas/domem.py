#!/usr/bin/env python3
# module load forge
# ln -s domem.py dompimem.py
# map --profile  srun -n 3  python dompimem.py
# map --export three.json /kfs2/projects/hpcapps/tkaiser/examples_1009/pandas/python3_dompimem_py_3p_1n_2024-05-07_12-37.map
# ./dojson.py three
# plsub.py three.dat 

import os
import sys 
import numpy as np
import time
import  psutil
import gc
def getmem():
    m=psutil.Process(os.getpid()).memory_info().rss / 1024 ** 2
    return m

dompi=False
myid=0
MAXTASK=1
# run as MPI program if mpi is in the name for the executable
# and if mpi4py is found
if sys.argv[0].find("mpi") > -1 :
	dompi=True
	try:
	# Initialize MPI
		from mpi4py import MPI
		comm=MPI.COMM_WORLD
	# What processor am I (what is my rank)?
		myid=comm.Get_rank()
	# How many processors (nPEs) are there?
		numprocs=comm.Get_size()
	# Processor name?
		name = MPI.Get_processor_name()
		print("from ",myid," of ",numprocs," on ",name)
        # How many tasks allocate memory
		if myid == 0 :
			if len(sys.argv) > 1 :
				try:
					MAXTASK=int(sys.argv[1])
				except:
					pass
		MAXTASK=comm.bcast(MAXTASK, root=0)
	except:
		dompi=False

if myid < MAXTASK :
	inv=np.linalg.inv
	rays={}
	size=4000
	bsize=size*size*8
	count=100
	sets=range(0,count)
	diag=range(0,size)
	f="%4d %10.5f %10.4f"
	print(" doing ",count," inverts of size ",size," = ",bsize/(1000*1000)," MB")
	#NOTE: memory_info().rss might not reflect actuall memory usage over time
	print("starting memory ",getmem())
	for i in sets:
		rays[i]=np.ones([size,size])*0.1
		for j in diag:
			rays[i][j,j]=3.14
		t1=time.time()
		over1=inv(rays[i])
		t2=time.time()
		print(f % (i,t2-t1,getmem()))
	
	print("releasing memory")
	for i in sets:
		t1=time.time()
		x=rays.pop(i)
	#either del x arter pop or set rays[i]=None does the trick
		del x
	#    rays[i]=None
		gc.collect()
		t2=time.time()
		print(f % (i,t2-t1,getmem()))
	
	del rays
	del over1
	gc.collect()
	print("memory after release ",getmem())
	
	
	print(" doing ",count," inverts of size ",size)
	rays={}
	for i in sets:
		rays[i]=np.ones([size,size])*0.1
		for j in diag:
			rays[i][j,j]=3.14
		t1=time.time()
		over1=inv(rays[i])
		t2=time.time()
		print(f % (i,t2-t1,getmem()))

if dompi: MPI.Finalize()


