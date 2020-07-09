#!/usr/bin/env python3
import pandas as pd
import sys
import numpy as np
import os
sys.path.append("/Users/tkaiser2/bin")
sys.path.append("/home/tkaiser2/bin")
from tymer import *
bins=np.zeros(10)
upper=[1,2,4,8,12,18,24,30,36,1000]
lower=[0,1,2,4,8,12,18,24,30,36]
bins=np.zeros(len(upper))
tymer(["-i","start"])
for infile in sys.stdin:
	infile=infile.strip()
	outfile=infile+"_jobs"
#	if os.path.exists(outfile):
#		os.remove(outfile)
	try:
		jobs=pd.read_pickle(infile+".zip")
		#jobs.to_hdf(outfile, 'jobs')
		#jobs.to_pickle(infile+".zip",protocol=4)
		tjobs=len(jobs)
		print("%15s %12d" %(infile,tjobs))
		for x in range(0,len(upper)) :
			c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x])])
			bins[x]=bins[x]+c
			c=c/tjobs
			print("%5.2f %4d %5d" %(c*100,lower[x],upper[x]))
	except:
		print(infile+" failed")
	tymer(["-i",infile])

tjobs=sum(bins)
bins=bins/tjobs
print("Total Jobs= "+str(tjobs))
for x in range(0,len(upper)) :
	c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x])])
	bins[x]=bins[x]*100.0
	print("%5.2f %4d %5d" %(bins[x],lower[x],upper[x]))

