# (3) #########  (broken)

print("Same as above but explicitly 'return' a value")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

nt<-10
asum=0
bsum<-foreach(ijk=1:nt ) %dopar% { 
	asum<-asum+ijk
  #asum
}
print(asum)
print(bsum)

stopCluster(ct)
#readline(prompt = "NEXT>")

