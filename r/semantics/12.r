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

