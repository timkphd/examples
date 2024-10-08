#!/usr/bin/env python3
import json
import sys
file=sys.argv[1]
infile=file+".json"
outfile=file+".dat"

with open(infile,"r") as read_file:
    data = json.load(read_file)

times=data['samples']['window_start_offsets']
mem=data['samples']['metrics']['node_mem_percent']['maxs']
tot_mem=data['info']['metrics']['memory_per_node']['mean']
tot_mem=float(tot_mem)/1e9
f=open(outfile,"w")
sm=mem[0]
for t, m in zip(times, mem):
    # divide by 100 because memory reported is %
    m=float(m-sm)*tot_mem/100.0
    if m < 0 : m=0
# memory is in GB
    x=f.write(str(t)+" "+str(m)+"\n")     
