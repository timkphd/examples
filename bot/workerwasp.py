#!/usr/bin/env python
from mpi4py import MPI
import random
import numpy
import subprocess, time, os, sys

global numnodes,myid,mpi_err
global mpi_root
mpi_root=0
#

def doit(ic,doline,rank):
		stdir=os.getcwd()
		print("%6.6d  running by %3d : %s" %(ic,rank,doline.rstrip()))
		newdir=doline.rstrip()
		os.chdir(stdir+"/"+newdir)
		st=time.time()
#NOTE: instead of spawning a new task here we could compile
#      a C or Fortran routine.  See cpam.c for an example
		cmd = ["/opt/raspa/bin/simulate", "simulation.input"]
		rt=rank*2
		cmd = ["../dummy.py", str(rt)]
		outfile=open("myout","w")
		p = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
		while p.poll() == None:
			outfile.write(p.stdout.readline())
		outfile.write("return code: %d" % (p.poll())+"\n")
		if p.stderr != None :
			outfile.write("err> \n"+p.stderr.read())
		et=time.time()
		out="Run time %8.2f" %(et-st)
		print("%6.6d finished by %3d : %s" %(ic,rank,out))
		outfile.write("\n"+out+"\n")
		outfile.close()
		os.chdir(stdir)



def init_it( ) :
	global myid,numnodes
	comm=MPI.COMM_WORLD
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
#
def worker(THE_COMM_WORLD,managerid,files,stamp):
	x=0.0
	comm=MPI.COMM_WORLD
	send_msg = numpy.arange(1, dtype='i')
	recv_msg = numpy.zeros_like(send_msg)
	stdir=os.getcwd()
	fname="mpi_%4.4d_%s" % (comm.Get_rank(),stamp)
	fname=stdir+"/"+fname
	l=open(fname,"w")
	l.close()
	while(x > -1) :
# send message says I am ready for data #
		#mpi_err= MPI_Send((void*)&x,1,MPI_FLOAT,managerid,1234,MPI_COMM_WORLD);
		send_msg[0]=x
		comm.Send([send_msg, MPI.INT], dest=managerid, tag=1234)
# get a message from the manager #
		#mpi_err= MPI_Recv((void*)&x,1,MPI_FLOAT,managerid,2345,MPI_COMM_WORLD,&status);
		comm.Recv([recv_msg, MPI.INT], source=managerid, tag=2345)
		x=recv_msg[0]
		if x <  len(files) and x > -1 :
# process data #
			l=open(fname,"a")
			l.write(str(x)+" "+files[x].strip()+" "+time.asctime()+"\n")
			l.close()
			doit(x,files[x],comm.Get_rank())
			l=open(fname,"a")
			l.write("done "+time.asctime()+"\n")
			l.close()
		x=x*2
	return None
#
def manager(num_used,todo):
	global numnodes,myid,mpi_err
	global mpi_root
	comm=MPI.COMM_WORLD
	send_msg = numpy.arange(1, dtype='i')
	recv_msg = numpy.zeros_like(send_msg)
	status = MPI.Status()
	TODO=todo
	igot=0   
	isent=0
	inputs = numpy.arange(TODO, dtype='i')
	while(igot < TODO):
# wait for a request for work #
		#mpi_err = MPI_Iprobe(MPI_ANY_SOURCE,MPI_ANY_TAG,MPI_COMM_WORLD,&flag,&status);
		flag=comm.Iprobe(source=MPI.ANY_SOURCE, tag=MPI.ANY_TAG,status=status)
		if(flag):
# where is it comming from #
			gotfrom=status.source 
			sendto=gotfrom
			#mpi_err = MPI_Recv((void*)&x,1,MPI_FLOAT,gotfrom,1234,MPI_COMM_WORLD,&status);
			comm.Recv([recv_msg, MPI.INT], source=gotfrom, tag=1234)
			x=recv_msg[0]
			print("worker %d sent %d" % (gotfrom,x))
			if(x > -1):
				igot=igot+1
				print("igot "+str(igot))
			if(isent < TODO):
# send real data #
				x=inputs[isent]
				#mpi_err = MPI_Send((void*)&x,1, MPI_FLOAT,sendto,2345,MPI_COMM_WORLD);
				send_msg[0]=x
				comm.Send([send_msg, MPI.INT], dest=sendto, tag=2345)
				isent=isent+1
# tell everyone to quit #
	for i in range(1,num_used+1):
		x=-1000
		#mpi_err = MPI_Send((void*)&x,1, MPI_FLOAT,i,2345,MPI_COMM_WORLD);
		send_msg[0]=x
		comm.Send([send_msg, MPI.INT], dest=i, tag=2345)
	return None
#
#
if __name__ == '__main__':
	global numnodes,myid,mpi_err
	init_it();
	print("hello from %d\n" % (myid))
# num_used is the # of processors that are part of the new communicator #
# for this case hardwire to not include 1 processor #
	num_used=numnodes-1
	mannum=0;
	MPI_COMM_WORLD=MPI.COMM_WORLD
	stamp=MPI_COMM_WORLD.bcast(time.strftime("%m%d%H%M%S"),0)
	if(myid == mannum):
		group=0
	else:
		group=1
	#MPI_Comm_split(MPI_COMM_WORLD,group,myid,&WORKER_WORLD);
	WORKER_WORLD=MPI_COMM_WORLD.Split(group,myid)
#
	#MPI_Comm_rank( WORKER_WORLD, &new_id);
	#MPI_Comm_size( WORKER_WORLD, &worker_size);
	inlist=""
	if(myid == 0):
		if len(sys.argv) > 1:
			inlist=sys.argv[1]
		else:
			inlist="list"
		if os.path.exists(inlist) :
			pass
		else:
		# if our data file does not exist create one
			st=int(time.time())
			l=open(inlist,"w")
			for n in range(st,st+3*num_used):
				name=str(n)
				l.write(name+"\n")
				os.mkdir(name)
				name=name+"/d"+name
				l2=open(name,"w")
				l2.write(name)
				l2.close()
	inlist=MPI_COMM_WORLD.bcast(inlist,0)
	l=open(inlist,"r")
	files=l.readlines()
	l.close()
	todo=len(files)

	new_id=WORKER_WORLD.Get_rank()
	worker_size=WORKER_WORLD.Get_size()
	print("old id = %d   new id = %d   worker size = %d\n" %(myid,new_id,worker_size))
#
	if(group == 0):
# if not part of the new group do management. #
		manager(num_used,todo)
		print("manager finished\n")
		#mpi_err =  MPI_Barrier(MPI_COMM_WORLD)
		MPI_COMM_WORLD.barrier()
		MPI.Finalize()
		sys.exit(0)
	else:
# part of the new group do work. #
		mannum=0;
		worker(WORKER_WORLD,mannum,files,stamp);
		print("worker finished %d %d\n" %(myid,new_id))
		MPI_COMM_WORLD.barrier()
		MPI.Finalize()
		sys.exit(0)
