#!/usr/bin/python
import os
import sys
input=sys.argv[1]
file=open(input,"r")
dat=file.readlines()
tasks=0
threads=0
tmin=1e32
for d in dat:
    if d.find("</td><td>") > -1:
         d=d.replace("</td>","")
         d=d.replace("</tr>\n","")
         d=d.split("<td>")
         d=d[2:]
         #print(d)
         its=int(d[3])
         if its < 10000:
             thetime=float(d[4])
             if thetime < tmin:
                 tmin=thetime
                 tasks=int(d[0])
                 threads=int(d[1])

input=input.replace(".html","")
print("%d %g %d %d" % (int(input)**2,tmin,tasks,threads))
