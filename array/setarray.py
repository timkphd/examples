#!/usr/bin/python
import os
import sys
import random
size=int(sys.argv[1])
# make list of inputs
l=open("in_list","w")
for x in range(0,size):
	n1=int(random.random()*100)+1
	n2=int(random.random()*100)+1
	n3=int(random.random()*100)+1
	n4=int(random.random()*100)+1
	n5=400
	l.write("%d %d %d %d %d\n" % (n1,n2,n3,n4,n5))
l.close()
l=open("dir_list","w")
os.mkdir("inputs",0755)
os.chdir("inputs")
for x in range(0,size):
	x=x+1
	n1=int(random.random()*100)+1
	n2=int(random.random()*100)+1
	n3=int(random.random()*100)+1
	n4=int(random.random()*100)+1
	n5=200
	newdir="set"+str("%3.3d" % x)
	l.write(newdir+"\n")
	os.mkdir(newdir,0755)
	os.chdir(newdir)
	f=open("myinput","w")
	f.write("%d %d %d %d %d\n" % (n1,n2,n3,n4,n5))
	f.close()
	os.chdir("..")




	
