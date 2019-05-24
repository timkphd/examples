#!/usr/bin/env python
from math import pi,sin
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
global ttol


def write_it(psi,i1, i2, j1, j2,nx,ny):
	from numpy import empty
	myid=100
	if(i1==1):
		i0=0
	else :
		i0=i1
	if(i2==nx):
		i3=nx+1
	else :
		i3=i2
	if(j1==1): 
		j0=0
	else :
		j0=j1
	if(j2==ny):
		j3=ny+1
	else :
		j3=j2
	fname="out"+str(myid)
	eighteen=open(fname,"w")
	
	aline=(str(i3-i0+1)+" , "+str(j3-j0+1)+" "+str(psi.shape))
	eighteen.write(aline+"\n")
	for i in range(i0,i3+1) :
		for j in range(j0,j3+1) :
			xout=str(psi[i][j])
			eighteen.write(xout)
			if(j != j3):
				eighteen.write(" ")
		eighteen.write("\n")
	eighteen.close()


class input:
	nx,ny=(50 , 50)
	lx,ly=(2000000 , 2000000)
	alpha,beta,gamma=(1.0e-9 , 2.25e-11 , 3.0e-6)
	steps=5000
	def __init__(this):
		pass
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
		return(this.a1,this.a2,this.a3,this.a4,this.a5,this.a6,this.dy,this.dx)
def do_force(forf,i1,i2,j1,j2):
	def force(y):
		global cons,vals
		return(-vals.alpha*sin(y*cons.a6))
	for i in range(i1-1,i2+2):
		for j in range(j1-1,j2+2):
			y=j*cons.dy
			forf[i,j]=force(y)
def bc(psi,i1,i2,j1,j2):
	psi[i1-1,:]=0.0
	psi[i2+1,:]=0.0
	psi[:,j1-1]=0.0
	psi[:,j2+1]=0.0


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
	
#get the input.  see above for typical values
vals=input()

#set the indices for the interior of the grid
i1=1
i2=vals.nx
j1=1
j2=vals.ny
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
r1=range(i1,i2+1)
r2=range(j1,j2+1)
ttot=0
for i in range(0,vals.steps):
	diff=do_jacobi(psi,new_psi,i1,i2,j1,j2)
	if ((i+1) % iout) == 0 :
		print(i+1,diff)
t2=walltime()
write_it(psi,i1,i2,j1,j2,i2,j2)
print("total time=",t2-t1, "  time spent in do_jacobi=",ttot)



		
