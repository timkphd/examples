#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
cores<-4
block=10
msize <- 100
if (length(args) > 2)cores <- as.integer(args[3] )
if (length(args) > 1)block <- as.integer(args[2] )
if (length(args) > 0)msize <- as.integer(args[1] )
print(c(msize,block,cores))
#library(ff)
mpicor <- function(
x, 
y = NULL,
fun = c("cor", "cov"), 
size = 2000, 
verbose = TRUE, 
...)
{
STR="parallel "
## send data to each task
	myid <<- mpi.comm.rank(comm=mpi_comm_world)
	numprocs <<- mpi.comm.size(comm=mpi_comm_world)
	if (myid == 0){
		ncol1=ncol(x)
		nrow1=nrow(x)
		if (is.null(y)){
			ncol2=0
			nrow2=0
		}
		else {
			ncol2=ncol(y)
			nrow2=nrow(y)
		}
	}
	else {
	ncol1<-0
	nrow1<-0
	ncol2<-0
	nrow2<-0
	size<-0
	}
 ncol1<-mpi.bcast(ncol1,    type=1,comm = mpi_comm_world)
 nrow1<-mpi.bcast(nrow1,    type=1,comm = mpi_comm_world)
 ncol2<-mpi.bcast(ncol2,    type=1,comm = mpi_comm_world)
 nrow2<-mpi.bcast(nrow2,    type=1,comm = mpi_comm_world)
 FUN <- cor
 size<-mpi.bcast(size,    type=1,comm = mpi_comm_world)
 verbose = TRUE
 

#  fun <- match.arg(fun)
#  if (fun == "cor") FUN <- cor else FUN <- cov
#  if (fun == "cor") STR <- "Correlation" else STR <- "Covariance" 
#  if (!is.null(y) & NROW(x) != NROW(y)) stop("'x' and 'y' must have compatible dimensions!")
   
  NCOL <- ncol1
  YCOL <- ncol2
  if (YCOL == 0) {
  	y=NULL
# if y is null then we will need all of X on each node
# since it replaces y
    if(myid == 0 ){
    print("before")
    print(str(x))
    }
  	mpi.bcast.Robj(x,comm = mpi_comm_world)  	
    if(myid > -1 ){
    print("after")
    print(str(x))
    }
  } 
  else {
# bcast all of y to each task  
	y<-mpi.bcast.Robj(y,comm = mpi_comm_world)
  } 
  ## calculate remainder, largest 'size'-divisible integer and block size
  REST <- NCOL %% size
  LARGE <- NCOL - REST  
  NBLOCKS <- NCOL %/% size
    
  if (myid == 0){
  	if (is.null(y)) resMAT <- matrix(0.0,NCOL, NCOL)  
  	else resMAT <- matrix(0.0,NCOL, YCOL)
  }
 
  ## split column numbers into 'nblocks' groups + remaining block
  GROUP <- rep(1:NBLOCKS, each = size)
  if (REST > 0) GROUP <- c(GROUP, rep(NBLOCKS + 1, REST))
  SPLIT <- split(1:NCOL, GROUP)
  
  ## create all unique combinations of blocks
  COMBS <- expand.grid(1:length(SPLIT), 1:length(SPLIT))
  COMBS <- t(apply(COMBS, 1, sort))
  COMBS <- unique(COMBS)  
  if (!is.null(y)) COMBS <- cbind(1:length(SPLIT), rep(1, length(SPLIT)))
  
  ## initiate time counter
  timeINIT <- proc.time() 
  if(myid == 1){
  	print(COMBS)
  	print(SPLIT)
  }
   lc<-nrow(COMBS)
   ea<-lc/numprocs
   start_block<-as.integer(myid*ea+1)
   end_block<-as.integer((myid+1)*ea)
   if(myid == numprocs-1)end_block<-lc
   
 
  if (is.null(y)) {
    if(myid == -1) {
  		print(x)
  	}

# every task has all of the data
# each just needs to do its portion
if(myid > -1 ) {
  print(str(x))
  RES=list(1)
  k=1
  print(c("blocks",myid,start_block,end_block))
	  for (i in start_block:end_block) {
		COMB <- COMBS[i, ]    
		G1 <- SPLIT[[COMB[1]]]
		G2 <- SPLIT[[COMB[2]]]  
		if(myid == 0 ) {
cat(sprintf("#%d: %s of Block %s and Block %s (%s x %s) ... ", i, STR,  COMB[1],
                               COMB[2], length(G1),  length(G2))) 		}
		RES[[k]] <-  FUN(x[, G1], x[, G2], ...)
		k<-k+1
	  }
  if(myid == 3) {
  print(str(RES))
  print(RES)
  }
  }

  }
  print("calling finalize")
  bonk<-mpi.finalize()
  q()  

  ## iterate through each block combination, calculate correlation matrix
  ## between blocks and store them in the preallocated matrix on both
  ## symmetric sides of the diagonal
  for (i in 1:nrow(COMBS)) {
    COMB <- COMBS[i, ]    
    G1 <- SPLIT[[COMB[1]]]
    G2 <- SPLIT[[COMB[2]]]    
    
    ## if y = NULL
    if (is.null(y)) {
      if (verbose) cat(sprintf("#%d: %s of Block %s and Block %s (%s x %s) ... ", i, STR,  COMB[1],
                               COMB[2], length(G1),  length(G2)))      
      RES <- FUN(x[, G1], x[, G2], ...)
      resMAT[G1, G2] <- RES
      resMAT[G2, G1] <- t(RES) 
    } else ## if y = smaller matrix or vector  
    {
      if (verbose) cat(sprintf("#%d: %s of Block %s and 'y' (%s x %s) ... ", i, STR,  COMB[1],
                               length(G1),  YCOL))    
      RES <- FUN(x[, G1], y, ...)
      resMAT[G1, ] <- RES             
    }
    
    if (verbose) {
      timeNOW <- proc.time() - timeINIT
      cat(timeNOW[3], "s\n")
    }
    
    gc()
  } 
  
  return(resMAT)
}


bigcor <- function(
x, 
y = NULL,
fun = c("cor", "cov"), 
size = 2000, 
verbose = TRUE, 
...)
{
  fun <- match.arg(fun)
  if (fun == "cor") FUN <- cor else FUN <- cov
  if (fun == "cor") STR <- "Correlation" else STR <- "Covariance" 
  if (!is.null(y) & NROW(x) != NROW(y)) stop("'x' and 'y' must have compatible dimensions!")
   
  NCOL <- ncol(x)
  if (!is.null(y)) YCOL <- NCOL(y)
    
  ## calculate remainder, largest 'size'-divisible integer and block size
  REST <- NCOL %% size
  LARGE <- NCOL - REST  
  NBLOCKS <- NCOL %/% size
    
  ## preallocate square matrix of dimension
  ## ncol(x) in 'ff' single format
  #if (is.null(y)) resMAT <- ff(vmode = "double", dim = c(NCOL, NCOL))  
  #else resMAT <- ff(vmode = "double", dim = c(NCOL, YCOL))
  if (is.null(y)) resMAT <- matrix(0.0,NCOL, NCOL)  
  else resMAT <- matrix(0.0,NCOL, YCOL)
 
  ## split column numbers into 'nblocks' groups + remaining block
  GROUP <- rep(1:NBLOCKS, each = size)
  if (REST > 0) GROUP <- c(GROUP, rep(NBLOCKS + 1, REST))
  SPLIT <- split(1:NCOL, GROUP)
  
  ## create all unique combinations of blocks
  COMBS <- expand.grid(1:length(SPLIT), 1:length(SPLIT))
  COMBS <- t(apply(COMBS, 1, sort))
  COMBS <- unique(COMBS)  
  if (!is.null(y)) COMBS <- cbind(1:length(SPLIT), rep(1, length(SPLIT)))
  
  ## initiate time counter
  timeINIT <- proc.time() 
  
  ## iterate through each block combination, calculate correlation matrix
  ## between blocks and store them in the preallocated matrix on both
  ## symmetric sides of the diagonal
  for (i in 1:nrow(COMBS)) {
    COMB <- COMBS[i, ]    
    G1 <- SPLIT[[COMB[1]]]
    G2 <- SPLIT[[COMB[2]]]    
    
    ## if y = NULL
    if (is.null(y)) {
      if (verbose) cat(sprintf("#%d: %s of Block %s and Block %s (%s x %s) ... ", i, STR,  COMB[1],
                               COMB[2], length(G1),  length(G2)))      
      RES <- FUN(x[, G1], x[, G2], ...)
      resMAT[G1, G2] <- RES
      resMAT[G2, G1] <- t(RES) 
    } else ## if y = smaller matrix or vector  
    {
      if (verbose) cat(sprintf("#%d: %s of Block %s and 'y' (%s x %s) ... ", i, STR,  COMB[1],
                               length(G1),  YCOL))    
      RES <- FUN(x[, G1], y, ...)
      resMAT[G1, ] <- RES             
    }
    
    if (verbose) {
      timeNOW <- proc.time() - timeINIT
      cat(timeNOW[3], "s\n")
    }
    
    gc()
  } 
  
  return(resMAT)
}

smallsav <- function(
x, 
y = NULL,
size = 2000, 
verbose = TRUE, 
...)
{}

smallcor <- function(
x, 
y=NULL,
size = 2000, 
verbose = TRUE, 
...)
{}

parcor <- function(
x, 
y=NULL,
size = 2000, 
verbose = TRUE, 
fun = smallcor,
...)
{}

mymat <- matrix(nrow=msize, ncol=msize)
# should most likely do this instead of the else mymat <- matrix(0.1,nrow=size, ncol=size)

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
  	  mymat[i,j] <- i+1000*j
  	}
  }
}
nsize<-msize/2
mat2 <- matrix(100.0,nrow=msize, ncol=nsize)
for(i in 1:dim(mat2)[1]) {
  for(j in 1:dim(mat2)[2]) {
    mat2[i,j] <- 0.1
  	if ( i == j) {
  	  mat2[i,j] <- dia
  	}
  	else {
  	  mat2[i,j] <- 0.1
  	  mat2[i,j] <- i+1000*j
  	}
  }
}

source("~/bin/tymer.r")
if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <<- mpi.comm.rank(comm=mpi_comm_world)
numprocs <<- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()

t3<-mpicor(mymat,size=block,verbose=TRUE,fun="cor")

tymer("start t1")
t1<-cor(mymat,mat2)
tymer("done t1")
tymer("start t2")
t2<-bigcor(mymat,size=block,verbose=FALSE,fun="cor")
tymer("done t2")
tymer("start t3")
tymer("done t3")
print(sum(abs(t1-t2)))
print(sum(abs(t1-t3)))
