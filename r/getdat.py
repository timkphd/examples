#!/usr/bin/env python
# Program to download earthquake data and to 
# split it in to "tasks" more or less equal sized
# files.  "tasks" is taken from the command line
# or defaults to 4.  Our data set should have 
# 634252 lines but we check it anyway.
import requests
import os
import sys
# Here's our data
url = ' http://scedc.caltech.edu/ftp/catalogs/hauksson/Socal_DD/hs_1981_all_comb_K4_A.cat_so_SCSN_v01'
exists = os.path.isfile('start')
if exists:
    print("file exixts")
else:
	print("downloading file")
	r = requests.get(url, allow_redirects=True)
	open('start', 'wb').write(r.content)

# get # of tasks
tasks=4
if(len(sys.argv) > 1):
	tasks=int(sys.argv[1])
	
# count the lines in the file
command="wc -l start"
f=os.popen(command,"r")
out=f.readlines()
out=out[0].split()
lines=int(out[0])
# should be 634252
print(lines == 634252)

# Get a good number of line for each file.
# The last file might be a bit short.
each=lines//tasks
tot=each*tasks
while(tot < lines):
	lines=lines+1
	each=lines//tasks
	tot=each*tasks

# Split the file.
command="split -l X start start"
each=str(each)
command=command.replace("X",each)
print(command)
f=os.popen(command,"r")
out=f.readlines()
