# (14) #########

print("A very simple loop, not in parallel")
bsum=0
nt<-20
myvect<-vector(length=nt)
myvect[1:nt]<-1

bsum<-for (ijk in 2:nt){
	myvect[ijk]<-myvect[ijk-1]+1
}
print(bsum)
print(myvect)
#readline(prompt = "NEXT>")

