#!/usr/bin/env Rscript
dyn.load("mapit.so")
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

library(foreach)
library(doParallel)
library(tictoc) 
con=file("threads.txt","r")
linn<-readLines(con,1)
nt<-strtoi(linn)
cl <- makeCluster(nt)
registerDoParallel(cl)
size <- 2000
tic()
ptime <- system.time({
	r <- foreach(ijk=1:nt, .combine=cbind) %dopar% {
	    dyn.load("mapit.so")
		dia <- 0.1
		docore <- 1+((ijk-1) %% 23)
		forceit(docore)
		# For each row and for each column, assign values based on position
		mymat <- matrix(10.0,nrow=size, ncol=size)
		for(i in 1:dim(mymat)[1]) {
			  mymat[i,i] <- dia
		}
		b <- solve(mymat)
		one=c(ijk,threadfunc())
	}
})
tim<-toc() 
dt<-tim[[2]][[1]]-tim[[1]][[1]]
stats<-c("results",nt,dt)
print(stats)
#print(r)
x<-paste(c(c(nt,dt),r[2,]))
x<-paste(nt,dt,sep=":")
t<-tempfile(pattern="output")
v<-strsplit(t,"/")
con <- file(v[[1]][4],"w")
vect <- 1:nt
for(ijk in 1:nt) {
	vect[ijk]=r[2,ijk]
}
svect <- sort(vect)
#print(r)
#print(svect)
writeLines(paste(c(x)),con=con,sep = "\n")
writeLines(paste(c(svect)),con=con,sep = " ")
writeLines(" ",con=con,sep = "\n")


