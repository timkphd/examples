#!/usr/bin/env python
from mpi4py import MPI
import numpy
global numnodes,myid,mpi_err
global mpi_root
mpi_root=0
#

#
def worker(THE_COMM_WORLD,managerid):
	x=0
	comm=MPI.COMM_WORLD
	send_msg = numpy.arange(1, dtype='i')
	recv_msg = numpy.zeros_like(send_msg)
	while(x > -1) :
# send message says I am ready for data #
		send_msg[0]=x
		comm.Send([send_msg, MPI.INT], dest=managerid, tag=1234)
# get a message from the manager #
		comm.Recv([recv_msg, MPI.INT], source=managerid, tag=2345)
		x=recv_msg[0]
		x=x*2
	return None
#
def manager(num_used,TODO):
	global numnodes,myid,mpi_err
	global mpi_root
	comm=MPI.COMM_WORLD
	send_msg = numpy.arange(1, dtype='i')
	recv_msg = numpy.zeros_like(send_msg)
	status = MPI.Status()
# our "data"
	inputs = numpy.random.random_integers(1,10000,TODO)
# counters
	igot=0   
	isent=0
	while(igot < TODO):
# wait for a request for work #
		flag=comm.Iprobe(source=MPI.ANY_SOURCE, tag=MPI.ANY_TAG,status=status)
		if(flag):
# where is it comming from #
			gotfrom=status.source 
			sendto=gotfrom
			comm.Recv([recv_msg, MPI.INT], source=gotfrom, tag=1234)
			x=recv_msg[0]
			print("worker %d sent %d" % (gotfrom,x))
			if(x > -1):
				igot=igot+1
				print("igot "+str(igot))
			if(isent < TODO):
# send real data #
				x=inputs[isent]
				send_msg[0]=x
				comm.Send([send_msg, MPI.INT], dest=sendto, tag=2345)
				isent=isent+1
# tell everyone to quit #
	for i in range(1,num_used+1):
		x=-1000
		send_msg[0]=x
		comm.Send([send_msg, MPI.INT], dest=i, tag=2345)
	return None
#
#
if __name__ == '__main__':
# do init
	global numnodes,myid,mpi_err
	comm=MPI.COMM_WORLD
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
	name = MPI.Get_processor_name()
	print("hello from %d of %d on %s" % (myid,numnodes,name))
# num_used is the # of processors that are part of the new communicator #
# for this case hardwire to not include 1 processor #
	num_used=numnodes-1
	mannum=0;
	MPI_COMM_WORLD=MPI.COMM_WORLD
	if(myid == mannum):
		group=0
	else:
		group=1
	WORKER_WORLD=MPI_COMM_WORLD.Split(group,myid)
#
	new_id=WORKER_WORLD.Get_rank()
	worker_size=WORKER_WORLD.Get_size()
	print("old id = %d   new id = %d   worker size = %d" %(myid,new_id,worker_size))
#
	if(group == 0):
		todo=100
# if not part of the new group do management. #
		manager(num_used,todo)
		print("manager finished")
		#mpi_err =  MPI_Barrier(MPI_COMM_WORLD)
		MPI_COMM_WORLD.barrier()
		MPI.Finalize()
	else:
# part of the new group do work. #
		mannum=0;
		worker(WORKER_WORLD,mannum);
		print("worker finished %d %d" %(myid,new_id))
		MPI_COMM_WORLD.barrier()
		MPI.Finalize()
