#!/usr/bin/env python3
import sys
import os
import pickle
print("hello")
infile=sys.argv[1]
fin=open(infile,"r")
x=fin.readlines()
fin.close()
domod=False
doenv=False
if infile.find("mod") > -1:
	domod=True
if infile.find("env") > -1:
	doenv=True
if len(sys.argv) > 2:
	arg2=sys.argv[2]
	if arg2.find("-e") > -1:
		doenv=True
	if arg2.find("-m") > -1:
		domod=True
	
if doenv:	
	indef=False
	dic={}
	k=0
	brac=0
	for n in x:
		if brac > 0 :
			v=v+n
			brac=v.count("{")-v.count("}")
			if brac == 0: 
				d=d.encode('utf-8')
				v=v.strip()
				v=v.encode('utf-8')
				dic[d]=v
				#print(d,v)
			continue
		if (n.find("=()") > -1 ):
			d,v=n.split("=",1)
			brac=brac+v.count("{")-v.count("}")
			if brac == 0:
				d=d.encode('utf-8')
				v=v.strip()
				v=v.encode('utf-8')
				dic[d]=v
				#print(d,v)
			continue
		d,v=n.split("=",1)
		d=d.encode('utf-8')
		v=v.strip()
		dic[d]=v.encode('utf-8')
	file=open(infile+".pkl","wb")
	pickle.dump(dic,file) 
	exit()  
if domod:
	cdir=""
	dlist={}
	for a in x:
		a=a.strip()
		if(len(a) == 0 and len(cdir) > 0 ):
			#print(cdir,mlist)
			mlist.sort()
			dlist[cdir]=mlist
			cdir=""
			continue
		if (len(a) == 0):
			cdir=""
			continue
		if a.find("-") == 0:
			cdir=a.split()[1]
			mlist=[]
			#print(cdir)
			continue
		if len(cdir) > 0 :
			mods=a.split()
			for mod in mods:
				if(mod.find("(") == -1 ) :
					mlist.append(mod)
	file=open(infile+".pkl","wb")
	pickle.dump(dlist,file)
	exit()
print("Input file name must contain 'mod' or 'env' or have use command line option '-m' or '-e'")	
	   
