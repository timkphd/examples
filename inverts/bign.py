#!/usr/bin/env python3
import numpy as np
import sys
from time import time as tyme

def dothreads():
import ctypes
	try:
		mkl_rt = ctypes.CDLL('libmkl_rt.dylib')
	except:
		mkl_rt=None
	if mkl_rt == None:
		try:
			mkl_rt = ctypes.CDLL('libmkl_rt.so')
		except:
			mkl_rt=None
	if mkl_rt != None :
		mkl_set_num_threads = mkl_rt.MKL_Set_Num_Threads
		mkl_get_max_threads = mkl_rt.MKL_Get_Max_Threads
		mkl_set_num_threads(nt)
	else:
		print(mkl_rt)

nt=1
if len(sys.argv) > 1:
	nt=int(sys.argv[1])
dothreads(nt)
size=1000
a=np.zeros([size,size])
a=a+0.1
dia=10.0
for i in range(0,len(a)) :
	for j in range(0,len(a)) :
		if (i == j): a[i,j]=dia
b=np.ones(len(a))
iter=100
st=tyme()

for i in range(0,iter):
	x = np.linalg.solve(a, b)

et=tyme()
#print(x)

print("size= %d  iterations= %d time= %g threads= %d" %(size,iter,et-st,nt))



