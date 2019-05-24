#!/opt/python/gcc/2.7.11/bin/python
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
X = np.arange(1, 203, 1)
Y = np.arange(1, 203, 1)
X, Y = np.meshgrid(X, Y)
R = np.sqrt(X**2 + Y**2)
Z = R
dataf=sys.argv[1]
infile=open(dataf,"r")
data=infile.readlines()
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

#plt.show()
plt.savefig(dataf+".png")
