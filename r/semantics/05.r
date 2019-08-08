# (5) #########

print("Similar to last run")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##
nt<-10
asum<-0
bsum<-foreach(ijk=1:nt , .combine=cbind ) %dopar% { 
	asum<-asum+ijk
}
print(sum(bsum))

stopCluster(ct)
#readline(prompt = "NEXT>")

