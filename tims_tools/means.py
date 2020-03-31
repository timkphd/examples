#!/usr/bin/env python3
import sys
import scipy.stats
from math import sqrt
import numpy as np
global n
global K
global Ex
global Ex2

#this excludes negative numbers and 0
def testit(x):
    return(True)
    #return (x > 0.0)

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
#S2 is the variance
#standard deviation, denoted by S is the sqrt of variance
    global n,K,Ex,Ex2
    return (Ex2 - (Ex*Ex)/n) / (n-1)

dat2="""2.215E+09
 2.048E+09
 2.247E+09
 2.214E+09
 2.202E+09
 2.142E+09
 2.207E+09
 2.074E+09
 2.093E+09
 2.049E+09"""

dat1="""2.245E+09
 2.0428E+09
 2.235E+09
 2.227E+09
 2.152E+09
 2.232E+09
 2.147E+09
 2.124E+09
 2.193E+09
 2.039E+09"""

con=98

f1=1
f2=2
bin=False
if(len(sys.argv) > 1) :
	if sys.argv[1]== "-b" :
	    bin=True
	    f1=2
	    f2=3

if(bin):
    if(len(sys.argv) > f1) :
	    fname=sys.argv[f1]
	    dat1=np.fromfile(fname,dtype=np.float)
    if(len(sys.argv) > f2) :
	    fname=sys.argv[f2]
	    dat2=np.fromfile(fname,dtype=np.float)
else:
    if(len(sys.argv) > f1) :
	    fname=sys.argv[f1]
	    f=open(fname,"r")
	    dat1=f.read()
    if(len(sys.argv) > f2) :
	    fname=sys.argv[f2]
	    f=open(fname,"r")
	    dat2=f.read()


T=scipy.stats.t._isf
if not bin : 
    dat=dat1.split("\n")
else:
    dat=dat1
n=0
K=0
Ex=0.0
Ex2=0.0
max1=-1e37
min1=1e37
for d in dat:
	d=float(d)
	if testit(d): 
	    if d < min1: min1=d
	    if d > max1: max1=d
	    add_variable(d)
m1=get_meanvalue()
s1=get_variance()**(0.5)	
n1=n

if not bin:
    dat=dat2.split("\n")
else:
    dat=dat2
n=0
K=0
Ex=0.0
Ex2=0.0
max2=-1e37
min2=1e37
for d in dat:
	d=float(d)
	if testit(d) :
	    if d < min2: min2=d
	    if d > max2: max2=d
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
#print(vtop,vbot1,vbot2)
v=(vtop**2)/(vbot1+vbot2)
#print("v=",v)

 
a=(1.0-con/100.0)
#print("a=",a)
ao2=a/2.0
ta2=T(ao2,v)
#print(ta2,v)
dm=m1-m2
diff=ta2*under
lower=dm-diff
upper=dm+diff
#print("diff=",diff)
#print("dm=",dm)
print("    min        mu         max        std             #   diff/ave")
print("%#10.4G %#10.4G %#10.4G %#10.4G %#10d %#10.4G  X" % (min1,m1,max1,s1**2,n1,abs(diff/m1)))
print("%#10.4G %#10.4G %#10.4G %#10.4G %#10d %#10.4G  Y" % (min2,m2,max2,s2**2,n2,abs(diff/m2)))

print("%#5.1F%s confidence interval for difference in means" %(float(con),"%"))

mycase="=="
if lower > 0: mycase="U1"
if lower < 0 and upper < 0 : mycase="U2"

print("        %#10.4G < u1 - u2 < %#10.4G     %s" % (lower,upper,mycase)) 

print()
d0=0
print("d0= %#10.4G" %(d0))
print("H0a:  m1 - m2  = %#10.4G" % (d0))
print("H1a:  m1 - m2  < %#10.4G" % (d0))
ta=T(a,v)
tp=((m1-m2)-d0)/sqrt((s1**2)/n1 + (s2**2)/n2)
if (tp < -ta): 
    print("Reject H0a at the %#10.4G level of significance" % (a))
else:
    print("Do not reject H0a at the %#10.4G level of significance" % (a))

print()
print("H0b:  m1 - m2  = %#10.4G" % (d0))
print("H1b:  m1 - m2  > %#10.4G" % (d0))
ta=T(a,v)
tp=((m1-m2)-d0)/sqrt((s1**2)/n1 + (s2**2)/n2)
if (tp > ta): 
    print("Reject H0b at the %#10.4G level of significance" % (a))
else:
    print("Do not reject H0b at the %#10.4G level of significance" % (a))




