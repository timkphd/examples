#!/usr/bin/env python3

#typeset  -f > be4
# runs script that makes functions
#typeset  -f > aft

import os
import sys
command="diff be4 aft | grep \(\)"
difs=os.popen(command,"r")
difs=difs.readlines()

aft=open("aft","r")
aft=aft.readlines()

funcs=[]
for d in difs:
    d=d.strip()
    d=d.replace("> ","")
    d=d.replace(" ()","")
    funcs.append(d)
    
for f in funcs:
    i=0
    for l in aft:
        if (l.find(f) == 0):
            print("\nlocal "+f+"_str = [=[")
            break
        i=i+1
    for l in aft[i+2:]:
        if (l.find("}") == 0):
            print("]=]")
            print("\n")
            print('set_shell_function("'+f+'",'+f+'_str)')
            break
        else:
            print(l.rstrip())
