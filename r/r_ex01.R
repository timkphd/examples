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
paste("I am",myid,"of",numprocs,"on",myname)
if(myid == source){
	buffer<-5678.9
	mpi.send(buffer, 2, destination, tag,  comm=mpi_comm_world)
	}
if(myid == destination){
	x<-1234.5
	x<-mpi.recv(x, 2, source, tag,  comm=mpi_comm_world, status=0)
	print(c("got",x))
	}
bonk<-mpi.finalize()
#bonk<-mpi.exit()
