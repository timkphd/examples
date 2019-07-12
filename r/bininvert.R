source("tymer.R")
size=1000
mymat <- matrix(0.0,nrow=size, ncol=size)
dia=10
for(i in 1:dim(mymat)[1]) {
    for(j in 1:dim(mymat)[2]) {
      mymat[i,j] <- 0.1
      if ( i == j) {
        mymat[i,j] <- dia
      }
      else {
        mymat[i,j] <- 0.1
      }
    }
}
b<-vector("double",size)
b<-b+10
tymer(reset=T)
for (i in 1:100) {
  x=solve(mymat,b)
}
tymer()



