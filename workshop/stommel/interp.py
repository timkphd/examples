#!/opt/python/gcc/2.7.11/bin/python
'''
Based on the example at:
http://matplotlib.org/examples/images_contours_and_fields/interpolation_methods.html

The original was designed to Show all different interpolation methods for imshow.

To see this 
 (1) comment out the second "method" line 
 (2) set the grid to 22,22
 (3) run stf_00 with the input st.short
 (4) ./interp.py out_serial

Normal run:
 (1) run stf_00 with the input st.in
 (2) ./interp.py out_serial
 

'''

import matplotlib.pyplot as plt
import numpy as np
import sys
import math

def myshape(numnodes) :
	nrow=int(round(math.sqrt(numnodes)))
	ncol=numnodes//nrow
	while  (nrow*ncol != numnodes) :
		nrow=nrow+1
		ncol=numnodes // nrow
	
	if (nrow > ncol) :
		i=ncol
		ncol=nrow
		nrow=i
	return [ncol,nrow]

# from the docs:

# If interpolation is None, default to rc image.interpolation. See also
# the filternorm and filterrad parameters. If interpolation is 'none', then
# no interpolation is performed on the Agg, ps and pdf backends. Other
# backends will fall back to 'nearest'.
#
# http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.imshow

methods = [None, 'none', 'nearest', 'bilinear', 'bicubic', 'spline16',
           'spline36', 'hanning', 'hamming', 'hermite', 'kaiser', 'quadric',
           'catrom', 'gaussian', 'bessel', 'mitchell', 'sinc', 'lanczos']
methods = [ 'bilinear']
fname=0
for f in sys.argv[1:] :
	fname=fname+1
	print fname
	grid = np.random.rand(202,202)
#	grid = np.random.rand(22,22)
	input=f
	infile=open(input,"r")
	data=infile.readlines()
	k=0
	for d in data[1:] :
		d=d.split()
		j=0
		for v in d:
			grid[j][k]=float(v)
			j=j+1
		k=k+1


	if len(methods) > 1:
		i,j=myshape(len(methods))
		fig, axes = plt.subplots(j,i, figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		for ax, interp_method in zip(axes.flat, methods):
			ax.imshow(grid, interpolation=interp_method)
			ax.set_title(interp_method)
#			atitle="frame%3.3d" % (fname)
#			ax.set_title(atitle)
		plt.savefig(input+".png")
	else:
		fig, axes = plt.subplots(1, len(methods), figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		ax=axes
		interp_method=methods[0]
		ax.imshow(grid, interpolation=interp_method)
#		ax.set_title(interp_method)
		atitle="frame%3.3d" % (fname)
		ax.set_title(atitle)
		plt.savefig(input+".png")
	plt.close()
