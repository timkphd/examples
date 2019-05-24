#!/bin/env python
'''
Show all different interpolation methods for imshow
'''
 
import matplotlib.pyplot as plt
import numpy as np
import sys
import os

# from the docs:

# If interpolation is None, default to rc image.interpolation. See also
# the filternorm and filterrad parameters. If interpolation is 'none', then
# no interpolation is performed on the Agg, ps and pdf backends. Other
# backends will fall back to 'nearest'.
#
# http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.imshow

cmaps = [
         ('Sequential', [
            'Greys', 'Purples', 'Blues', 'Greens', 'Oranges', 'Reds',
            'YlOrBr', 'YlOrRd', 'OrRd', 'PuRd', 'RdPu', 'BuPu',
            'GnBu', 'PuBu', 'YlGnBu', 'PuBuGn', 'BuGn', 'YlGn']),
         ('Sequential (2)', [
            'binary', 'gist_yarg', 'gist_gray', 'gray', 'bone', 'pink',
            'spring', 'summer', 'autumn', 'winter', 'cool',
            'hot', 'afmhot', 'gist_heat', 'copper']),
         ('Diverging', [
            'PiYG', 'PRGn', 'BrBG', 'PuOr', 'RdGy', 'RdBu',
            'RdYlBu', 'RdYlGn', 'Spectral', 'coolwarm', 'bwr', 'seismic']),
         ('Qualitative', [
            'Pastel1', 'Pastel2', 'Paired', 'Accent',
            'Dark2', 'Set1', 'Set2', 'Set3']),
         ('Miscellaneous', [
            'flag', 'prism', 'ocean', 'gist_earth', 'terrain', 'gist_stern',
            'gnuplot', 'gnuplot2', 'CMRmap', 'cubehelix', 'brg', 'hsv',
            'gist_rainbow', 'rainbow', 'jet', 'nipy_spectral', 'gist_ncar'])]

methods = [None, 'none', 'nearest', 'bilinear', 'bicubic', 'spline16',
           'spline36', 'hanning', 'hamming', 'hermite', 'kaiser', 'quadric',
           'catrom', 'gaussian', 'bessel', 'mitchell', 'sinc', 'lanczos']
#methods = [None, 'nearest', 'bilinear']
methods = ['nearest', 'bilinear']
methods = [ 'none']
fname=0
text=False
for f in sys.argv[1:] :
	fname=fname+1
	print fname
	if text :
		grid = np.random.rand(65,65)
		grid = np.random.rand(20,10)
		input=f
		infile=open(input,"r")
		data=infile.readlines()
		k=0
		for d in data[0:] :
			d=d.split()
			print(d)
			j=0
			for v in d:
				grid[j][k]=float(v)
				j=j+1
			k=k+1
	else:
		grid=np.fromfile(f, dtype=np.float32)
		print "length=",len(grid)
		grid=grid.reshape((4097, 2196),order="FORTRAN").T
#		grid=grid.reshape((2196,4097),order="FORTRAN").T
		input=f

	print(grid)
	#fig, axes = plt.subplots(3, 6, figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	try:
		atitle=os.environ['TITLE']
	except:
		atitle="frame%3.3d" % (fname)
	try:
		cm=os.environ['CMAP']
	except:
		cm=""
	if len(cm) == 0:
		cm="gist_ncar"
	cmap=plt.get_cmap(cm)
	fig, axes = plt.subplots(1, len(methods), figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	if len(methods) > 1:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		for ax, interp_method in zip(axes.flat, methods):
			ax.imshow(grid, interpolation=interp_method)
#			ax.set_title(interp_method)
			ax.set_title(atitle)
		plt.savefig(input+".png")
	else:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		ax=axes
		interp_method=methods[0]
		ax.imshow(grid, interpolation=interp_method,cmap=cmap)
#		ax.set_title(interp_method)
		ax.set_title(atitle)
		plt.savefig(input+".png")
	plt.close()
