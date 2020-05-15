#!/usr/bin/env python3

# Make module from "new" bash functions
# typeset  -f > be4
# run script that adds functions
# typeset  -f > aft
# ./makemod.py > mods/new.lua

import os

command="diff be4 aft | grep \(\)"
difs=os.popen(command,"r").readlines()

funcs=[]
for d in difs:
    d=d.strip()
    d=d.replace("> ","")
    d=d.replace(" ()","")
    funcs.append(d)
    
aft=open("aft","r").readlines()

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
