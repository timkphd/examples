rm(list=ls())
library(parallel)
library(dplyr) 
library(multidplyr) 
library(doParallel)


print("Use 4 cores for our parallel machine")
cores=4


##########

# Do a very simple loop, not in parallel

nt<-10
asum=0
for(ijk in 1:nt ){ 
	asum<-asum+ijk
}
print(asum)

##########

print("Do a very simple parallel loop")
##
ct <- create_cluster(cores)  
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
readline(prompt = "NEXT>")
##########

print("Same as above but explicitly 'return' a value")
##
ct <- create_cluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt ) %dopar% { 
	asum<-asum+ijk
}
print(asum)
print(bsum)

stopCluster(ct)
readline(prompt = "NEXT>")
##########

print("Same as above but explicitly 'return' a value as rows")
##
ct <- create_cluster(cores)  
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
readline(prompt = "NEXT>")
##########

print("Same as above but explicitly 'return' a value as columns")
##
ct <- create_cluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt , .combine=cbind ) %dopar% { 
	asum<-asum+ijk
}
print(asum)
print(bsum)

stopCluster(ct)
readline(prompt = "NEXT>")
##########

print("Work on a matrix")
##
ct <- create_cluster(cores)  
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
readline(prompt = "NEXT>")
##########

print("Same as above but explicitly 'return' a value as columns")

##
ct <- create_cluster(cores)  
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
readline(prompt = "NEXT>")
##########

print("We return the matrix")

##
ct <- create_cluster(cores)  
registerDoParallel(ct)
##

nt<-10
mymat<-matrix(nrow=nt,ncol=nt)
mymat[1:nt,]<-0
bsum=0
bsum<-foreach(ijk = 1:nt, .combine=cbind ) %dopar% { 
	set.seed(ijk) 
	mymat[,ijk]<-rnorm(mymat[,ijk])
	#junk<-sum(mymat[,ijk])
}
print(bsum)


print("BIG QUESTION:  WHY IS THIS DIFFERENT FROM OPENMP?")

stopCluster(ct)
readline(prompt = "NEXT>")
##########

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


##########

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

##########

print("Same loop 'breaks' in parallel")
##
ct <- create_cluster(cores)  
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
readline(prompt = "NEXT>")
##########
