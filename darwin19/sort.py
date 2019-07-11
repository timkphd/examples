#!/opt/intel/intelpython2/bin/python
import sys
procs=int(sys.argv[1])

def send(myid,toid):
	print("%d sending to %d  " %(myid,toid))

def recv(myid,fromid):
	print("%d getting from  to %d , merging with my data" %(myid,fromid))

	
def doit(myid,active):
	if(myid >= active):
		send(myid , myid-active)
		return("done")
	if(myid + active < procs):
		recv(myid, myid+active)
	while(active > 1):
		active = active // 2
		if(myid >= active):
			send(myid, myid-active)
			return("done")
		else :
			recv(myid , myid+active)

active =1
while (2*active < procs) :
	active = 2 * active
for myid in range(procs-1,-1,-1):
	print("\nfor myid= %d" %(myid))
	doit(myid,active)
