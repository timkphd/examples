# (2) #########

print("Do a very simple parallel loop")
##
#ct <- create_cluster(cores)  
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
foreach(ijk=1:nt ) %dopar% { 
	asum<-asum+ijk
}
print(asum)

print("What happened?")

stopCluster(ct)
#readline(prompt = "NEXT>")

