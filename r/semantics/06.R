# (6) #########

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
#readline(prompt = "NEXT>")

