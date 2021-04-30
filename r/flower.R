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
paste("R am",myid,"of",numprocs,"on",myname)
bots<-integer(numprocs)
tops<-integer(numprocs)
if (myid == 0 ) {
  library(datasets)
  set1<-iris[iris$Species == "setosa", ]
  set2<-iris[iris$Species == "versicolor", ]
  #set3<-iris[iris$Species == "virginica", ]
  each=as.integer(nrow(set1)/numprocs)
  for (n in 1:numprocs) {
    bots[n]<-(n-1)*each+1
    tops[n]<-bots[n]+each-1
  }
  tops[numprocs]=nrow(set1)
  print(bots)
  print(tops)
  myset<-set1[bots[1]:tops[1],]
} else {
set2<-integer(1)
}
Sys.sleep(2)
set2<-mpi.bcast.Robj(set2,0,comm=mpi_comm_world)
if (myid == 1) {
    head(set2)
}
Sys.sleep(2)
if (myid == 0 ) {
  for (n in 1:(numprocs-1)) {
    tosend<-set1[bots[n+1]:tops[n+1],]
    mpi.send.Robj(tosend,n,tag=1234,comm=mpi_comm_world)
  }
} else {
   status<-as.integer(0)
   myset<-mpi.recv.Robj(0,tag=1234,comm=mpi_comm_world,status)
}
#print(myset)
#Sepal.Length Sepal.Width Petal.Length Petal.Width
sizes=c(sum(myset[["Sepal.Length"]]),mean(myset[["Sepal.Width"]]),
        sum(myset[["Petal.Length"]]),mean(myset[["Petal.Width"]]))
cat(myid,sizes,"\n")
thetot<-mpi.reduce(sizes, type=2, op="sum",dest = 0, comm = mpi_comm_world)
if(myid == 0) {
  thetot=thetot/nrow(set1)
  cat("Final sizes =",thetot,"\n")
}
bonk<-mpi.finalize()

