#!/opt/intel/intelpython3/bin/python3
import sys
import scipy.stats
from math import sqrt
import numpy as np
global n
global K
global Ex
global Ex2

def add_variable(x):
    global n,K,Ex,Ex2
    if (n == 0):
      K = x
    n = n + 1
    Ex += x - K
    Ex2 += (x - K) * (x - K)

def remove_variable(x):
    global n,K,Ex,Ex2
    n = n - 1
    Ex -= (x - K)
    Ex2 -= (x - K) * (x - K)

def get_meanvalue():
    global n,K,Ex,Ex2
    return K + Ex / n

def get_variance():
#s2 is the variance
#standard deviation, denoted by S is the sqrt of variance
    global n,K,Ex,Ex2
    return (Ex2 - (Ex*Ex)/n) / (n-1)

dat2=""" 2.215E+09
 2.048E+09
 2.247E+09
 2.214E+09
 2.202E+09
 2.142E+09
 2.207E+09
 2.074E+09
 2.093E+09
 2.049E+09
"""

dat1=""" 2.245E+09
 2.0428E+09
 2.235E+09
 2.227E+09
 2.152E+09
 2.232E+09
 2.147E+09
 2.124E+09
 2.193E+09
 2.039E+09
"""

con=98

if(len(sys.argv) > 1) :
	fname=sys.argv[1]
	#f=open(fname,"r")
	#dat1=f.read()
	dat1=np.fromfile(fname,dtype=np.float)

if(len(sys.argv) > 2) :
	fname=sys.argv[3]
	#f=open(fname,"r")
	#dat2=f.read()
	dat2=np.fromfile(fname,dtype=np.float)


T=scipy.stats.t._isf
#dat=dat1.split()
dat=dat1
n=0
K=0
Ex=0.0
Ex2=0.0
for d in dat:
	d=float(d)
	add_variable(d)
m1=get_meanvalue()
s1=get_variance()**(0.5)	
n1=n

#dat=dat2.split()
dat=dat2
n=0
K=0
Ex=0.0
Ex2=0.0
for d in dat:
	d=float(d)
	add_variable(d)
m2=get_meanvalue()
s2=get_variance()**(0.5)	
n2=n

"""
#page 204
m1=4.93
s1=1.14
n1=15
m2=2.64
s2=0.66
n2=10
don't think the book is correct


#page 232 #13
m1=80
s1=5
n1=25
m2=75
s2=3
n2=36

#page 232 #15
m1=12.2
s1=1.1
n1=100
m2=9.1
s2=0.9
n2=200

"""


under=sqrt((s1*s1)/n1+(s2*s2)/n2)
vtop=(s1*s1)/n1+(s2*s2)/n2
vbot1=(((s1*s1)/n1)**2)/(n1-1)
vbot2=(((s2*s2)/n2)**2)/(n2-1)
print(vtop,vbot1,vbot2)
v=(vtop**2)/(vbot1+vbot2)
print("v=",v)


a=(1.0-con/100.0)
print("a=",a)
ao2=a/2.0
ta2=T(ao2,v)
print(ta2,v)
dm=m1-m2
diff=ta2*under
lower=dm-diff
upper=dm+diff
print("diff=",diff)
print("dm=",dm)

print(m1,s1,n1)
print(m2,s2,n2)
print("%#10.4G < u1 - u2 < %#10.4G" % (lower,upper)) 

