#!/usr/bin/env Rscript
# start the cluster
library(foreach)
library(doParallel)
numprocs<-parallel::detectCores()
cl <- makeCluster(numprocs)
registerDoParallel(cl)
nt<-900

# default is a list
aset <- foreach (ijk=1:nt) %dopar% {
    aset<-c(ijk,Sys.getpid())
}


head(aset)


aset <- foreach (ijk=1:nt , .combine=rbind) %dopar% {
    aset<-c(ijk,Sys.getpid())
}


head(aset)

aset <- foreach (ijk=1:nt , .combine=cbind) %dopar% {
    aset<-c(ijk,Sys.getpid())
}

head(aset)