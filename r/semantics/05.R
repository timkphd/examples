# (5) #########

print("Same as above but explicitly 'return' a value as columns")
##
ct <- create_cluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt , .combine=cbind ) %dopar% { 
	asum<-asum+ijk
}
print(asum)
print(bsum)

stopCluster(ct)
#readline(prompt = "NEXT>")

