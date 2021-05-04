#!/usr/bin/env Rscript
if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <- mpi.comm.rank(comm=mpi_comm_world)
numprocs <- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()
cat("I am",myid,"of",numprocs,"on",myname,"\n")
if (myid == 0 ) {
  library(datasets)
  set2<-iris[iris$Species == "versicolor", ]
} else {
# For the bcast we need to set input 
# to something on every processor
# even though technically it is not used.
  set2<-integer(1)
}
Sys.sleep(2)
set2<-mpi.bcast.Robj(set2,0,comm=mpi_comm_world)
if (myid == 1) {
    head(set2)
}
Sys.sleep(2)
if (myid == 0 ) {
  set1<-iris[iris$Species == "setosa", ]
  each=as.integer(nrow(set1)/numprocs)
# We are going to send a section of "setosa"
# to each processor. This gives the ranges.
  bots<-integer(numprocs)
  tops<-integer(numprocs)
  for (n in 1:numprocs) {
    bots[n]<-(n-1)*each+1
    tops[n]<-bots[n]+each-1
  }
  tops[numprocs]=nrow(set1)
  cat("bots",bots,"\n")
  cat("tops",tops,"\n")
  myset<-set1[bots[1]:tops[1],]
  for (n in 1:(numprocs-1)) {
    tosend<-set1[bots[n+1]:tops[n+1],]
    mpi.send.Robj(tosend,n,tag=1234,comm=mpi_comm_world)
  }
} else {
   status<-as.integer(0)
   myset<-mpi.recv.Robj(0,tag=1234,comm=mpi_comm_world,status)
}
#head(myset)
#Sepal.Length Sepal.Width Petal.Length Petal.Width
sizes<-c(sum(myset[["Sepal.Length"]]),sum(myset[["Sepal.Width"]]),
         sum(myset[["Petal.Length"]]),sum(myset[["Petal.Width"]]))
cat(myid,"sums",sizes,"\n")
thetot<-mpi.reduce(sizes, type=2, op="sum",dest = 0, comm = mpi_comm_world)
if(myid == 0) {
  thetot=thetot/nrow(set1)
  cat("Final sizes =",thetot,"\n")
}
bonk<-mpi.finalize()

