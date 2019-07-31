# (8) #########

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
