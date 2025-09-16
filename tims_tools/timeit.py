#!/usr/bin/env python3
#### watch -n 10 ./timeit.py 3 | tee speed
import time
from subprocess import run
from random import random
import sys
sites=[]
sites.append("https://www.python.org/ftp/python/3.13.7/Python-3.13.7.tgz")
sites.append("https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.8.tar.gz")
sites.append("https://www.mpich.org/static/downloads/4.3.1/mpich-4.3.1.tar.gz")
#sites.append("https://bigsearcher.com/mirrors/gcc/releases/gcc-11.1.0/gcc-11.1.0.tar.xz")
#sites.append("https://julialang-s3.julialang.org/bin/linux/x64/1.11/julia-1.11.7-linux-x86_64.tar.gz")
if len(sys.argv) > 1:
	nc=int(sys.argv[1])
else:
	nc=1
	
for c in range(0,nc):
	if nc == len(sites):
		select=c
	else:
		select=int(random()*len(sites))
	command="wget --no-check-certificate "+sites[select]+" -O /dev/null"
	#print(select)
	#print(command)
	t1=time.time()
	data = run(command, capture_output=True, shell=True, text=True)
	t2=time.time()
	stderr=data.stderr.split("\n")
	#print(stderr)
	z=0
	for x in stderr:
		if x.find("saved") > -1 :
				z=x.split("[")
				z=z[-1].split("/")
				z=int(z[0])
	dt=t2-t1
	rate=z/dt
	print("%15i %9.3f %s" %(z,rate/1e6,time.asctime()))        

