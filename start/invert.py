#!/usr/bin/env python3
import numpy as np
import sys
from time import time as tyme
nt=1
if len(sys.argv) > 1:
	nt=int(sys.argv[1])
size=1000
a=np.zeros([size,size])
a=a+0.1
dia=10.0
for i in range(0,len(a)) :
	for j in range(0,len(a)) :
		if (i == j): a[i,j]=dia
#####


b=np.ones(len(a))
iter=100
st=tyme()


for i in range(0,iter):
	x = np.linalg.solve(a, b)

et=tyme()
#print(x)

print("size= %d  iterations= %d time= %g threads= %d" %(size,iter,et-st,nt))



