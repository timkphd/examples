#!/usr/bin/env python
# coding: utf-8
#https://docs.scipy.org/doc/scipy/reference/linalg.html
from scipy import linalg
import numpy as np
n=4
a= np.ones([n,n])
d=2
for dig in range(0,n): a[dig,dig]=d
print(a)
ieqj=(d+n-2)/(d*(d+n-2)-(n-1))
inej=-1/(d*(d+n-2)-(n-1))
print(ieqj,inej)
o=linalg.inv(a)
print(o)
p=np.matmul(o,a)
p[abs(p)< 1e-10]=0
print(p)
linalg.eigvals(a)
print(linalg.eigvals(a, homogeneous_eigvals=True))
print(linalg.eig(a, left=True, right=False)[1] )# normalized left eigenvector)
print(linalg.eig(a, left=False, right=True)[1] )# normalized right eigenvector)

