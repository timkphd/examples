#!/usr/bin/env Rscript
if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <- mpi.comm.rank(comm=mpi_comm_world)
numprocs <- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()
tag<-1234;
source<-0;
destination<-1;
count<-1;
for(i in 1:3) {
paste("I R am",myid,"of",numprocs,"on",myname)
if(myid == source){
	buffer<-as.integer(c(5678+i,1234+i,6789+i,4567+i))
    print(sprintf("R sending %d %d %d %d",buffer[1],buffer[2],buffer[3],buffer[4]))
	mpi.send(buffer, 1, destination, tag,  comm=mpi_comm_world)
	}
if(myid == destination){
	x<-as.integer(c(0,0,0,0))
	x<-mpi.recv(x, 1, source, tag,  comm=mpi_comm_world, status=0)
	print(c("got",x))
	}
}
bonk<-mpi.finalize()
#bonk<-mpi.exit()
