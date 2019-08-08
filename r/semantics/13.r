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

