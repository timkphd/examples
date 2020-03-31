#!/usr/bin/env python
from filelock import Timeout, FileLock
from time import sleep
import sys
from random import random
import os

file_path = "high_ground.txt"
lock_path = "high_ground.txt.lock"
lock = FileLock(lock_path, timeout=1)
def dc(j,maxloc=1):
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
			#print("open for write")
			x=open(file_path, "w")
			n=n+j
			if(n<0): n=0
			if(n>maxloc): n=maxloc
			print(str(n)+" "+str(os.getpid()))
			x.write(str(n)+" "+str(os.getpid())+"\n")
			x.close()
			#print("release")
			lock.release()
			trying=False
		except:
			#print("fail")
			sleep(1)
	return(nlast,n)
	
nl=0
nb=0
for i in range(1,20):
        nlast,nnow=dc(1,1)
        if nlast < 1 :
            print("doing local",i)
            sleep(5*random())
            nl=nl+1
            nlast,nnow=dc(-1,1)
            sleep(5*random())
        else:
            print("local busy",i)
            nb=nb+1
            sleep(1)
        
print(nl,nb)
#    ./locks.py > one.out &
#    ./locks.py > two.out &
#    ./locks.py > thr.out &

