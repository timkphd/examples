#!/usr/bin/env Rscript
if (!is.loaded("mpi_initialize")) {library("Rmpi")} 
 
mpi_comm_world<-0 
myid <- mpi.comm.rank(comm=mpi_comm_world)
numprocs <- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()

paste("I am",myid,"of",numprocs,"on",myname)

source=0
count<-4 #not needed

buffer1<-c(0,0,0,0)
if (myid == source){
    buffer1<-c(10,200,3000,40000)
}

buffer1<-mpi.bcast(buffer1,type=1,comm = mpi_comm_world)

#print(c(myid,buffer1))

buffer2<-as.integer(myid+1)

stuff<-vector("integer",numprocs)

stuff<-mpi.gather(buffer2, 1, stuff,root = 0, comm = mpi_comm_world)

mysum<-mpi.reduce(buffer2, type=1, op="sum",dest = 0, comm = mpi_comm_world)

myprod<-mpi.reduce(buffer2, type=1, op="prod",dest = 0, comm = mpi_comm_world)

if(myid == 0){
	print(stuff)
	print(mysum)
	print(myprod)
}

bonk<-mpi.finalize()

