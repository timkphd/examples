#!/bin/env python
import sys
from pylab import *
import math
#import EasyDialogs
import warnings
import time
import os


import dialogs
def AskFileForOpen(message="file="):
	title = dialogs.input_alert('Enter', message, '', '')
	return title

def AskString(message="input:",default=""):
	prompt=message+": "+default+" "
	fstring=dialogs.input_alert('Enter', message, default, '')
	if(len(fstring)==0):
		fstring=default
	return fstring
	
	
warnings.simplefilter("ignore")

paths=[]
if len(sys.argv) > 1:
	for pathname in sys.argv[1:]:
#		print pathname
		paths.append(pathname)
else:
	pathname=" "
	while pathname:
		pathname = AskFileForOpen(message='File to plot:')
		if pathname:
#			print pathname
			paths.append(pathname)

ip=len(paths)
bottom=" "
side=" "
top=" "
bottom=AskString("bottom label","x axis")
side=AskString("side label","y axis")
top=AskString("title","the title")
#log=AskString("log","none")
log=dialogs.list_dialog("log scale?",["None","X","Y","Both"])
if log is None:
	log="None"
xrange="auto"
yrange="auto"
xrange=AskString("X-range",xrange)
yrange=AskString("Y-range",yrange)
lw=1
lw=AskString("lw","1")
lw=float(lw)


xray={}
yray={}
i=0
for pathname in paths:
	f=open(pathname)
	lines=f.readlines()
	f.close()
	a=[]
	b=[]
	for line in lines:
		try:
			data=line.split()
			x=float(data[0])
			y=float(data[1])
			a.append(x)
			b.append(y)
		except:
			break
	xray[i]=a
	yray[i]=b
	i=i+1



if(log.find("x") > -1 or  log.find("X") > -1 or log.find("both") > -1 or log.find("Both") > -1):
	xscale("log")
if(log.find("y") > -1 or  log.find("Y") > -1 or log.find("both") > -1 or log.find("Both") > -1):
	yscale("log")

leg=[]
leggs=AskFileForOpen("Legend file:")
if(leggs):
	f=open(leggs)
	for p in paths:
		p=f.readline()
		p=p.strip()
		leg.append(p)
else:
	for p in paths:
		p=p.split("/")
		leg.append(p[len(p)-1])
for myplot in range(0,ip):
	plot(xray[myplot], yray[myplot], linewidth=lw)		
if(len(leg) > 0):
	legend(leg,loc=0)
if(xrange != "auto"):
	xrange=xrange.replace(","," ")
	xrange=xrange.replace(":"," ")
	xrange=xrange.strip()
	[xmin,xmax]=xrange.split()
	xmin=float(xmin)
	xmax=float(xmax)
	xlim(xmin,xmax)

if(yrange != "auto"):
	yrange=yrange.replace(","," ")
	yrange=yrange.replace(":"," ")
	yrange=yrange.strip()
	[ymin,ymax]=yrange.split()
	ymin=float(ymin)
	ymax=float(ymax)
	ylim(ymin,ymax)
	
xlabel(bottom)
ylabel(side)
title(top)
grid(True)
x=time.localtime()
stime=("%2.2d%2.2d%2.2d%2.2d%2.2d%2.2d" % (x[0]-2000,x[1],x[2],x[3],x[4],x[5]))
stime=os.getenv("HOME")+"/plots/"+stime+".pdf"
#savefig(stime)
#host=os.getenv("HOSTNAME")
#who=os.getlogin()
#print who+"@"+host+":"+stime
show()

