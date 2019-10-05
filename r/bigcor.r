#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
cores<-4
block=500
msize <- 6000
if (length(args) > 2)cores <- as.integer(args[3] )
if (length(args) > 1)block <- as.integer(args[2] )
if (length(args) > 0)msize <- as.integer(args[1] )
print(c(msize,block,cores))
#library(ff)
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
{
  if (!is.null(y) & NROW(x) != NROW(y)) stop("'x' and 'y' must have compatible dimensions!")
   
  NCOL <- ncol(x)
  if (!is.null(y)) YCOL <- NCOL(y)
    
  ## calculate remainder, largest 'size'-divisible integer and block size
  REST <- NCOL %% size
  LARGE <- NCOL - REST  
  NBLOCKS <- NCOL %/% size
    
  ## preallocate square matrix of dimension
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
    RES <- cor(x[, G1], x[, G2], ...)
    resMAT[G1, G2] <- RES
    resMAT[G2, G1] <- t(RES) 
  } 
  
  return(resMAT)
}

smallcor <- function(
x, 
y=NULL,
size = 2000, 
verbose = TRUE, 
...)
{
   
  NCOL <- ncol(x)
  if (!is.null(y)) YCOL <- NCOL(y)
    
  ## calculate remainder, largest 'size'-divisible integer and block size
  REST <- NCOL %% size
  LARGE <- NCOL - REST  
  NBLOCKS <- NCOL %/% size
    
  ## preallocate square matrix of dimension
  resMAT <- matrix(0.0,NCOL, NCOL)  
 
  ## split column numbers into 'nblocks' groups + remaining block
  GROUP <- rep(1:NBLOCKS, each = size)
  if (REST > 0) GROUP <- c(GROUP, rep(NBLOCKS + 1, REST))
  SPLIT <- split(1:NCOL, GROUP)
  
  ## create all unique combinations of blocks
  COMBS <- expand.grid(1:length(SPLIT), 1:length(SPLIT))
  COMBS <- t(apply(COMBS, 1, sort))
  COMBS <- unique(COMBS)  
  
  ## initiate time counter
  timeINIT <- proc.time() 
  
  ## iterate through each block combination, calculate correlation matrix
  ## between blocks and store them in the preallocated matrix on both
  ## symmetric sides of the diagonal
  for (i in 1:nrow(COMBS)) {
    COMB <- COMBS[i, ]    
    G1 <- SPLIT[[COMB[1]]]
    G2 <- SPLIT[[COMB[2]]]    
    RES <- cor(x[, G1], x[, G2], ...)
    #print(c("RES",str(RES)))
    resMAT[G1, G2] <- RES
    resMAT[G2, G1] <- t(RES) 
  } 
  
  return(resMAT)
}

parcor <- function(
x, 
y=NULL,
size = 2000, 
verbose = TRUE, 
fun = smallcor,
...)
{
  #print(fun(x))
  NCOL <- ncol(x)
  if (!is.null(y)) YCOL <- NCOL(y)
    
  ## calculate remainder, largest 'size'-divisible integer and block size
  REST <- NCOL %% size
  LARGE <- NCOL - REST  
  NBLOCKS <- NCOL %/% size
    
  ## preallocate square matrix of dimension
  resMAT <- matrix(0.0,NCOL, NCOL)  
 
  ## split column numbers into 'nblocks' groups + remaining block
  GROUP <- rep(1:NBLOCKS, each = size)
  if (REST > 0) GROUP <- c(GROUP, rep(NBLOCKS + 1, REST))
  SPLIT <- split(1:NCOL, GROUP)
  
  ## create all unique combinations of blocks
  COMBS <- expand.grid(1:length(SPLIT), 1:length(SPLIT))
  COMBS <- t(apply(COMBS, 1, sort))
  COMBS <- unique(COMBS)  
  
  ## initiate time counter
  timeINIT <- proc.time() 
  
  ## iterate through each block combination, calculate correlation matrix
  ## between blocks and store them in the preallocated matrix on both
  ## symmetric sides of the diagonal
  #res<-foreach(i = 1:nrow(COMBS),.verbose=FALSE,.combine = cbind,
  # .packages = c('data.table', 'doParallel')) %dopar% {
  print(c("COMBS",nrow(COMBS)))
  res<-foreach(i = 1:nrow(COMBS),.verbose=FALSE,
                .inorder = FALSE) %dopar% {
    COMB <- COMBS[i, ]    
    G1 <- SPLIT[[COMB[1]]]
    G2 <- SPLIT[[COMB[2]]]    
    #RES <- list(G1,G2,c(fun(x[, G1], x[, G2], ...)))
    RES <- list(G1,G2,c(fun(x[, G1], x[, G2])))
    
  } 
 for (b in 1:(nrow(COMBS))) {
    bonk=res[b]
    G1<-bonk[[1]][[1]]
    G2<-bonk[[1]][[2]]
    #crap<-matrix(bonk[[1]][[3]],10,10)
	resMAT[G1,G2] <- matrix(bonk[[1]][[3]],length(G1),length(G2))
	resMAT[G2,G1]  <- t(resMAT[G1,G2])
	}

  return(resMAT)
}


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
library(dplyr)
library(parallel)
library(doParallel)
source("~/bin/tymer.r")

tymer("start t1")
t1<-cor(mymat)
tymer("done t1")
tymer("start t2")
#t2<-bigcor(mymat,mymat,size=block,verbose=FALSE,fun="cor")
tymer("done t2")
tymer("start t3")
#t3<-smallcor(mymat,size=block,verbose=FALSE)
tymer("done t3")
tymer("start cores")
cluster <- makeCluster(cores)  
registerDoParallel(cluster)  
tymer("start t4")
t4<-parcor(mymat,size=block,verbose=FALSE,fun=bigcor)
tymer("done t4")
tymer("start t5")
t5<-parcor(mymat,size=block,verbose=FALSE,fun=cor)
tymer("done t5")
#print(sum(abs(t1-t2)))
#print(sum(abs(t1-t3)))
print(sum(abs(t1-t4)))
print(sum(abs(t1-t5)))
