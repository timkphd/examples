#!/opt/python/gcc/2.7.11/bin/python
'''
Show all different interpolation methods for imshow
'''

import matplotlib.pyplot as plt
import numpy as np
import sys

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
#methods = [None, 'nearest', 'bilinear']
methods = ['nearest', 'bilinear']
methods = [ 'bilinear']
fname=0
for f in sys.argv[1:] :
	fname=fname+1
	print fname
	grid = np.random.rand(202,202)
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


	#fig, axes = plt.subplots(3, 6, figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	fig, axes = plt.subplots(1, len(methods), figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	if len(methods) > 1:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		for ax, interp_method in zip(axes.flat, methods):
			ax.imshow(grid, interpolation=interp_method)
#			ax.set_title(interp_method)
			atitle="frame%3.3d" % (fname)
			ax.set_title(atitle)
		plt.savefig(input+".png")
	else:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		ax=axes
		interp_method=methods[0]
		ax.imshow(grid, interpolation=interp_method)
#		ax.set_title(interp_method)
		atitle="frame%3.3d" % (fname)
		ax.set_title(atitle)
		plt.savefig(input+".png")
	plt.close()
