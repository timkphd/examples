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
paste("I R am",myid,"of",numprocs,"on",myname)
if(myid == source){
	buffer<-as.integer(5678)
	mpi.send(buffer, 1, destination, tag,  comm=mpi_comm_world)
	}
if(myid == destination){
	x<-as.integer(1234)
	x<-mpi.recv(x, 1, source, tag,  comm=mpi_comm_world, status=0)
	print(c("got",x))
	}
bonk<-mpi.finalize()
#bonk<-mpi.exit()
