#!/usr/bin/env python3
from sys import argv
from os.path import isfile
from os import remove
from pathlib import Path
from time import sleep
from math import sin,cos
#
fname="message"
my_id=int(argv[1])
print(my_id, "starting program")
#
if (my_id == 1):
	sleep(2)
	myval=cos(10.0)
	mf=open(fname,"w")
	mf.write(str(myval))
	mf.close()
else:
	myval=sin(10.0)
	notready=True
	while notready :
		if isfile(fname) :
			notready=False
			sleep(3)
			mf=open(fname,"r")
			message=float(mf.readline())
			mf.close()
			total=myval**2+message**2
		else:
			sleep(5)
	print("           sin(10)**2+cos(10)**2=",total)
	remove(fname)
#
print(my_id, "done with program")

