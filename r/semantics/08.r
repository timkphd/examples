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

