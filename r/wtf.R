library(foreach)
library(doParallel)
library(tictoc)
con=file("threads.txt","r")
linn=readLines(con,1)
nt<-strtoi(linn)
cl <- makeCluster(nt)
registerDoParallel(cl)

x <- iris[which(iris[,5] != "setosa"), c(1,5)]
trials <- 10000
trials <- 20000
tic()
ptime <- system.time({
r <- foreach(icount(trials), .combine=cbind) %dopar% {
  ind <- sample(100, 100, replace=TRUE)
  result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
  coefficients(result1)}
})
tim<-toc()
dt=tim[[2]][[1]]-tim[[1]][[1]]
x<-paste(c(nt,dt))
t<-tempfile(pattern="output")
v<-strsplit(t,"/")
writeLines(x,con=v[[1]][4])

