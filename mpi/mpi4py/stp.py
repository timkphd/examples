#!/usr/bin/env python
#total time= 4720.508449077606   time spent in do_jacobi= 4678.393705606461
#['0', '<=', 'i', '<=', '201', ',', '0', '<=', 'j', '<=', '201']
# C version run time =       3.04

# For a description of the Fortran and C versions of this program see:
# http://geco.mines.edu/prototype/Show_me_some_local_HPC_tutorials/stoma.pdf
# http://geco.mines.edu/prototype/Show_me_some_local_HPC_tutorials/stomb.pdf
# The python version stp.py follows this C version except it does a 1d
# decomposition.  
#
# pcalc.py and ccalc.c are similar except they create a new communicator
# that contains N-1 tasks.  These tasks do the calculation and pass data
# to the remaining task to be plotted.  Thus we can have "C" do the heavy
# calculation and python do plotting.    

from math import pi,sin
from math import fabs as abs
from numpy import empty
import numpy
from time import time as walltime
global vals,cons
global psi,new_psi,forf
import sys
global a1,a2,a3,a4,a5,a6,dx,dy
global r1,r2
global ttol
from write_grid import *
from copy import deepcopy
#http://mpi4py.scipy.org/docs/apiref/frames.html
#http://mpi4py.scipy.org/docs/usrman/tutorial.html
from mpi4py import MPI

def myquit(mes):
	MPI.Finalize()
	print(mes)
	sys.exit()
	
def even(i):
	return (i % 2) == 0

class input:
	nx,ny=(0 , 0)
	lx,ly=(0.0 , 0.0)
	alpha,beta,gamma=(0.0,0.0,0.0)
	steps=0
	def __init__(this):
		pass
	def getInput(this):
		return(this.nx,this.ny,this.lx,this.ly,this.alpha,this.beta,this.gamma,this.steps)
	def Read(this):
#  50  50  5000
#  75  75 12000
# 100 100 20000
# 200 200 75000
		mysize=100
		this.nx,this.ny=(mysize,mysize)
		this.lx,this.ly=(2000000. , 2000000.)
		this.alpha,this.beta,this.gamma=(1.0e-9 , 2.25e-11 , 3.0e-6)
		this.steps=75000
		if mysize == 50 :
			this.steps=5000
		if mysize == 75 :
			this.steps=12000
		if mysize == 100 :
			this.steps=20000
		data=sys.stdin.readlines()
		if len(data) >= 4:
			values=data[0].split()
			this.nx=int(values[0])
			this.ny=int(values[1])
			values=data[1].split()
			this.lx=float(values[0])
			this.ly=float(values[1])
			values=data[2].split()
			this.alpha=float(values[0])
			this.beta=float(values[1])
			this.gamma=float(values[2])
			values=data[3].split()
			this.steps=int(values[0])
class constants:
	a1,a2,a3,a4,a5,a6,dx,dy=(0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)
	def __init__(this,inputs):
		dx=inputs.lx/(inputs.nx+1.0)
		dy=inputs.ly/(inputs.ny+1.0)
		dx2=dx*dx
		dy2=dy*dy
		bottom=2.0*(dx2+dy2)
		a1=(dy2/bottom)+(inputs.beta*dx2*dy2)/(2.0*inputs.gamma*dx*bottom)
		a2=(dy2/bottom)-(inputs.beta*dx2*dy2)/(2.0*inputs.gamma*dx*bottom)
		a3=dx2/bottom
		a4=dx2/bottom
		a5=dx2*dy2/(inputs.gamma*bottom)
		a6=pi/(inputs.ly)
		this.dx=dx
		this.dy=dy
		this.a1=a1
		this.a2=a2
		this.a3=a3
		this.a4=a4
		this.a5=a5
		this.a6=a6
	def getCons(this):
		return(this.a1,this.a2,this.a3,this.a4,this.a5,this.a6,this.dy,this.dx)
def do_force(forf,i1,i2,j1,j2):
	global cons,vals
	def force(y):
		global cons,vals
		global r1,r2
		return(-vals.alpha*sin(y*cons.a6))
	r1=range(0,(i2-i1)+3)
	r2=range(0,(j2-j1)+3)
	for i in r1:
		for j in r2:
			y=(j+j1-1)*cons.dy
			forf[i,j]=force(y)
def bc(psi,i1,i2,j1,j2):
	global cons,vals
	if (i1 == 1):
		psi[i1-1,:]=0.0
	if (i2 == vals.ny):
		psi[psi.shape[0]-1,:]=0.0
	if (j1 == 1):
		psi[:,j1-1]=0.0
	if (j2 == vals.nx):
		psi[:,psi.shape[1]-1]=0.0


def do_jacobi(psi,new_psi,i1,i2,j1,j2):
# does a single Jacobi iteration step
# input is the grid and the indices for the interior cells
# new_psi is temp storage for the the updated grid
# output is the updated grid in psi and diff which is
# the sum of the differences between the old and new grids
	global cons
	global forf
	global ttot
	global a1,a2,a3,a4,a5,a6,dx,dy
	diff=0.0
	ts=walltime()
	#for j in r2:
		#for i in r1:
	for i in r1:
		for j in r2:
			new_psi[i,j]=a1*psi[i+1,j] + a2*psi[i-1,j] + \
			a3*psi[i,j+1] + a4*psi[i,j-1] - \
			a5*forf[i,j]
			diff=diff+abs(new_psi[i,j]-psi[i,j])
	#for j in r2:
		#for i in r1:
	for i in r1:
		for j in r2:
			psi[:,:]=new_psi[:,:]
	te=walltime()
	ttot=ttot+(te-ts)
	return (diff)
	

def do_transfer(psi,i1,i2,j1,j2):
	global numnodes,myid,mpi_err
	num_x=i2-i1+3
	myleft=myid-1
	myright=myid+1
	if(myleft <= -1):
		myleft=MPI.PROC_NULL
	if(myright >= numnodes):
		myright=MPI.PROC_NULL
	vlen=psi[:,1].shape[0]
	vlen=psi.shape[0]
	vect=empty(vlen,"d")

	if(even(myid)):
# we are on an even col processor
		if myleft != MPI.PROC_NULL :
	# send to left
			#mpi.mpi_send(psi[:,1],  num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
			vect=deepcopy(psi[:,1])
			#vect=vect*0+myid+10
			comm.Send([vect, MPI.DOUBLE], dest=myleft, tag=100)
	# rec from left
			#psi[:,0]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
			comm.Recv([vect, MPI.DOUBLE], source=myleft, tag=100)
			psi[:,0]=vect
		if myright != MPI.PROC_NULL :
	# rec from right
			#psi[:,psi.shape[1]-1]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
			comm.Recv([vect, MPI.DOUBLE], source=myright, tag=100)
			psi[:,psi.shape[1]-1]=vect
	# send to right
			#mpi.mpi_send(psi[:,psi.shape[1]-2],  num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
			vect=deepcopy(psi[:,psi.shape[1]-2])
			#vect=vect*0+myid+10
			comm.Send([vect, MPI.DOUBLE], dest=myright, tag=100)
	else:
# we are on an odd col processor
		if myright != MPI.PROC_NULL :
	# rec from right
			#psi[:,psi.shape[1]-1]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
			comm.Recv([vect, MPI.DOUBLE], source=myright, tag=100)
			psi[:,psi.shape[1]-1]=vect

	# send to right
			#mpi.mpi_send(psi[:,psi.shape[1]-2],  num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
			vect=deepcopy(psi[:,psi.shape[1]-2])
			#vect=vect*0+myid+10
			comm.Send([vect, MPI.DOUBLE], dest=myright, tag=100)
		if myleft != MPI.PROC_NULL :
	# send to left
			#mpi.mpi_send(psi[:,1],  num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
			vect=deepcopy(psi[:,1])
			#vect=vect*0+myid+10
			comm.Send([vect, MPI.DOUBLE], dest=myleft, tag=100)
	# rec from left
			#psi[:,0]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
			comm.Recv([vect, MPI.DOUBLE], source=myleft, tag=100)
			psi[:,0]=vect
if __name__ == '__main__':
# do init
	global numnodes,myid,mpi_err
	comm=MPI.COMM_WORLD
	myid=comm.Get_rank()
	numnodes=comm.Get_size()
	name = MPI.Get_processor_name()
	print("hello from %d of %d on %s" % (myid,numnodes,name))

	#get the input.  see above for typical values
	if (myid == 0): 
		vals=input()
		vals.Read()
	else:
		vals=input()
	vals.nx=comm.bcast(vals.nx, root=0)
	vals.ny=comm.bcast(vals.ny, root=0)
	vals.lx=comm.bcast(vals.lx, root=0)
	vals.ly=comm.bcast(vals.ly, root=0)
	vals.alpha=comm.bcast(vals.alpha, root=0)
	vals.beta=comm.bcast(vals.beta, root=0)
	vals.gamma=comm.bcast(vals.gamma, root=0)
	vals.steps=comm.bcast(vals.steps, root=0)
	#set the indices for the interior of the grid
	i1org=1
	i2org=vals.nx
	j1org=1
	j2org=vals.ny
	i1=1
	i2=vals.nx
	j1=1
	j2=vals.ny
	dj=float(j2)/float(numnodes)
	j1=round(1.0+myid*dj)
	j2=round(1.0+(myid+1)*dj)-1
	print("proc", myid," holds ",i1,i2,j1,j2)
	# allocate the grid to size nx * ny plus the boundary cells
	t1=walltime()
	psi=empty(((i2-i1)+3,(j2-j1)+3),"d")
	new_psi=empty(((i2-i1)+3,(j2-j1)+3),"d")
	forf=empty(((i2-i1)+3,(j2-j1)+3),"d")
	#calculate the constants for the calculations
	cons=constants(vals)
	(a1,a2,a3,a4,a5,a6,dx,dy)=cons.getCons()

	# set initial guess for the value of the grid
	psi[:,:]=1.0
	do_force(forf,i1,i2,j1,j2)
	#set boundary conditions
	bc(psi,i1,i2,j1,j2)

	new_psi[:,:]=psi[:,:]
	iout=vals.steps//100
	if(iout  == 0):
		iout=1
	r1=range(1,(i2-i1)+2)
	r2=range(1,(j2-j1)+2)
	ttot=0	
	do_transfer(psi,i1,i2,j1,j2)
	for i in range(0,vals.steps):
		diff=do_jacobi(psi,new_psi,i1,i2,j1,j2)
		diff=comm.reduce(diff)
		do_transfer(psi,i1,i2,j1,j2)
		if ((i+1) % iout) == 0  and myid == 0:
			print("%8d %18.6e %10.3f" %(i+1,diff,walltime()-t1))
	t2=walltime()
# turn off write for benchmarks
#	write_each(psi,i1,i2,j1,j2,vals.nx,vals.ny,comm)
	write_one(psi,i1,i2,j1,j2,vals.nx,vals.ny,comm)
	if(myid == 0) : print("total time=",t2-t1, "  time spent in do_jacobi=",ttot)
	myquit("done")



		
