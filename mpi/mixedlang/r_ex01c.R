#!/usr/bin/env Rscript
if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <- mpi.comm.rank(comm=mpi_comm_world)
numprocs <- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()

# number of times we will exchange data
times<-3
# length of the vector to exchange
count<-4
# these can be on the command line
#srun -n 2 ./r_ex01c.R 3 4
if (myid == 0){
    args <- commandArgs(trailingOnly=TRUE)
    if (length(args) > 0) {
        times<-as.integer(args[1])
    }
    if (length(args) > 1) {
        count<-as.integer(args[2])
    }
}
times<-mpi.bcast(times,type=1,comm = mpi_comm_world)
count<-mpi.bcast(count,type=1,comm = mpi_comm_world)
tag<-1234;
source<-0;
destination<-1;
paste("R Hello from ",myname," # ",myid,"of",numprocs)
for(i in 1:times) {
if(myid == source){
    buffer<-c()
    for(j in 1:count) {
        buffer<-c(buffer,j+j+i)    
    }
    for(destination in 1:(numprocs-1)) {
        mpi.send(buffer, 1, destination, tag,  comm=mpi_comm_world)
    }
    head="R sending"
    for(i in 1:count) {
        head<-paste(head,sprintf(" %d",buffer[i]))    
    }
    print(head)

}
if(myid != source){
    x<-c()
    for(j in 1:count) {
        x<-c(x,as.integer(0))
    }
    x<-mpi.recv(x, 1, source, tag,  comm=mpi_comm_world, status=0)
    head="R processor  "
    head<-paste(head,sprintf(" %d got",myid))  
    for(i in 1:count) {
        head<-paste(head,sprintf(" %d",x[i]))    
    }
    print(head)
    }
}
bonk<-mpi.finalize()
#bonk<-mpi.exit()
