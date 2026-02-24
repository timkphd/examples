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
import numpy as np
def turb(xp):
    xp=xp+0.05*(np.random.rand(len(xp))-0.5)
    return(xp)
seed(42)
global acell
acell=0
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
	#return(xua,yua,xla,yla)
	return(turb(xua),turb(yua),turb(xla),turb(yla))


# In[ ]:


import numpy as np
def box(dm,dp,dtu,dtl,dnp):
    k=0
    skip=True
    xp=np.empty(79)
    yp=np.empty(79)
    y=0.5
    ns=[21,21,21,20]
    for x in np.linspace(.5,-.5,ns[0]):
         if (not skip): 
             #print(x,y)
             xp[k]=x
             yp[k]=y
             k+=1
         skip=False
    skip=True
    for y in np.linspace(.5,-.5,ns[1]):
        if (not skip): 
            #print(-.5,y)
            xp[k]=x
            yp[k]=y
            k+=1
        skip=False
    skip=True
    for x in np.linspace(-.5,.5,ns[2]):
        if (not skip): 
            #print(x,y)
            xp[k]=x
            yp[k]=y
            k+=1
        skip=False
    skip=True
    for y in np.linspace(-.5,.5,ns[3]):
        if (not skip): 
            #print(x,y)
            xp[k]=x
            yp[k]=y
            k+=1
        skip=False
    #return (xp,yp,[],[])
    return (turb(xp),turb(yp),[],[])


def scatter(dm,dp,dtu,dtl,dnp):
    bins=np.zeros([20,20])
    got=0
    while got < 79 :
        ix=int(np.random.random()*20)
        iy=int(np.random.random()*20)
        if bins[ix,iy]== 0:
            bins[ix,iy]=1
            got+=1
    yp=np.zeros(79)
    xp=np.zeros(79)
    k=0
    for i in range(20):
        for j in range(20):
            if bins[i,j] == 1.0:
                xp[k]=i/19.0-0.5
                yp[k]=j/19.0-0.5
                k+=1
    #return (xp,yp,[],[])
    return (turb(xp),turb(yp),[],[])


def circle(dm,dp,dtu,dtl,dnp):
    yp=np.zeros(79)
    xp=np.zeros(79)
    pi=np.pi
    r=0.5
    dt=2*pi/79
    for i in range(79):
        t=i*dt
        xp[i]=r*np.cos(t)
        yp[i]=r*np.sin(t)
    #return(xp,yp,[],[])
    return(turb(xp),turb(yp),[],[])


# In[ ]:


def doit(cfile):
    bonk=[]
    np=40
    (m,p,tu,tl)=(.02,.4,.15,.15)
    """
    if(len(sys.argv) >= 2):
    	np=int(sys.argv[1])
    if(len(sys.argv) == 6):
    	(m,p,tu,tl)=(float(sys.argv[2]),float(sys.argv[3]),float(sys.argv[4]),float(sys.argv[5]))
    """
    funcs=[foil,box,circle,scatter]
    #xu,yu,xl,yl=foil(m,p,tu,tl,np)
    #xu,yu,xl,yl=box(m,p,tu,tl,np)
    #xu,yu,xl,yl=circle(m,p,tu,tl,np)
    #xu,yu,xl,yl=scatter(m,p,tu,tl,np)
    shape=int(random()*3)
    #shape=acell
    #print(shape)
    #sout=(shape+1)*10
    sout=(shape+1)
    cfile.write(bytes(([sout])))
    #print(shape)
    xu,yu,xl,yl=funcs[shape](m,p,tu,tl,np)

    f=open("wing.dat","w")
    size=1.0/np
    rp=1.0625
    ip=-9.0
    [rp,ip]=[3.987305,  -8.138200]
    [rp,ip]=[8.833554, -2.024160]
    #[rp,ip]=[2.895066, -8.587636]
    #[rp,ip]=[6.615291, -6.194097]
    rpk=int(random()*0.5)+1
    rpk=random()*0.5+1

    #print(rpk)
    [rp,ip]=[rpk,0]
    #[rp,ip]=[4,-2]
    #[rp,ip]=[4,-8]
    #[rp,ip]=[4,-16]

    i=0
    for x in xu:
    	rp=int(random()*4)+1
    	rp=(random()*0.1)+2
    	if(i == 0):
    		size=sqrt((xu[i]-xu[i+1])**2+(yu[i]-yu[i+1])**2)*0.5
    	else:
    		size=sqrt((xu[i]-xu[i-1])**2+(yu[i]-yu[i-1])**2)*0.5
    		size=size*0.5
    # we flip the wing around so that it faces right and center it
    	if shape == 3: size=0.015
    	f.write("%10f %10f %10f  %10f,%10f\n" % (-(xu[i]-0.5),yu[i],size,rp,ip))
    	bonk.append(rp)

    	i=i+1

    i=i-1
    for x in xl:
    	rp=int(random()*4)+1
    	rp=(random()*0.1)+2


    	if(i == 0):
    		pass
    	else:
    		size=sqrt((xl[i]-xl[i-1])**2+(yl[i]-yl[i-1])**2)*0.5
    # we flip the wing around so that it faces right and center it
    		if shape == 3: size=0.015
    		f.write("%10f %10f %10f  %10f,%10f\n" % (-(xl[i]-0.5),yl[i],size,rp,ip))
    		bonk.append(rp)
    	i=i-1
    return(shape)
if True:
    t1=time()
    command="rm -rf data/cells*" ; runit=os.popen(command,"r") ; runit.read()
    command="rm -rf data/rcsout*" ; runit=os.popen(command,"r") ; runit.read()
    command="rm -rf data/cfile*" ; runit=os.popen(command,"r") ; runit.read()
    cfile=open("data/cfile","wb")

    for ijk in range(0,70000):
        acell=ijk
        b=doit(cfile)
        if ((ijk % 100) == 0):
            print(ijk,time()-t1)
        command="./rcs 2>/dev/null" ; runit=os.popen(command,"r") ; myout=runit.read()
        if(myout.find("lap") > -1):print(myout)
        #!(awk '{printf("%3.1f ",$4)}' wing.dat ; echo "") >> data/cells
        #!(awk '{printf("%10.4f ",$1)}' out.dat ; echo "") >> data/rcs
    t2=time()
    cfile.close()
print(t2-t1)

