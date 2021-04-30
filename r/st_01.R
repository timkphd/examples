#!/usr/bin/env Rscript
source("tymer.R")

do_force<-function(i1,i2,j1,j2,alpha){
	forf<-matrix(0.0,nrow=((i2-i1)+3),ncol=((j2-j1)+3))
	r1<-range(0,(i2-i1)+2)
	r2<-range(0,(j2-j1)+1)
	for (i in r1[1]:r1[2]){
		for (j in r2[1]:r2[2]){
			y<-(j+j1-1)*dy
			forf[i+1,j+1]<-(-alpha*sin(y*a6))
		}
	}
	return(forf)
}

getresults<-function(psi,nx,ny){
	myid <<- mpi.comm.rank(comm=mpi_comm_world)
	tosend=(nrow(psi)-2)*(ncol(psi)-2)
	rcounts<-vector("integer",numprocs)
	rcounts<-mpi.gather(tosend, 1, rcounts,root = 0, comm = mpi_comm_world)
	typeof(rcounts)
	typeof(psi)
	tot<-sum(rcounts)
	full<-vector("double",tot)
	full<-mpi.gatherv(psi[(2:(nrow(psi)-1)),(2:(ncol(psi)-1))] ,2, full, rcounts, root = 0, comm = mpi_comm_world)
	#full<-matrix(full,nrow=nx,ncol=ny)
	if(myid == 0){writeBin(full,"stom01.out")}
	#install.packages("plotly", lib="/Library/Frameworks/R.framework/Versions/3.6/Resources/library")
	#result<-readBin("stom01.out",double(),10000)
	#grid<-matrix(result,100,100)
	#library(plotly)
	#plot_ly(z =grid)
}
bc<-function(psi){
	myid <<- mpi.comm.rank(comm=mpi_comm_world)
	numprocs <<- mpi.comm.size(comm=mpi_comm_world)
	myleft<-myid-1
	myright<-myid+1
	if(myleft <= -1){myleft<-(-1)}
	if(myright >= numprocs){myright=(-1)}

	if(myleft == -1){
		psi[,1]=0.0
	}
	if(myright == -1){
		psi[,ncol(psi)]=0.0
	}
		psi[1,]=0.0
		psi[nrow(psi),]=0.0
	return(psi)
}


do_jacobi<-function(psi){
# does a single Jacobi iteration step
# input is the grid and the indices for the interior cells
# new_psi is temp storage for the the updated grid
# output is the updated grid in psi and diff which is
# the sum of the differences between the old and new grids
	gdiff<<-0.0
	is=2
	ie=dim(psi)[1]
	js=2
	je=dim(psi)[2]
	new_psi[,je]<-psi[,je]
	new_psi[,1]<-psi[,1]
	new_psi[ie,]<-psi[ie,]
	new_psi[1,]<-psi[1,]
	je=je-1
	ie=ie-1
	for (i in is:ie){
		for (j in js:je){
			new_psi[i,j]<-a1*psi[i+1,j] + a2*psi[i-1,j] + a3*psi[i,j+1] + a4*psi[i,j-1] - a5*forf[i,j]
			gdiff<<-gdiff+abs(new_psi[i,j]-psi[i,j])
			}
	}
	return(new_psi)
}

do_transfer<-function(psi,i1,i2,j1,j2){
	mystat=0
	myid <<- mpi.comm.rank(comm=mpi_comm_world)
	myleft<-myid-1
	myright<-myid+1
	if(myleft <= -1){myleft<-(-1)}
	if(myright >= numprocs){myright=(-1)}
	lc=dim(psi)[2]
	if(is.even(myid)){
# we are on an even col processor
# send to left
		if(myleft != -1){
			#print(paste(myid,"to",myleft))
			mpi.send(psi[,2], type=2, dest=myleft, tag=100,  comm = mpi_comm_world)
# rec from left
			#print(paste(myid,"from",myleft))
			psi[,1]<-mpi.recv(psi[,1], type=2, source=myleft, tag=100,  comm = mpi_comm_world, status = mystat)
		}
# rec from right
		if(myright != -1){
			#print(paste(myid,"from",myright))
			psi[,lc]<-mpi.recv(psi[,lc], type=2, source=myright, tag=100,  comm = mpi_comm_world, status = mystat)
# send to right
			#print(paste(myid,"to",myright))
			mpi.send(psi[,lc-1], type=2, dest=myright, tag=100,  comm = mpi_comm_world)
			}
	}else{
# we are on an odd col processor
# rec from right
		if(myright != -1){
			#print(paste(myid,"FROM",myright))
			psi[,lc]<-mpi.recv(psi[,lc], type=2, source=myright, tag=100,  comm = mpi_comm_world, status = mystat)
# send to right
			#print(paste(myid,"TO",myright))
			mpi.send(psi[,lc-1], type=2, dest=myright, tag=100,  comm = mpi_comm_world)
		}
# send to left
		if(myleft != -1){
			#print(paste(myid,"TO",myleft))
			mpi.send(psi[,2], type=2, dest=myleft, tag=100,  comm = mpi_comm_world)
# rec from left
			#print(paste(myid,"FROM",myleft))
			psi[,1]<-mpi.recv(psi[,1], type=2, source=myleft, tag=100,  comm = mpi_comm_world, status = mystat)
		}
	}
return(psi)
}

mybind <- function(psi){

}
is.even <- function(x) x %% 2 == 0

if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <<- mpi.comm.rank(comm=mpi_comm_world)
numprocs <<- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()

if (myid != 0) {
	nx<-0
	ny<-0
	lx<-0.0
	ly<-0.0
	alpha<-0.0
	beta<-0.0
	gamma<-0.0
	steps=0
}else{
	ngrid<-scan("st.in",integer(),2)
	grid<-scan("st.in",double(),2,skip=1)
	const<-scan("st.in",double(),3,skip=2)
	steps<-scan("st.in",integer(),1,skip=3)
	#bcast should be here
	nx<-ngrid[1]
	ny<-ngrid[2]
	lx<-grid[1]
	ly<-grid[2]
	alpha<-const[1]
	beta<-const[2]
	gamma<-const[3]
}
 ##  mpi.bcast(nx,    type=1,comm = mpi_comm_world)
 nx<-mpi.bcast(nx,    type=1,comm = mpi_comm_world)
 ##  mpi.bcast(ny,    type=1,comm = mpi_comm_world)
 ny<-mpi.bcast(ny,    type=1,comm = mpi_comm_world)
 ##     mpi.bcast(steps, type=1,comm = mpi_comm_world)
 steps<-mpi.bcast(steps, type=1,comm = mpi_comm_world)
 lx<-mpi.bcast(lx,    type=2,comm = mpi_comm_world)
 ly<-mpi.bcast(ly,    type=2,comm = mpi_comm_world)
 alpha<-mpi.bcast(alpha, type=2,comm = mpi_comm_world)
 beta<-mpi.bcast(beta,  type=2,comm = mpi_comm_world)
 gamma<-mpi.bcast(gamma, type=2,comm = mpi_comm_world)
 print(paste(myid,nx,ny,steps,lx,ly,alpha,beta,gamma))
i1org<-1
i2org<-nx
j1org<-1
j2org<-ny
i1<-1
i2<-nx
j1<-1
j2<-ny
dj<-as.double(j2)/as.double(numprocs)
j1<-round(1.0+myid*dj)
j2<-round(1.0+(myid+1)*dj)-1

dx<<-lx/(nx+1.0)
dy<<-ly/(ny+1.0)
dx<<-lx/(nx+1.0)
dx2<-dx*dx
dy2<-dy*dy
bottom<-2.0*(dx2+dy2)
a1<<-(dy2/bottom)+(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
a2<<-(dy2/bottom)-(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
a3<<-dx2/bottom
a4<<-dx2/bottom
a5<<-dx2*dy2/(gamma*bottom)
a6<<-pi/(ly)
gdiff<<-0.0


psi<-matrix(1.0,nrow=((i2-i1)+3),ncol=((j2-j1)+3))
print(paste(myid,"covers",i1,i2,j1,j2))
psi<-bc(psi)
new_psi<<-matrix(0.0,nrow=((i2-i1)+3),ncol=((j2-j1)+3))
forf<<-do_force(i1,i2,j1,j2,alpha)
iout=steps/100
if(iout  == 0){iout=1}
if(myid == 0){tymer(reset=T)}
for(i in 1:steps){
	psi<-do_transfer(psi,i1,i2,j1,j2)
	psi<-do_jacobi(psi)
	mydiff<-gdiff
	todiff<-mpi.reduce(mydiff, type=2, op="sum",dest = 0, comm = mpi_comm_world)
	if (((i) %% iout) == 0){
#		print(paste(myid,max(psi),min(psi)))
		if(myid == 0){
			print(paste(i,todiff,tymer()))
		}
	}
}
getresults(psi,nx,ny)
bonk<-mpi.finalize()


