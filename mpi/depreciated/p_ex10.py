#!/usr/bin/env python
#
# This program shows how to use MPI_Scatter and MPI_Gather
# Each processor gets different data from the root processor
# by way of mpi_scatter.  The data is summed and then sent back
# to the root processor using MPI_Gather.  The root processor
# then prints the global sum. 
#
import numpy
from numpy import *
import mpi
import sys
import math

def get_input():
	to=0
	my_tag=0
	i=0
	f12=open('./ex10.in', 'r')
	while i < 100 :
		x=f12.readline()
		i=int(x)
		print "i=",i
		mpi.mpi_send(i,1,mpi.MPI_INT,to,my_tag,mpi.MPI_COMM_WORLD)

	return i
#end subroutine get_input

def pass_token(THE_COMM_WORLD):
	my_tag=1234
	j=0
	flag=0
	to=myid+1
	if to == numnodes:
		to=0
	fromid=myid-1
	if fromid < 0 :
		fromid=numnodes-1
	i=0
	while i < 100 :
		if myid == j:
			flag=mpi.mpi_iprobe(mpi.MPI_ANY_SOURCE,mpi.MPI_ANY_TAG,mpi.MPI_COMM_WORLD)
			if flag == 1:
				i=mpi.mpi_recv(1,mpi.MPI_INT,mpi.MPI_ANY_SOURCE,mpi.MPI_ANY_TAG,mpi.MPI_COMM_WORLD)
				i=i[0]
			#endif
			mpi.mpi_send(i,1, mpi.MPI_INT,to,my_tag,THE_COMM_WORLD)
			j=-1
		else :
			i=mpi.mpi_recv(1,mpi.MPI_INT,fromid,my_tag,THE_COMM_WORLD)
			i=i[0]
			j=myid
		#endif
	#endwhile
	if myid < numnodes-1 :
		mpi.mpi_send(i,1, mpi.MPI_INT,to,my_tag,THE_COMM_WORLD)
#end subroutine pass_token


#print "before",len(sys.argv),sys.argv
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
#print "after ",len(sys.argv),sys.argv

myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numnodes=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print "hello from ",myid," of ",numnodes


num_used=numnodes-1
if numnodes > num_used :
# get our old group from MPI_COMM_WORLD
	old_group=mpi.mpi_comm_group(mpi.MPI_COMM_WORLD)
# create a new group from the old group 
# that will contain a subset of the  processors
	will_use=zeros(num_used,"i")
	for ijk in range(0, num_used):
		will_use[ijk]=ijk
		print will_use[ijk]
	new_group=mpi.mpi_group_incl(old_group,num_used,will_use)
# create the new communicator
	tims_comm_world=mpi.mpi_comm_create(mpi.MPI_COMM_WORLD,new_group)
# test to see if i am part of new_group.
	user_id=mpi.mpi_group_rank(new_group)
	if user_id == mpi.MPI_UNDEFINED:
# if not part of the new group do keyboard i/o.
		print "getting input"
		get_input()
		mpi.mpi_barrier(mpi.MPI_COMM_WORLD)
		mpi.mpi_finalize()
		sys.exit(0)
	else:
		print "passing token"
		myid=mpi.mpi_comm_rank( tims_comm_world )
		numnodes=mpi.mpi_comm_size( tims_comm_world )
		pass_token(tims_comm_world)
		print "back"
		mpi.mpi_barrier(mpi.MPI_COMM_WORLD)
    
mpi.mpi_finalize()
#end program





