#!/usr/bin/env python
# coding: utf-8
import numpy as np
n=3
a=np.ones([n,n*2])
d=2
for dig in range(0,n): a[dig,dig]=d 
a[:,3:]=0
for dig in range(0,n): 
    a[dig,dig+n]=1
print(a)
a[0,:]=a[0,:]/a[0,0]
print(a)
a[1,:]=a[1,:]-a[0,:]*a[1,0]
a[2,:]=a[2,:]-a[0,:]*a[2,0]
print(a)
a[1,:]=a[1,:]/a[1,1]
print(a)
a[0,:]=a[0,:]-a[1,:]*a[0,1]
a[2,:]=a[2,:]-a[1,:]*a[2,1]
print(a)
a[2,:]=a[2,:]/a[2,2]
print(a)
a[0,:]=a[0,:]-a[2,:]*a[0,2]
a[1,:]=a[1,:]-a[2,:]*a[1,2]
print(a)
a[0:3,0:3]
a[0:3,3:]
right=a[0:3,3:]
print(right)
import numpy as np
left=np.ones([n,n])
for dig in range(0,n): left[dig,dig]=d 
print(left)
p=np.matmul(left,right)
p[abs(p)< 1e-10]=0
print(p)


#https://docs.scipy.org/doc/scipy/reference/linalg.html
from scipy import linalg
import numpy as np
n=3
a= np.ones([n,n])
d=2
for dig in range(0,n): a[dig,dig]=d
ieqj=(d+n-2)/(d*(d+n-2)-(n-1))
inej=-1/(d*(d+n-2)-(n-1))
print(ieqj,inej)
# linalg is also in numpy
o=linalg.inv(a)
o
p=np.matmul(o,a)
p[abs(p)< 1e-10]=0
p
linalg.eigvals(a)
print(linalg.eigvals(a, homogeneous_eigvals=True))
print(linalg.eig(a, left=True, right=False)[1] )# normalized left eigenvector)
print(linalg.eig(a, left=False, right=True)[1] )# normalized right eigenvector)
