#!/usr/bin/env python3
# Pass a "token" from one task to the next with
# a single task reading token from a file.

# An extensive program.  We first create a new
# communicator that contains every task except the
# zeroth one.  This is done by first defining a group,
# new_group.  We define new_group based on the group
# associated with mpi_comm_world, old_group and an 
# array, will_use.  Will_use contains a list of tasks
# to be included in the new group.  It does not 
# contain the zeroth one.  
# The new communicator is sub_comm_world.
#
# There are other ways to create communicator but this
# is one of the more general methods.
# 
# Next, we have break of the task not in the communicator
# to call the routine get_input.  This routine will do
# input from a file ex10.in.  The file contains a list
# of integers.  The task will send the integer to the 
# first task in the new communicator.

# The remaining tasks which are port of sub_comm_world 
# call the routine pass_token.  Pass_token "just" receives
# a value from the previous processor and passes it on
# to the next.

# There is a minor subtlety in pass_token.  We are using
# both our new communicator and MPI_COMM_WORLD.  The tasks
# that are port of the new communicator use it to pass 
# data.  We note that the task that is injecting values
# into the stream is not part of the new communicator
# so it must use MPI_COMM_WORLD.  Thus we do a probe on
# WORLD, which is actually MPI_COMM_WORLD looking for a
# message.  When we get it we send it on using the new
# communicator.  


from mpi4py import MPI
import numpy
from numpy import *
import sys


global numprocs,myid,mpi_err
global mpi_root
mpi_root=0

def myquit(mes):
        MPI.Finalize()
        print(mes)
        sys.exit()

def get_input(comm):
	to=0
	my_tag=0
	i=empty(1,"i")
	i[0]=1
	f12=open('./ex10.in', 'r')
	while i[0] < 100 :
		x=f12.readline()
		i[0]=int(x)
		print("i=",i)
		comm.Send([i,MPI.INT],to,my_tag)
	return i
#end subroutine get_input

def pass_token(DEFINED_COMM,WORLD):
	status = MPI.Status()
	my_tag=1234
	j=0
	flag=0
	myid=DEFINED_COMM.Get_rank()
	to=myid+1
	if to == numprocs:
		to=0
	fromid=myid-1
	if fromid < 0 :
		fromid=numprocs-1
	i=empty(1,"i")
	i[0]=0
	print("ids ",DEFINED_COMM.Get_rank(),WORLD.Get_rank())
	while i[0] < 100 :
		if myid == j:
# The first task in our group waits for a value from MPI_COMM_WORLD
			flag=WORLD.Iprobe(source=MPI.ANY_SOURCE, tag=MPI.ANY_TAG,status=status)
			if(flag):
				i[0]=-12345
				WORLD.Recv([i, MPI.INT], source=MPI.ANY_SOURCE, tag=MPI.ANY_TAG)
				print(myid," WORLD.Recv",i[0])
			#endif
			print(myid," my new id got ",i[0])
#			i[0]=i[0]+1
# Then sends it on to the next task which is part of our new communicator
			print(myid," DEFINED_COMM.Send #1",i[0]," to ",to)
			DEFINED_COMM.Send([i,MPI.INT],to,my_tag)
			j=-1
		else :
# else we just wait for a value from the previous task in our communicator
			i[0]=-12345
			DEFINED_COMM.Recv([i, MPI.INT], source=fromid, tag=my_tag)
			print(myid," DEFINED_COMM.Recv",i[0]," from ",fromid)
			j=myid
		#endif
	#endwhile
	if myid < numprocs-1 :
		print(myid," DEFINED_COMM.Send #2",i[0]," to ",to)
		DEFINED_COMM.Send([i,MPI.INT],to,my_tag)
#end subroutine pass_token


comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()
print("hello from ",myid," of ",numprocs)


num_used=numprocs-1
# get our old group from MPI_COMM_WORLD
old_group=comm.Get_group()
# create a new group from the old group 
# containing a subset of the processors
will_use=zeros(num_used,"i")
for ijk in range(0, num_used):
	will_use[ijk]=ijk

print(will_use)
new_group=old_group.Incl(will_use)
# create the new communicator
sub_comm_world=comm.Create(new_group)
# test to see if i am part of new_group.
user_id=new_group.Get_rank()


if user_id == MPI.UNDEFINED:
# If not part of the new group do keyboard i/o.
	print("getting input")
	get_input(comm)
	comm.Barrier()
	myquit("done getting input")
else:
# If part of the new group pass the token.
	myid=sub_comm_world.Get_rank()
	numprocs=sub_comm_world.Get_size()
	print("passing token with task %d of %d" % (myid,numprocs))
	pass_token(sub_comm_world,comm)
	print("back")
	comm.Barrier()
	myquit("passing token")



