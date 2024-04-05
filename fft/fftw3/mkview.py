#!/usr/bin/env python3

'''
# based on https://matplotlib.org/examples/images_contours_and_fields/interpolation_methods.html

The original was designed to Show all different interpolation methods for imshow.

To see this 
 (1) comment out the second "method" line 
 (2) set the grid to 22,22
 (3) run stf_00 with the input st.short
 (4) ./interp.py out_serial
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
methods = [ 'bicubic']
text=True
skipone=False
def plotit(f,fnumber=-100,nxin=64,nyin=64) :
	print(fnumber)
	try:
		dolog=os.environ['LOG']
		if (dolog.find("t") > -1  or dolog.find("T") > -1) :
			dolog=True
		else:
			dolog=False
	except:
		dolog=False
	print("Log=",dolog)
	if text :
		grid = np.random.rand(nxin,nyin)
#		grid = np.random.rand(20,10)
		input=f
		infile=open(input,"r")
		data=infile.readlines()
		#data=infile.read()
		k=0
		j=0
		if(skipone):
			st=1
		else:
			st=0
		"""	
#		for d in data[0:] :
		for d in data[st:] :
			d=d.split()
			print(d)
			print(j,len(d))
			k=0
			for v in d:
				print(j,k,v)
				grid[j][k]=float(v)
				if(dolog): grid[j][k]=np.log10(grid[j][k])
				k=k+1
			j=j+1 
		"""
		lm=-1
		for j in range(0,64):
			for k in range(0,64):
				lm=lm+1
				grid[j][k]=float(data[lm])
				
	else:
		grid=np.fromfile(f, dtype=np.float32)
		print("length=",len(grid))
		grid=grid.reshape((4097, 2196),order="FORTRAN").T
#		grid=grid.reshape((2196,4097),order="FORTRAN").T
		input=f

#	print(grid)
	#fig, axes = plt.subplots(3, 6, figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
	try:
		atitle=os.environ['TITLE']
	except:
		atitle="frame%3.3d" % (fnumber)
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
#ffmpeg -r 10 -f image2 -i l_%03d.png -filter:v "crop=600:600:300:0" -c:v prores_ks -profile:v 3  video.mov
		plt.savefig(input+".png")
#		plt.savefig(atitle+".png")
	plt.close()



if __name__ == '__main__':
	fnumber=0
	try:
		mysize=os.environ['SIZE']
	except:
		mysize="64,64"
	mysize=mysize.split(",")
	nx=int(mysize[0])
	ny=int(mysize[1])
	for f in sys.argv[1:] :
		fnumber=fnumber+1
		plotit(f,fnumber,nx,ny)
