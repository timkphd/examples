#!/usr/bin/env Rscript
 threadfunc <-function() {  
 trd<-c(0)  
 out <- .C("findcore",ic=as.integer(trd),package="thread")  
 return(out$ic)  
 }  
 forceit <-function(core) {  
 trd<-c(core)  
 out <- .C("forcecore",ic=as.integer(trd),package="core")  
 return(out$ic)  
 }  
 p2c <-function(pid,core) { 
 cr<-c(core) 
 pr<-c(pid) 
  out <- .C("p_to_c",ip=as.integer(pr),ic=as.integer(cr),package="ptwoc")  
 return(out$ic)  
} 

t0<-as.numeric(Sys.time()) 
 
library(foreach) 
library(dplyr) 
library(multidplyr) 
library(parallel) 
library(doParallel) 
 
 
set.seed(1) 
rows <- 6*(10^6) 
cols <- 9 

# meth == 1  use partition(V6, V2, V3, V5, V4, cluster = cluster)
# meth == 0  use partition(cluster = cluster)

meth <- 0
 
con<-file("threads.txt","r")  
linn<-readLines(con,1)  
nt<-strtoi(linn) 
# force master to core 23 
dyn.load("mapit.so") 
forceit(23) 

cluster <- create_cluster(nt) 
registerDoParallel(cluster) 

foreach(ijk=1:nt, .combine=cbind) %dopar% { 
	dyn.load("mapit.so")
	docore <- 2+((ijk-1) %% 23) 
	forceit(docore) 
	one<-c(ijk,threadfunc())
}
 
t1<-as.numeric(Sys.time()) 
#tmpData <- as.data.frame(foreach(i = 1:rows, .combine = "rbind") %dopar% { rnorm(cols)}) 
load("/home/timk@colostate.edu/scratch/home/mcandrew/Reproducible_Examples_Space.RData")

# Grow our data set...
y<-rbind(tmpData,2*tmpData)
tmpData<-rbind(y,2*y)

str(tmpData) 
t2<-as.numeric(Sys.time()) 
colnames(tmpData) <- c("V1","V2","V3","V4","V5","V6","V7","V8","V9") 
stopCluster(cluster)  
print(threadfunc())
cluster <- create_cluster(nt) 

foreach(ijk=1:nt, .combine=cbind) %dopar% { 
	dyn.load("mapit.so")
	docore <- 2+((ijk-1) %% 23) 
	forceit(docore) 
	one<-c(ijk,threadfunc())
}
t3<-as.numeric(Sys.time()) 
if( meth == 1) {
createdDF <- tmpData %>% 
   partition(V6, V2, V3, V5, V4, cluster = cluster) %>% 
   group_by(V6, V2, V3, V5, V4) %>% 
   summarize(Data1 = sum(V7), Data2 = sum(V8), Data3 = n()) %>% 
   collect() 
} else {
createdDF <- tmpData %>% 
  partition(cluster = cluster) %>% 
  group_by(V6, V2, V3, V5, V4) %>% 
  summarize(Data1 = sum(V7), Data2 = sum(V8), Data3 = n()) %>% 
  collect() 
}
t4<-as.numeric(Sys.time()) 
stopCluster(cluster) 
print(createdDF) 
newdata <-createdDF[order(createdDF$V6,createdDF$V2,createdDF$V3,createdDF$V5,createdDF$V4),]
head(newdata)
tail(newdata)
t5<-as.numeric(Sys.time()) 

dt1<-t2-t1 
dt2<-t4-t3 
dt3<-t4-t1 
dt4<-t4-t0
dt5<-t5-t4
dt6<-t5-t0
print(c(nt)) 
print(c(t0,t1,t2,t3,t4,t5),digits=13) 
print(c(dt1,dt2,dt3,dt4,dt5,dt6),digits=5) 
#if( meth == 1) {
#	fname<-"/home/timk@colostate.edu/scratch/home/mcandrew/Reproducible_Examples_Space_new"
#} else {
#	fname<-"/home/timk@colostate.edu/scratch/home/mcandrew/Reproducible_Examples_Space_old"
#}
#fname<-paste(fname,toString(nt),sep=".")
#save(createdDF,file=fname) 
q(save = "no")
 
 

