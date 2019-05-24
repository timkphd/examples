#!/usr/bin/python
'''
Show all different interpolation methods for imshow
'''
 
import matplotlib.pyplot as plt
import numpy as np
import sys


# usage
# ./mkview.py       mpiio_dat_016_0200_0100_0200     200 200
# from the docs:
#
# http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.imshow

methods = [ 'bilinear']
fname=0
text=False
vol=np.fromfile(sys.argv[1], dtype=np.int32)
vol=vol[3:]
nx=100
nz=100
if len(sys.argv) > 2:
	nx=int(sys.argv[2])
	nz=int(sys.argv[3])
frames=len(vol)/(nx*nz)
min=vol[0]
max=vol[-1]

for f in range(0,frames):
	fname=fname+1
	print fname
	if text :
		pass
	else:
		grid=vol[f*nx*nz:(f+1)*nx*nz]
		grid=grid.reshape((nx,nz),order="FORTRAN").T
		print "length=",len(grid)
		print grid[0,0]
		input="out"

	#fig, axes = plt.subplots(3, 6, figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	fig, axes = plt.subplots(1, len(methods), figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	if len(methods) > 1:
		pass
	else:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		ax=axes
		interp_method=methods[0]
		ax.imshow(grid, interpolation=interp_method,vmin=min,vmax=max)
#		ax.set_title(interp_method)
		atitle="slice%3.3d" % (fname)
		ax.set_title(atitle)
		plt.savefig(atitle+".png")
	plt.close()
