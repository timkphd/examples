#!/usr/bin/env Rscript
# (0) #########
rm(list=ls())
library(parallel)
library(dplyr) 
#library(multidplyr) 
library(doParallel)
print("Use 4 cores for our parallel machine")
cores=4


# (1) #########

print("Do a very simple loop, not in parallel")

nt<-10
asum=0
for(ijk in 1:nt ){ 
	asum<-asum+ijk
}
print(asum)
#readline(prompt = "NEXT>")

# (2) #########

print("Do a very simple parallel loop")
##
#ct <- create_cluster(cores)  
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
foreach(ijk=1:nt ) %dopar% { 
	asum<-asum+ijk
}
print(asum)

print("What happened?")

stopCluster(ct)
#readline(prompt = "NEXT>")

# (3) #########  (broken)

print("Same as above but explicitly 'return' a value")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt ) %dopar% { 
	asum<-asum+ijk
}
print(c("asum",asum))
print(c("bsum",bsum))

stopCluster(ct)
#readline(prompt = "NEXT>")

# (4) #########  (broken)

print("Same as above but explicitly 'return' a value as rows")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt , .combine=rbind ) %dopar% { 
	asum<-asum+ijk
}
print(asum)
print(bsum)

stopCluster(ct)
#readline(prompt = "NEXT>")

# (5) #########

print("Similar to last run")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##
nt<-10
asum<-0
bsum<-foreach(ijk=1:nt , .combine=cbind ) %dopar% { 
	asum<-asum+ijk
}
print(sum(bsum))

stopCluster(ct)
#readline(prompt = "NEXT>")

# (6) #########

print("Add process ID to the output")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##
if(!exists("doprint")){doprint=FALSE}
nt<-10
asum<-0
bsum<-foreach(ijk=1:nt , .combine=rbind ) %dopar% { 
	asum<-asum+ijk
	pid<-Sys.getpid()
	c(pid,asum)
}
if(doprint){
	#print(bsum)
	print(bsum[order(bsum[,1]),])
}
print(sum(bsum[,2]))

stopCluster(ct)
#readline(prompt = "NEXT>")


# (7) ######### (skip this one)

print("Work on a matrix")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
mymat<-matrix(nrow=nt,ncol=nt)
mymat[1:nt,]<-0
asum=0
bsum=0
bsum<-foreach(ijk = 1:nt ) %dopar% { 
	set.seed(ijk) 
	mymat[,ijk]<-rnorm(mymat[,ijk])
	junk<-sum(mymat[,ijk])
}
print(bsum)
print(sum(mymat))

stopCluster(ct)
#readline(prompt = "NEXT>")

# (8) #########

print("Same as above but explicitly 'return' a value as columns")

##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
mymat<-matrix(nrow=nt,ncol=nt)
mymat[1:nt,]<-0
bsum=0
bsum<-foreach(ijk = 1:nt, .combine=cbind ) %dopar% { 
	set.seed(ijk) 
	mymat[,ijk]<-rnorm(mymat[,ijk])
	junk<-sum(mymat[,ijk])
}
print(bsum)
print(mymat)

stopCluster(ct)
#readline(prompt = "NEXT>")

# (9) #########

writeLines("Now for some examples that actually work")
writeLines("but maybe not the way you expected.")
writeLines("The export may generate a warning.")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##
if(!exists("doverbose")){doverbose=FALSE}
nt<-10
asum<-0
writeLines("\nasum is zero")
bsum<-foreach(ijk=1:nt , .combine=cbind, .export=(c('asum'))) %dopar% { 
	asum<-2**ijk
	asum
}
print(asum)
print(bsum)


#readline(prompt = "NEXT>")

nt<-10
asum<-vector(mode="double",length=nt)
writeLines("\nasum is vector of zero")

bsum<-foreach(ijk=1:nt , .combine=cbind,.export=(c('asum')) ) %dopar% { 
	asum<-2**ijk
	asum
}
print(asum)
print(bsum)

asum=vector(mode="double",length=nt)+2000
writeLines("\nasum is vector of 2000")
bsum<-foreach(ijk=1:nt , .combine=cbind,.export=(c('asum')) ) %dopar% { 
	asum<-2**ijk
	asum
}
print(asum)
print(bsum)

stopCluster(ct)
#readline(prompt = "NEXT>")

# (10) #########

writeLines("We move asum to the right hand size")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)

asum<-5
writeLines("\nasum is  scalar on the right hand side")

bsum<-foreach(ijk=1:nt , .combine=rbind ,.export=(c('asum')),.verbose=doverbose) %dopar% { 
	xsum<-asum*ijk
	
}
print(asum)
print(bsum)


asum=vector(mode="double",length=5)
writeLines("\nasum is vector of on length 5 on the right hand side")

for (ijk in 1:length(asum))asum[ijk]<-asum[ijk]+ijk

bsum<-foreach(ijk=1:nt , .combine=rbind ,.export=(c('asum')),.verbose=doverbose) %dopar% { 
	xsum<-asum*ijk
}
print(asum)
print(bsum)

asum=vector(mode="double",length=15)
writeLines("\nasum is vector of on length 15 on the right hand side")
writeLines("We add the pid for each task/iteration to the output")
for (ijk in 1:length(asum))asum[ijk]<-asum[ijk]+ijk

bsum<-foreach(ijk=1:nt , .combine=rbind,.verbose=doverbose) %dopar% { 
	xsum<-asum+ijk*1000
	pid<-Sys.getpid()
	c(pid,xsum)
}
print(asum)
print(bsum)
print(bsum[order(bsum[,1]),])


stopCluster(ct)
#readline(prompt = "NEXT>")

# (11) ######### (skip this one)

print("Work on a matrix")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##
if(!exists("mymean")){mymean=0}
nt<-8
mymat<-matrix(nrow=nt,ncol=nt)
mymat[1:nt,]<-mymean

bsum<-foreach(ijk = 1:nt, .combine=cbind ) %dopar% { 
	set.seed(ijk) 
# note: the length for rnorm is ignored but needed or you get an error
	mymat[,ijk]<-rnorm(nt,mean=mymat[,ijk])
	junk<-c(length(mymat[,ijk]),sum(mymat[,ijk]))
}
print(bsum)
print(sum(mymat))

stopCluster(ct)
#readline(prompt = "NEXT>")

# (12) #########

print("Work on a matrix")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##
if(!exists("mymean")){mymean=0}
nt<-8
mymat<-matrix(nrow=nt,ncol=nt)
mymat[1:nt,]<-mymean

csum<-foreach(ijk = 1:nt, .combine=cbind ) %dopar% { 
	set.seed(ijk) 
# note: the length for rnorm is ignored but needed or you get an error
	junk<-rnorm(nt,mean=mymat[,ijk])
}
print(csum)
bonk=vector(mode="double",length=nt)
for (i in 1:nt){bonk[i]=sum(csum[,i])}
print(bonk)
print(sum(mymat))

print("BIG QUESTION:  WHY IS THIS DIFFERENT FROM OPENMP?")

stopCluster(ct)
#readline(prompt = "NEXT>")

##########

# (13) #########

print("Not in parallel")
nt<-10
mymat<-matrix(nrow=nt,ncol=nt)
mymat[1:nt,]<-0
bsum=0
bsum<-for(ijk in 1:nt  )  { 
	set.seed(ijk) 
	mymat[,ijk]<-rnorm(mymat[,ijk])
}
print(bsum)
print(mymat)
#readline(prompt = "NEXT>")

# (14) #########

print("A very simple loop, not in parallel")
bsum=0
nt<-20
myvect<-vector(length=nt)
myvect[1:nt]<-1

bsum<-for (ijk in 2:nt){
	myvect[ijk]<-myvect[ijk-1]+1
}
print(bsum)
print(myvect)
#readline(prompt = "NEXT>")

# (15) #########

print("Same loop 'breaks' in parallel")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

bsum=0
nt<-20
myvect[1:nt]<-1

bsum<-foreach(ijk = 2:nt ) %dopar% { 
	myvect[ijk]<-myvect[ijk-1]+1
}
print(bsum)
print(myvect)

stopCluster(ct)
#readline(prompt = "NEXT>")

##########