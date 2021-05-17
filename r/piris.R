#!/usr/bin/env Rscript
# start the cluster

library(foreach)
library(doParallel)
library(tictoc)
numprocs<-parallel::detectCores()
cl <- makeCluster(numprocs)
registerDoParallel(cl)

#get our dataset
library(datasets)
set1<-iris[iris$Species == "setosa", ]

#figure out how we are going to split it
each<-as.integer(nrow(set1)/numprocs)
bots<-integer(numprocs)
  tops<-integer(numprocs)
  for (n in 1:numprocs) {
    bots[n]<-(n-1)*each+1
    tops[n]<-bots[n]+each-1
  }
tops[numprocs]=nrow(set1)
cat("bots",bots,"\n")
cat("tops",tops,"\n")

#run analysis in parallel
aset <- foreach (ijk=1:length(bots)) %dopar% {
    myset<-set1[bots[ijk]:tops[ijk],]
    aset<-c(sum(myset[["Sepal.Length"]]),sum(myset[["Sepal.Width"]]),sum(myset[["Petal.Length"]]),sum(myset[["Petal.Width"]]),tops[ijk]-bots[ijk]+1,Sys.getpid())
    }

str(aset)

stopCluster(cl)

#reduce the data
df<-data.frame(sl=double(),sw=double(),pl=double(),pw=double(),vals=double(),pid=integer())
for (ijk in 1:4){
		df[nrow(df) + 1,] <-aset[[ijk]]
	}
df
colSums(df[,1:4])/sum(df[['vals']])