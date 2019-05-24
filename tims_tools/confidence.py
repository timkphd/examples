#!/usr/bin/python
import sys
import scipy.stats
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
    global n,K,Ex,Ex2
    return (Ex2 - (Ex*Ex)/n) / (n-1)

dat=""" 2.215E+09
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
con=95

if(len(sys.argv) > 1) :
	fname=sys.argv[1]
	f=open(fname,"r")
	dat=f.read()

if(len(sys.argv) > 2) :
	con=float(sys.argv[2])

z={}
z[80]=1.282
z[85]=1.440
z[90]=1.645
z[95]=1.960
z[99]=2.576
z[99.5]=2.807
z[99.9]=3.291

T=scipy.stats.t._isf
dat=dat.split()
n=0
K=0
Ex=0.0
Ex2=0.0
for d in dat:
	d=float(d)
	add_variable(d)
m=get_meanvalue()
s=get_variance()**(0.5)	

#for a in [80,85,90,95,99,99.5,99.9] :
#	dif=z[a]*s/(float(n)**0.5)
#	print("%#10.4G +/- %#8.4G" % (m,dif))

a=(1.0-con/100.0)
ao2=a/2.0
v=n-1
ta2=T(ao2,v)
dif=ta2*s/(float(n)**0.5)
print("The %g%s confidence interval with a sample size of %d is:" %(con,"%",n))
print("%#10.4G +/- %#8.4G" % (m,dif))
outstr="%#10.4G <mu< %#10.4G" % (m-dif,m+dif)
outstr=outstr.replace(" ","")
outstr=outstr.replace("<"," < ")
print(outstr)

