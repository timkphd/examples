#!/usr/bin/python
import numpy as np
sfile=open("wing.dat","r")
# in pyplot set sym=['.','.','.','.','#','X','0']
sin=sfile.readlines()
x=np.empty(799)
y=np.empty(799)
i=0
for s in sin:
	s=s.split()
	x[i]=float(s[0])
	y[i]=float(s[1])
	i=i+1
m0=open("m0","w")
m1=open("m1","w")
m2=open("m2","w")
m3=open("m3","w")
i=0
matfile=open("output","r")
dat=matfile.readlines()
for d in dat:
	d=int(d)
	print(d,x[i],y[i])
	if( d == 0):myfile=m0
	if (d == 1):myfile=m1
	if (d == 2):myfile=m2
	if (d == 3):myfile=m3
	myfile.write("%g %g\n" %(x[i],y[i]))
	i=i+1
