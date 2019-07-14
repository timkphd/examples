# (8) #########

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
#readline(prompt = "NEXT>")

