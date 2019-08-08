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


