library(tictoc) 
size <- 4000
mymat <- matrix(nrow=size, ncol=size)
dia <- 10
# For each row and for each column, assign values based on position
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
tic()
b=solve(mymat)
tim<-toc() 
one=sum(b %*% mymat)/size
dt=tim[[2]][[1]]-tim[[1]][[1]]
#dt
one

