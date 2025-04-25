#!/usr/bin/env python3
# usage
# scontrol show hostnames | ./mlist.py  4 2 6
import sys
node_list = sys.stdin.read()
node_list=node_list.split()
k=0
nnodes=len(node_list)
for n in sys.argv[1:]:
    for j in range(0,int(n)):
        print(node_list[k % nnodes])
    k=k+1
