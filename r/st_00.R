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


bc<-function(psi){
	myid <<-0
	numprocs <<- 1
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


numprocs<-1
myid<-0
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
psi<-bc(psi)

new_psi<-matrix(0.0,nrow=((i2-i1)+3),ncol=((j2-j1)+3))
forf<<-do_force(i1,i2,j1,j2,alpha)

iout=steps/100
if(iout  == 0){iout=1}
tymer(reset=T)
for(i in 1:steps){
	psi<-do_jacobi(psi)
	if(myid == 0){
			if (((i) %% iout) == 0){
			print(paste(i,gdiff,tymer()))
			}
	}
}

writeBin(as.vector(psi),"stom00.out")

