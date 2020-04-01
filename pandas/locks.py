#!/usr/bin/env python
# Program to show usage of python locks.
# This only allows pmax instances of a 
# particular routine to run.  In this
# case the local program is:
# sleep(5*random())
# In a real case this would be replaced
# with a launch of a another program via
# a system call or a long subroutine.
#
# The file sentinel.txt.lock acts as the
# lock and the file sentinel.txt is where
# we store the number of instances of our
# local program running.

from filelock import Timeout, FileLock
from time import sleep,time
import sys
from random import random
import os

file_path = "sentinel.txt"
lock_path = "sentinel.txt.lock"
#lock = FileLock(lock_path, timeout=0.01)
lock = FileLock(lock_path, timeout=1)
def dc(j,maxloc=1,lable=""):
	trying=True
	while trying :
		try:
			lock.acquire()
			n=0
			try:
				x=open(file_path, "r")
				n=x.read()
				x.close()
				n=n.split()
				n=int(n[0])
			except:
				n=0
			nlast=n
			if verbose: print("open for write",lable)
			x=open(file_path, "w")
			n=n+j
			if(n<0): n=0
			if(n>maxloc): n=maxloc
			if verbose: print(str(n)+" "+lable)
			x.write(str(n)+" "+lable+"\n")
			x.close()
			if verbose: print("release",lable)
			lock.release()
			trying=False
		except:
			if verbose: print("retry",lable)
			sleep(0.1)
	return(nlast,n)
	
nl=0
nb=0
# Maximum number of simultaneous local instances to run.
pmax=1
if len(sys.argv)> 1:
    lable=sys.argv[1]
else:
	lable=str(os.getpid())
for i in range(1,20):
        nlast,nnow=dc(1,pmax,lable)
        if nlast < pmax :
            print("doing local %2d %15.3f %10s %4d" % (i,time(),lable,nlast))
            sleep(5*random())
            nl=nl+1
            nlast,nnow=dc(-1,pmax,lable)
            sleep(5*random())
        else:
            print("local busy  %2d %15.3f %10s %4d" % (i,time(),lable,nlast))
            nb=nb+1
            sleep(1)
        
print(nl,nb)
# Putting tasks in the background like
# this might not work on some platforms.
# You'll need to launch from different 
# terminal windows.
#    rm sentinel.txt*
#    ./locks.py one > one.out &
#    ./locks.py two > two.out &
#    ./locks.py thr > thr.out &
#    sleep 2
#    while true ; do cat sentinel.txt ; sleep 1 ; done
#        OR
#    tail -f sentinel.txt
# Again, the tail command might not work 
# on some platforms.  In any case you'll 
# need to manually kill the tail/while 
# command because it does not quit even 
# after no output is going to the file.
#
# Then to see what happened...
# cat *out | grep local | sort -nk4,4 

