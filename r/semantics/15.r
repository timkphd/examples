# (15) #########

print("Same loop 'breaks' in parallel")
##
ct <- makeCluster(cores)  
registerDoParallel(ct)
##

bsum=0
nt<-20
myvect[1:nt]<-1

bsum<-foreach(ijk = 2:nt ) %dopar% { 
	myvect[ijk]<-myvect[ijk-1]+1
}
print(bsum)
print(myvect)

stopCluster(ct)
#readline(prompt = "NEXT>")

##########