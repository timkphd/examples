#!/usr/bin/env python
import sys
cmin=int(sys.argv[1])
cmax=int(sys.argv[2])
left=2**103
mask=""
for l in range(cmin,cmax+1) :
    l=103-l
    x=left//2**l
    #print( x,f"{x:#026x}",f"{x:#0104b}")
    smask=f"{x:#026x}"
    mask=mask+smask+","
mask=mask[0:len(mask)-1]
print(mask)

