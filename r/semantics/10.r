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

