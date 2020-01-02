#!/usr/bin/python
import os
import sys
import re
f1=sys.argv[1]
f2=sys.argv[2]
f1=open(sys.argv[1],"r")
f2=open(sys.argv[2],"r")
d1=f1.readlines()
d2=f2.readlines()
k=0
for l in d1:
    if l.find("title") > 0:
        d1[k]="<title>Differences</title>"
    k=k+1
k=0
for l in d1:
    if l.find("title") > 0:
        d2[k]="<title>Differences</title>"
    k=k+1
#print(len(d1),len(d2))
k=0
for l in d1:
    if(l == d2[k]):
        print(l.strip())
    else:
        if(l.find("h3") > 0):
            print(l.strip())
            print(d2[k].strip())
        else:
            r1=re.findall(r"\d+\.\d+|\d+", l)
            r2=re.findall(r"\d+\.\d+|\d+", d2[k])
            temp="<tr><td></td><td>A</td><td>B</td><td>C</td><td>D</td><td>E</td><td>F</td><td>G</td></tr>"
            j=0
            key=['A','B','C','D','E','F','G']
            for r in r1:
                if(r2[j] == r):
                    temp=temp.replace(key[j],r)
                else:
                    x=(float(r2[j])-float(r))/(0.5*(float(r2[j])+float(r)))
                    x="{:10.2f}%".format(x*100)
                    x='<span style="color:red">'+str(x)+"</span>"
                    temp=temp.replace(key[j],x)
                j=j+1
            print(temp)
    k=k+1

