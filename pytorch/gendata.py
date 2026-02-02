#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import sys
import os
from math import *
from random import random
from random import seed
seed(42)
def foil(m,p,tu,tl,n):
### http://www.aerospaceweb.org/question/airfoils/q0041.shtml ###
### http://en.wikipedia.org/wiki/NACA_airfoil ###
# m The maximum camber in fraction of the chord (airfoil length)
# p The position of the maximum camber in fraction of chord
# t the maximum thickness of the airfoil in fraction of chord
#NACA 2415 <=> foil(.02,.4,.15,.15,100)
	xua=[]
	yua=[]
	xla=[]
	yla=[]
	dx=1.0/(n-1.0)
	for i in range(0,n):
		x=i*dx
		if(x < p):
			yc=(m/(p*p))*(2.0*p*x-x*x)
			ycp=(m/(p*p))*(2.0*p-2.0*x)
		else:
			yc=(m/((1.0-p)**2))*((1.0-2.0*p)+2.0*p*x-x**2)
			ycp=(m/((1.0-p)**2))*(2.0*p-2.0*x)
		ytu=(tu/0.2)*(0.2969*sqrt(x)-0.1260*x-0.3516*x**2+0.2843*x**3-0.1015*x**4)
		ytl=(tl/0.2)*(0.2969*sqrt(x)-0.1260*x-0.3516*x**2+0.2843*x**3-0.1015*x**4)
		theta=atan(ycp)
		xu=x-ytu*sin(theta)
		yu=yc+ytu*cos(theta)
		xl=x+ytl*sin(theta)
		yl=yc-ytl*cos(theta)
		xua.append(xu)
		yua.append(yu)
		xla.append(xl)
		yla.append(yl)
	return(xua,yua,xla,yla)

def doit():
    bonk=[]
    np=40
    (m,p,tu,tl)=(.02,.4,.15,.15)
    """
    if(len(sys.argv) >= 2):
    	np=int(sys.argv[1])
    if(len(sys.argv) == 6):
    	(m,p,tu,tl)=(float(sys.argv[2]),float(sys.argv[3]),float(sys.argv[4]),float(sys.argv[5]))
    """
    xu,yu,xl,yl=foil(m,p,tu,tl,np)
    f=open("wing.dat","w")
    size=1.0/np
    rp=1.0625
    ip=-9.0
    [rp,ip]=[3.987305,  -8.138200]
    [rp,ip]=[8.833554, -2.024160]
    #[rp,ip]=[2.895066, -8.587636]
    #[rp,ip]=[6.615291, -6.194097]
    rpk=int(random()*4)+1
    #print(rpk)
    [rp,ip]=[rpk,0]
    #[rp,ip]=[4,-2]
    #[rp,ip]=[4,-8]
    #[rp,ip]=[4,-16]

    i=0
    for x in xu:
    	rp=int(random()*4)+1
    	if(i == 0):
    		size=sqrt((xu[i]-xu[i+1])**2+(yu[i]-yu[i+1])**2)*0.5
    	else:
    		size=sqrt((xu[i]-xu[i-1])**2+(yu[i]-yu[i-1])**2)*0.5
    		size=size*0.5
    # we flip the wing around so that it faces right and center it
    	f.write("%10f %10f %10f  %10f,%10f\n" % (-(xu[i]-0.5),yu[i],size,rp,ip))
    	bonk.append(rp)

    	i=i+1

    i=i-1
    for x in xl:
    	rp=int(random()*4)+1


    	if(i == 0):
    		pass
    	else:
    		size=sqrt((xl[i]-xl[i-1])**2+(yl[i]-yl[i-1])**2)*0.5
    # we flip the wing around so that it faces right and center it
    		f.write("%10f %10f %10f  %10f,%10f\n" % (-(xl[i]-0.5),yl[i],size,rp,ip))
    		bonk.append(rp)
    	i=i-1
    return(bonk)
from time import time
t1=time()
#get_ipython().system('rm -rf data/cells*')
#get_ipython().system('rm -rf data/rcsout*')
command='rm -rf data/cells*'
xcmd=os.popen(command,"r") ; bonkit=xcmd.read() ; xcmd.close()
command='rm -rf data/rcsout*'
xcmd=os.popen(command,"r") ; bonkit=xcmd.read() ; xcmd.close()

for ijk in range(0,10000):
    b=doit()
    if ((ijk % 100) == 0):
        print(ijk,time()-t1)
    #get_ipython().system('./rcs >/dev/null')
    command='./rcs >/dev/null'
    xcmd=os.popen(command,"r") ; bonkit=xcmd.read() ; xcmd.close()

    #!(awk '{printf("%3.1f ",$4)}' wing.dat ; echo "") >> data/cells
    #!(awk '{printf("%10.4f ",$1)}' out.dat ; echo "") >> data/rcs
t2=time()
print(t2-t1)


# In[ ]:


import numpy as np
import torch
dtype = np.float32
file_path = 'data/rcsout.bin'
numpy_array = np.fromfile(file_path, dtype=dtype)
#numpy_array = numpy_array.reshape(37,numpy_array.shape[0]//37)
numpy_array = numpy_array.reshape(360,numpy_array.shape[0]//360)
torch_tensor = torch.from_numpy(numpy_array)
print(file_path)
print(torch_tensor.size())
print(torch_tensor)

file_path = 'data/cells.bin'
numpy_array = np.fromfile(file_path, dtype=dtype)
#numpy_array = numpy_array.reshape(37,numpy_array.shape[0]//37)
numpy_array = numpy_array.reshape(79,numpy_array.shape[0]//79)
torch_tensor = torch.from_numpy(numpy_array)
print(file_path)
print(torch_tensor.size())
print(torch_tensor)



# In[ ]:


print(torch_tensor)

