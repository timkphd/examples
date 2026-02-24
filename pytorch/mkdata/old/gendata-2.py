#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import sys
from math import *
from random import random
from random import seed
import matplotlib.pyplot as plt
import os
from time import time
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


# In[ ]:


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
if False:
    t1=time()
    command="rm -rf data/cells*" ; runit=os.popen(command,"r") ; runit.read()
    command="rm -rf data/rcsout*" ; runit=os.popen(command,"r") ; runit.read()
    for ijk in range(0,10):
        b=doit()
        if ((ijk % 100) == 0):
            print(ijk,time()-t1)
        get_ipython().system('./rcs')
        #!(awk '{printf("%3.1f ",$4)}' wing.dat ; echo "") >> data/cells
        #!(awk '{printf("%10.4f ",$1)}' out.dat ; echo "") >> data/rcs
    t2=time()
    print(t2-t1)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:


def douniform(c1,c2,x,y):
    return c1
def dorandom(c1,c2,x,y):
    return int(random()*5)+2
def dolinear(c1,c2,x,y):
    dcdx=(c1-c2)/1.0
    b=c1-0.5*dcdx
    return(x*dcdx+b)
def getcs(top,bot):
    x1=0
    x2=0
    while (x1 == x2):
        z1=(random()*top)+bot
        z2=(random()*top)+bot
        x1=z1
        x2=z2
        #x1=int(z1+bot)
        #x2=int(z2+bot)
        #print(x2,x1)
    if(x2 > x1):
        return(x1,x2)
    return(x2,x1)
func=[dorandom,dolinear,douniform]


# In[ ]:


for i in range(30):
    print(getcs(4,1),int(random()*3))


# In[ ]:


random()


# In[ ]:


#help(random)


# In[ ]:


func=[dorandom,dolinear,douniform]


# In[ ]:


func[2](3,4,0,0)


# In[ ]:


random()*3


# In[ ]:


def do3(cfile):
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
    top=6
    bot=2
    case=int(random()*3)
    #cfile.write(str(case)+"\n")
    cfile.write(bytes([case]))
    #print(case)
    case=func[case]
    (c1,c2)=getcs(top,bot)
    for x in xu:
    	rp=int(random()*4)+1
    	if(i == 0):
    		size=sqrt((xu[i]-xu[i+1])**2+(yu[i]-yu[i+1])**2)*0.5
    	else:
    		size=sqrt((xu[i]-xu[i-1])**2+(yu[i]-yu[i-1])**2)*0.5
    		size=size*0.5

    # we flip the wing around so that it faces right and center it
    	xout=(-(xu[i]-0.5))
    	rp=case(c1,c2,xout,yu[i])
    	f.write("%10f %10f %10f  %10f,%10f\n" % (xout,yu[i],size,rp,ip))
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
    		xout=(-(xu[i]-0.5))
    		rp=case(c1,c2,xout,yl[i])
    		f.write("%10f %10f %10f  %10f,%10f\n" % (xout,yl[i],size,rp,ip))
    		bonk.append(rp)
    	i=i-1
    return(bonk)
from time import time
t1=time()
command="rm -rf data/cells*" ; runit=os.popen(command,"r") ; runit.read()
command="rm -rf data/rcsout*" ; runit=os.popen(command,"r") ; runit.read()
command="rm -rf data/cfile*" ; runit=os.popen(command,"r") ; runit.read()

cfile=open("data/cfile","wb")
for ijk in range(0,10000):
    b=do3(cfile)
    if ((ijk % 100) == 0):
        print(ijk,time()-t1)
    command="./rcs > /dev/null" ; runit=os.popen(command,"r") ; runit.read()
    #!(awk '{printf("%3.1f ",$4)}' wing.dat ; echo "") >> data/cells
    #!(awk '{printf("%10.4f ",$1)}' out.dat ; echo "") >> data/rcs
t2=time()
cfile.close()
print(t2-t1)


# In[ ]:


import numpy as np
import torch
dtype = np.float32
nvals=360
file_path = 'data/rcsout.bin'
numpy_array = np.fromfile(file_path, dtype=dtype)
numpy_array = numpy_array.reshape(nvals,numpy_array.shape[0]//nvals)
numpy_array =numpy_array.T
torch_tensor = torch.from_numpy(numpy_array)


# In[ ]:


if False:
    for ijk in range(20):
        tmin=torch_tensor[ijk].min()
        tmax=torch_tensor[ijk].max()
        dten=-2/(tmax-tmin)
        b=-1-dten*tmax
        wtf=torch_tensor[ijk]*dten+b
        plt.plot(wtf)
        plt.show()


# In[ ]:




