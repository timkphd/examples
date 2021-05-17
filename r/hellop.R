#!/usr/bin/env Rscript
# start the cluster
library(foreach)
library(doParallel)
numprocs<-parallel::detectCores()
cl <- makeCluster(numprocs)
registerDoParallel(cl)

# do something
nt<-90
aset <- foreach (ijk=1:nt) %dopar% {
    aset<-c(ijk,Sys.getpid())
}
# stop the cluster
stopCluster(cl)

# use the results
df<-data.frame(iter=integer(),pid=integer())
nresults=length(aset)
for (ijk in 1:nresults){
        r<-unlist(aset[ijk])
        df[nrow(df) + 1,]<-c(r)
    }

str(df)
df2<-data.frame(pid=integer(),its=integer(),load=double())
pids<-unique(df['pid'])
for (p in pids[,]) {
    n<-nrow(df[df['pid'] == p,])
    load<-100.0*(n/nt)
    df2[nrow(df2)+1,]<-list(p,n,load)
}
df2<-df2[order(df2$pid),]
print(df2)
