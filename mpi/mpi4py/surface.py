#!/usr/bin/env python
# based on https://matplotlib.org/examples/mplot3d/surface3d_demo.html

from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
import numpy as np
import sys

fig = plt.figure()
ax = fig.gca(projection='3d')
#X = np.arange(-32, 32, 1)
#Y = np.arange(-32, 32, 1)
#X = np.arange(1, 65, 1)
#Y = np.arange(1, 65, 1)
dataf=sys.argv[1]
infile=open(dataf,"r")
data=infile.readlines()
line1=data[0].split()
print(line1)
gs=int(line1[4])+2
X = np.arange(1, gs, 1)
Y = np.arange(1, gs, 1)
X, Y = np.meshgrid(X, Y)
R = np.sqrt(X**2 + Y**2)
Z = R
k=0
for d in data[1:] :
	d=d.split()
	j=0
	for v in d:
		Z[j][k]=float(v)
		j=j+1
	k=k+1


surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.rainbow,
                       linewidth=0, antialiased=False)
#ax.set_zlim(0,256)
ax.set_zlim(0,0.5e8)

ax.zaxis.set_major_locator(LinearLocator(11))
#ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))
ax.zaxis.set_major_formatter(FormatStrFormatter('%3.2e'))

fig.colorbar(surf, shrink=0.5, aspect=5)

#print("doing show - show is synchronous function")
#plt.show()
#print("did show")
plt.savefig(dataf+"_s.png")
