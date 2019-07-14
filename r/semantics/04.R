# (4) #########

print("Same as above but explicitly 'return' a value as rows")
##
ct <- create_cluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt , .combine=rbind ) %dopar% { 
	asum<-asum+ijk
}
print(asum)
print(bsum)

stopCluster(ct)
#readline(prompt = "NEXT>")

