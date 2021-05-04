#!/usr/bin/env Rscript
# start the cluster
library(foreach)
library(doParallel)
numprocs=parallel::detectCores()
cl <- makeCluster(numprocs)
registerDoParallel(cl)

# do something
nt<-900
aset <- foreach (ijk=1:nt) %dopar% {
    aset<-c(ijk,Sys.getpid())
}
# stop the cluster
stopCluster(cluster)

# use the results
df<-data.frame(iter=integer(),pid=integer())
nresults=length(aset)
for (ijk in 1:nresults){
        r<-unlist(aset[ijk])
        df[nrow(df) + 1,]<-c(r)
    }

str(df)
pids=unique(df['pid'])
for (p in pids[,]) {
    n<-nrow(df[df['pid'] == p,])
    load<-n/nt
    cat(n,load,"\n")
}

