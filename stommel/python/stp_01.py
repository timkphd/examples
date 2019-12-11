#!/usr/bin/env python
from math import pi,sin,modf
from math import fabs as abs
#from Numeric import empty
from numpy import empty
import numpy
from time import time as walltime
global vals,cons
global psi,new_psi,forf
import sys
global a1,a2,a3,a4,a5,a6,dx,dy
global r1,r2
global ttot
global myid,numprocs
import mpi

def round(x):
    sign=1     
    if(x < 0.0):
            sign=-1
            x=-x
    (f,w)=modf(x)
    w=int(w)
    if(f >= 0.5):
            w=w+1
    return w*sign

def even(i):
	return (i % 2) == 0

class input:
	nx,ny=(10 , 10)
	lx,ly=(2000 , 2000)
	alpha,beta,gamma=(1.0e-9 , 2.25e-11 , 3.0e-6)
	steps=500
	def __init__(this):
		this.nx=mpi.mpi_bcast(this.nx,1,mpi.MPI_INT,0,mpi.MPI_COMM_WORLD)[0]
		this.ny=mpi.mpi_bcast(this.ny,1,mpi.MPI_INT,0,mpi.MPI_COMM_WORLD)[0]
		this.steps=mpi.mpi_bcast(this.steps,1,mpi.MPI_INT,0,mpi.MPI_COMM_WORLD)[0]
		this.lx=mpi.mpi_bcast(this.lx,1,mpi.MPI_DOUBLE,0,mpi.MPI_COMM_WORLD)[0]
		this.ly=mpi.mpi_bcast(this.ly,1,mpi.MPI_DOUBLE,0,mpi.MPI_COMM_WORLD)[0]
		this.alpha=mpi.mpi_bcast(this.alpha,1,mpi.MPI_DOUBLE,0,mpi.MPI_COMM_WORLD)[0]
		this.beta=mpi.mpi_bcast(this.beta,1,mpi.MPI_DOUBLE,0,mpi.MPI_COMM_WORLD)[0]
		this.gamma=mpi.mpi_bcast(this.gamma,1,mpi.MPI_DOUBLE,0,mpi.MPI_COMM_WORLD)[0]
		
	def getInput(this):
		return(this.nx,this.ny,this.lx,this.ly,this.alpha,this.beta,this.gamma,this.steps)
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
#		return(this.a1[0],this.a2[0],this.a3[0],this.a4[0],this.a5[0],this.a6[0],this.dy[0],this.dx[0])
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
	for j in r2:
		for i in r1:
			new_psi[i,j]=a1*psi[i+1,j] + a2*psi[i-1,j] + \
			a3*psi[i,j+1] + a4*psi[i,j-1] - \
			a5*forf[i,j]
			diff=diff+abs(new_psi[i,j]-psi[i,j])
	psi[:,:]=new_psi[:,:]
	te=walltime()
	ttot=ttot+(te-ts)
	return (diff)
	
def do_transfer(psi,i1,i2,j1,j2):
	global numprocs,myid
	num_x=i2-i1+3
	myleft=myid-1
	myright=myid+1
	if(myleft <= -1):
		myleft=-1
	if(myright >= numprocs):
		myright=-1
	if(even(myid)):
# we are on an even col processor
# send to left
		if(myleft != -1):
			mpi.mpi_send(psi[:,1],  num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
# rec from left
			psi[:,0]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
# rec from right
		if(myright != -1):
			psi[:,psi.shape[1]-1]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
#			print psi[:,psi.shape[1]-1]
# send to right
			mpi.mpi_send(psi[:,psi.shape[1]-2],  num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
	else:
# we are on an odd col processor
# rec from right
		if(myright != -1):
			psi[:,psi.shape[1]-1]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
# send to right
			mpi.mpi_send(psi[:,psi.shape[1]-2],  num_x,mpi.MPI_DOUBLE,myright, 100,mpi.MPI_COMM_WORLD)
# send to left
		if(myleft != -1):
			mpi.mpi_send(psi[:,1],  num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)
# rec from left
			psi[:,0]=mpi.mpi_recv(num_x,mpi.MPI_DOUBLE,myleft, 100,mpi.MPI_COMM_WORLD)


#def main():
#	global myid,numprocs,cons,vals,forf
#	global r1,r2
#	global ttot
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
print("hello from ",myid," of ",numprocs)

#get the input.  see above for typical values
vals=input()

#set the indices for the interior of the grid
i1org=1
i2org=vals.nx
j1org=1
j2org=vals.ny
i1=1
i2=vals.nx
j1=1
j2=vals.ny
dj=float(j2)/float(numprocs)
j1=round(1.0+myid*dj)
j2=round(1.0+(myid+1)*dj)-1
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
iout=vals.steps/100
if(iout  == 0):
	iout=1
iw=0
r1=range(1,(i2-i1)+2)
r2=range(1,(j2-j1)+2)
ttot=0
for i in range(0,vals.steps):
		do_transfer(psi,i1,i2,j1,j2)
		diff=do_jacobi(psi,new_psi,i1,i2,j1,j2)
		diff=mpi.mpi_reduce(diff,1,  mpi.MPI_DOUBLE,mpi.MPI_SUM,0,mpi.MPI_COMM_WORLD)
		if(myid == 0):
			if ((i+1) % iout) == 0 :
				print(i+1,diff[0])
t2=walltime()
if(myid == 0):
	print("total time=",t2-t1, "  time spent in do_jacobi=",ttot)
mpi.mpi_finalize()

# if is acting as the executable call main
#if __name__ == '__main__':
#	main()

		
