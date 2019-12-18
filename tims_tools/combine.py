#!/usr/bin/python
#combine two or more html files taking the 
#header from the first and bodies from each
import os
import sys
file1=sys.argv[1]
f1=open(file1,"r")
dat1=f1.readlines()
for l in dat1:
    b2=l.find("</body")
    if (b2 < 0):
        print(l.strip())
    else:
        break
for r in sys.argv[2:]:
    print("<br>")
    print("<br>")
    f2=open(r,"r")
    dat1=f2.readlines()
    k=0
    for l in dat1:
        b2=l.find("<body")
        k=k+1
        if (b2 < 0):
            pass
        else:
             break
    for l in dat1[k:]:
        b2=l.find("</body")
        if (b2 < 0):
            print(l.strip())
        else:
            break
print("</body>")
print("</hltm>")
