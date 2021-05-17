#!/usr/bin/env Rscript
if(FALSE){
library(parallel,quietly = TRUE)
library(doParallel,quietly = TRUE)
}
library(foreach,quietly = TRUE)
library(dplyr,quietly = TRUE)

source("tymer.R")
if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <<- mpi.comm.rank(comm=mpi_comm_world)
numprocs <<- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()
print(c(myid,myname,numprocs))

#### Reproducible example for "unused argument" error

set.seed(1)
rows <- 60000
cols <- 9

if(myid == 0)tymer("at 1",reset=TRUE)
if(FALSE){
## example from https://blog.aicry.com/r-parallel-computing-in-5-minutes/
system.time(foreach(i=1:rows) %dopar% sum(tanh(1:i)))
results <- foreach(i=1:rows, .combine = "rbind") %dopar% {
  data.frame(feature=rnorm(10))
}
class(results)
}
if(myid == 0)tymer("at 2")

## creating a DF that is like our analytics data
dr<-round(rows/numprocs)
rstart<-myid*dr+1
rend<-(myid+1)*dr
if(myid == numprocs-1) {
	rend<-rows
}
tmpData <- as.data.frame(foreach(i = rstart:rend, .combine = "rbind") %do%
{
  set.seed(i)
  c(sample(c("CCCCCC","OOOO"),1),
    as.character(sample(c(5000:7000),1)),
    as.character(sample(c(5000:7000),1)),
    as.numeric(sample(c(2000:3000),1)),
    as.numeric(sample(c(2000:3000),1)),
    as.numeric(sample(c(25000000:25000033),1)),
    sample(c(1:25),1),
    sample(c(60:1800),1),
    sample(c(1:100),1))
}
)
if(myid == 0)tymer("at 3")
#if(myid == 0)head(tmpData)
colnames(tmpData) <- c("V1","V2","V3","V4","V5","V6","V7","V8","V9")
rownames(tmpData) <- NULL
tmpData$V1 <- as.character(tmpData$V1)
tmpData$V2 <- as.character(tmpData$V2)
tmpData$V3 <- as.character(tmpData$V3)
tmpData$V4 <- as.numeric(levels(tmpData$V4)[tmpData$V4])
tmpData$V5 <- as.numeric(levels(tmpData$V5)[tmpData$V5])
tmpData$V6 <- as.numeric(levels(tmpData$V6)[tmpData$V6])
tmpData$V7 <- as.integer(levels(tmpData$V7)[tmpData$V7])
tmpData$V8 <- as.numeric(levels(tmpData$V8)[tmpData$V8])
tmpData$V9 <- as.numeric(levels(tmpData$V9)[tmpData$V9])
#str(tmpData)
if(myid == 0)tymer("at 4")

if(myid == 0)tymer("at 5")
tmp <- tmpData %>% group_by(V6, V2, V3, V5, V4) %>% summarize(Data1 = sum(V7), Data2 = sum(V8), Data3 = n())
print(c(myid,"did it"))
#print(tmp)
if(myid == 0)tymer("at 6")
z<-paste("f",myid,sep="_")
write.csv(tmp,file=z)
bonk<-mpi.finalize()

