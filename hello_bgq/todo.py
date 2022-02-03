#!/usr/bin/env python3
import os
nodes=os.environ['SLURM_NNODES']
try:
    nodes=int(nodes)
except:
    nodes=1

onondes=os.environ['SLURM_CPUS_ON_NODE']
try:
    onnodes=int(onondes)
except:
    onnodes=36

n=nodes*onnodes
f=open("todo","w")
f.write("0\n")
f.write("1\n")
off=str(n//2)
f.write(off+"\n")
f.close()

