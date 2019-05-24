#!/curc/sw/python/3.6.5/bin/python3
import os
import sys 
import numpy as np
import time
inv=np.linalg.inv
n=np.ones([5],dtype=int)
n[0]=10
n[1]=20
n[2]=30
n[3]=40
n[4]=100
iargs=len(sys.argv)
if iargs > 6:
	iargs=6
if iargs > 1:
	for i in range(1,iargs):
		try:
			n[i-1]=int(sys.argv[i])
		except:
			n[i-1]=100
size=n[4]
print(n)
ray1=np.ones([size,size])*0.1
for i in range(0,size):
	ray1[i,i]=n[0]
ray2=np.ones([size,size])*0.1
for i in range(0,size):
	ray2[i,i]=n[1]
ray3=np.ones([size,size])*0.1
for i in range(0,size):
	ray3[i,i]=n[2]
ray4=np.ones([size,size])*0.1
for i in range(0,size):
	ray4[i,i]=n[3]

tstart=time.time()
####
t1s=time.time()
over1=inv(ray1)
t1e=time.time()

####
t2s=time.time()
over2=inv(ray2)
t2e=time.time()

####
t3s=time.time()
over3=inv(ray3)
t3e=time.time()

#####
t4s=time.time()
over4=inv(ray4)
t4e=time.time()

print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray1, over1), np.eye(size)),t1s-tstart,t1e-t1s))
print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray2, over2), np.eye(size)),t2s-tstart,t2e-t2s))
print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray3, over3), np.eye(size)),t3s-tstart,t3e-t3s))
print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray4, over4), np.eye(size)),t4s-tstart,t4e-t4s))

