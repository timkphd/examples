#!/usr/bin/env python
# coding: utf-8

from scipy import linalg
import numpy as np


n=9


a= np.empty([n,n])
a[1-1,1-1]=0.19e+02
a[2-1,1-1]=-0.19e+02
a[3-1,1-1]=-0.19e+02
a[4-1,1-1]=-0.19e+02
a[5-1,1-1]=-0.19e+02
a[6-1,1-1]=-0.19e+02
a[7-1,1-1]=-0.19e+02
a[8-1,1-1]=-0.19e+02
a[9-1,1-1]=-0.19e+02
a[1-1,2-1]=0.30e+01
a[2-1,2-1]=0.30e+01
a[3-1,2-1]=-0.30e+01
a[4-1,2-1]=-0.30e+01
a[5-1,2-1]=-0.30e+01
a[6-1,2-1]=-0.30e+01
a[7-1,2-1]=-0.30e+01
a[8-1,2-1]=0.30e+01
a[9-1,2-1]=-0.30e+01
a[1-1,3-1]=0.10e+01
a[2-1,3-1]=0.10e+01
a[3-1,3-1]=0.10e+01
a[4-1,3-1]=-0.10e+01
a[5-1,3-1]=-0.10e+01
a[6-1,3-1]=-0.10e+01
a[7-1,3-1]=-0.10e+01
a[8-1,3-1]=-0.10e+01
a[9-1,3-1]=-0.10e+01
a[1-1,4-1]=0.12e+02
a[2-1,4-1]=0.12e+02
a[3-1,4-1]=0.12e+02
a[4-1,4-1]=0.12e+02
a[5-1,4-1]=-0.12e+02
a[6-1,4-1]=-0.12e+02
a[7-1,4-1]=-0.12e+02
a[8-1,4-1]=-0.12e+02
a[9-1,4-1]=-0.12e+02
a[1-1,5-1]=0.10e+01
a[2-1,5-1]=0.10e+01
a[3-1,5-1]=0.10e+01
a[4-1,5-1]=0.10e+01
a[5-1,5-1]=0.10e+01
a[6-1,5-1]=-0.10e+01
a[7-1,5-1]=-0.10e+01
a[8-1,5-1]=-0.10e+01
a[9-1,5-1]=-0.10e+01
a[1-1,6-1]=0.16e+02
a[2-1,6-1]=0.16e+02
a[3-1,6-1]=0.16e+02
a[4-1,6-1]=0.16e+02
a[5-1,6-1]=0.16e+02
a[6-1,6-1]=0.16e+02
a[7-1,6-1]=-0.16e+02
a[8-1,6-1]=-0.16e+02
a[9-1,6-1]=-0.16e+02
a[1-1,7-1]=0.10e+01
a[2-1,7-1]=0.10e+01
a[3-1,7-1]=0.10e+01
a[4-1,7-1]=0.10e+01
a[5-1,7-1]=0.10e+01
a[6-1,7-1]=0.10e+01
a[7-1,7-1]=0.10e+01
a[8-1,7-1]=-0.10e+01
a[9-1,7-1]=-0.10e+01
a[1-1,8-1]=0.30e+01
a[2-1,8-1]=0.30e+01
a[3-1,8-1]=0.30e+01
a[4-1,8-1]=0.30e+01
a[5-1,8-1]=0.30e+01
a[6-1,8-1]=0.30e+01
a[7-1,8-1]=0.30e+01
a[8-1,8-1]=0.30e+01
a[9-1,8-1]=-0.30e+01
a[1-1,9-1]=0.11e+02
a[2-1,9-1]=0.11e+02
a[3-1,9-1]=0.11e+02
a[4-1,9-1]=0.11e+02
a[5-1,9-1]=0.11e+02
a[6-1,9-1]=0.11e+02
a[7-1,9-1]=0.11e+02
a[8-1,9-1]=0.11e+02
a[9-1,9-1]=0.11e+02


b= np.zeros([n])
b[2]=1.0


o=linalg.inv(a)
x=np.matmul(o,b)

res=np.sum(abs(np.matmul(a,x)-b))

print("+++ a +++")
print(a)
print("\n+++ b +++")
print(b)
print("\n+++ x +++")
print(x)
print("\n+++ residual +++")
print(res)


