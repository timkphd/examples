#!/usr/bin/python
'''
Show all different interpolation methods for imshow
'''

import matplotlib.pyplot as plt
import numpy as np
import sys
import os
from math import exp as exp
# from the docs:

# If interpolation is None, default to rc image.interpolation. See also
# the filternorm and filterrad parameters. If interpolation is 'none', then
# no interpolation is performed on the Agg, ps and pdf backends. Other
# backends will fall back to 'nearest'.
#
# http://matplotlib.org/api/pyplot_api.html#matplotlib.pyplot.imshow
#https://matplotlib.org/examples/color/colormaps_reference.html

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
methods = [ 'bilinear']
methods = [ 'none']
fname=0
try:
	sigmoid=os.environ['SIGMOID']
	print(sigmoid)
	sigmoid=float(sigmoid)
except:
	sigmoid=0.0

#   for x in $xs ; do echo $x ; od -v -A n -f -j 8 $x   > $x.d; done
for f in sys.argv[1:] :
	fname=fname+1
	print fname
	grid = np.random.rand(65,65)
	d1=250
	d2=473
#	grid = np.random.rand(d2,d1)
	grid = np.random.rand(d1,d2)
	input=f
	infile=open(input,"r")
	data=infile.readlines()
	k=0
	j=0
	l=0
	t=0
# 	for d in data[1:] :
# 		d=d.split()
# 		j=0
# 		for v in d:
# 			grid[j][k]=float(v)
# 			j=j+1
# 		k=k+1
	for d in data[1:] :
		l=l+1
		d=d.split()
		for v in d:
#			grid[j][k]=float(v)
			grid[k][j]=abs(float(v))
#			grid[k][j]=float(v)
			t=t+1
			j=j+1
#			print(j,k,len(d),l)
			if j == d2:
				j=0
				k=k+1

	ymin=grid.min()
	ymax=grid.max()
	if sigmoid > 0.0:
		print("doing sigmoid ",t,ymin,ymax,grid.min(),grid.max())
		rmax=sigmoid
		rmin=-rmax
		m=(rmax-rmin)/(ymax-ymin)
		b=rmax-m*ymax
#		grid=m*grid+b
#		grid=1.0/(1.0+exp(grid))
		(nx,ny)=grid.shape
		for x in range(0,nx):
			for y in range(0,ny):
				z=grid[x,y]
				grid[x,y]=grid[x,y]*m+b
				if(abs(grid[x,y]) > rmax*1.0000001) :
					print("bonds ",x,y,grid[x,y],z,m,b)
				grid[x,y]=1.0/(1.0+exp(-grid[x,y]))
	else:
		print(t,ymin,ymax)
		
	#fig, axes = plt.subplots(3, 6, figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	try:
		cm=os.environ['CMAP']
	except:
		cm="Greys"
	try:
		atitle=os.environ['TITLE']
	except:
		atitle="Picture"
	cmap=plt.get_cmap(cm)
	fig, axes = plt.subplots(1, len(methods), figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	if len(methods) > 1:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		for ax, interp_method in zip(axes.flat, methods):
			ax.imshow(grid, interpolation=interp_method)
#			ax.set_title(interp_method)
			if len(atitle) == 0 :
				atitle="frame%3.3d" % (fname)
			ax.set_title(atitle)
		plt.savefig(input+".png")
	else:
		fig.subplots_adjust(hspace=0.3, wspace=0.05)
		ax=axes
		interp_method=methods[0]
		ax.imshow(grid, interpolation=interp_method ,cmap=cmap)
#		ax.set_title(interp_method)
		if len(atitle) == 0 :
			atitle="frame%3.3d" % (fname)
		ax.set_title(atitle)
		plt.savefig(input+".png")
	plt.close()
