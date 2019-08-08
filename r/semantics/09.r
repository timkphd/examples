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

