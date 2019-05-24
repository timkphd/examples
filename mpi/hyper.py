#!/usr/bin/env python
# Shows the hypercube algorithm used in
# my implementation of  MPI_Alltoall in
# the example program testall2all.f90
#
# There is an output line for each MPI task.
# Each column is the MPI task with which it
# is doing an exchange at each stage of the
# algorithm. If the number of tasks is not
# a power of two there will be some stages
# where there is no exchange "x".  Note that
# there no duplication of exchanges and every
# task talks with every other task.  
import sys
from operator import xor as ieor
from math import log
numnodes=8
if len(sys.argv) > 1 :
	numnodes=int(sys.argv[1])
n2=round(log(numnodes)/log(2))
n2=int(n2)
if (2**n2 < numnodes) : 
	n2=n2+1

n2=2**n2
n2=n2-1
do=range(1,n2+1)
tasks=range(0,numnodes)
for myid in tasks :
	line=str( " %2d " % (myid))
	for i in do:
		xchng=ieor(i,myid)
		if(xchng <= (numnodes-1)) :
			sub=str( " %2d " % (xchng))
			line=line+sub
		else :
			line=line+"  x "
	print line
