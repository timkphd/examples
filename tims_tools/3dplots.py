#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import numpy as np
x=np.zeros(1001)
y=np.zeros(1001)
z=np.zeros(1001)
s=(-1+0j)
for p in range(0,1001):
    v=p/1000.0
    v=v*2
    z[p]=v
    r=s**v
    x[p]=r.real
    y[p]=r.imag


# In[ ]:


get_ipython().run_line_magic('matplotlib', 'notebook')
import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
mpl.rcParams['legend.fontsize'] = 10
fig = plt.figure()
ax = fig.gca(projection='3d')
ax.plot(x, y, z, label='-1**z')
ax.legend()
plt.show()


# In[ ]:


from mpl_toolkits.mplot3d import axes3d
import matplotlib.pyplot as plt

get_ipython().run_line_magic('matplotlib', 'notebook')

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

# load some test data for demonstration and plot a wireframe
X, Y, Z = axes3d.get_test_data(0.1)
ax.plot_wireframe(X, Y, Z, rstride=5, cstride=5)

# rotate the axes and update
for angle in range(0, 360):
    ax.view_init(30, angle)
    plt.draw()
    plt.pause(.001)


# In[ ]:




