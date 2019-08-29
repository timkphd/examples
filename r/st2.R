library(foreach,quietly = TRUE)
library(dplyr,quietly = TRUE)
library(parallel,quietly = TRUE)
library(doParallel,quietly = TRUE)
source("tymer.R")


#### Reproducible example for "unused argument" error

set.seed(1)
rows = 60000
cols = 9

nCores <- detectCores()-4
nCores <-4
cluster <- makeCluster(nCores)
registerDoParallel(cluster)
getDoParWorkers()
tymer("at 1",reset=TRUE)
if(FALSE){
## example from https://blog.aicry.com/r-parallel-computing-in-5-minutes/
system.time(foreach(i=1:rows) %dopar% sum(tanh(1:i)))
results <- foreach(i=1:rows, .combine = "rbind") %dopar% {
  data.frame(feature=rnorm(10))
}
class(results)
}
tymer("at 2")

## creating a DF that is like our analytics data
tmpData <- as.data.frame(foreach(i = 1:rows, .combine = "rbind") %dopar% {
  set.seed(i)
  c(sample(c("CCCCCC","OOOO"),1),
    as.character(sample(c(5000:7000),1)),
    as.character(sample(c(5000:7000),1)),
    as.numeric(sample(c(2000:3000),1)),
    as.numeric(sample(c(2000:3000),1)),
    as.numeric(sample(c(25000000:25000033),1)),
    sample(c(1:25),1),
    sample(c(60:1800),1),
    sample(c(1:100),1))
})
tymer("at 3")

colnames(tmpData) <- c("V1","V2","V3","V4","V5","V6","V7","V8","V9")
rownames(tmpData) <- NULL
tmpData$V1 <- as.character(tmpData$V1)
tmpData$V2 <- as.character(tmpData$V2)
tmpData$V3 <- as.character(tmpData$V3)
tmpData$V4 <- as.numeric(levels(tmpData$V4)[tmpData$V4])
tmpData$V5 <- as.numeric(levels(tmpData$V5)[tmpData$V5])
tmpData$V6 <- as.numeric(levels(tmpData$V6)[tmpData$V6])
tmpData$V7 <- as.integer(levels(tmpData$V7)[tmpData$V7])
tmpData$V8 <- as.numeric(levels(tmpData$V8)[tmpData$V8])
tmpData$V9 <- as.numeric(levels(tmpData$V9)[tmpData$V9])
#str(tmpData)
tymer("at 4")
z<-paste("x",0,sep="_")
write.csv(tmpData,file=z)

tymer("at 5")
## foreach testing of our initial analytics step
createdDF <- as.data.frame(foreach(i = 1:nCores, .combine = "rbind", .packages = c("dplyr")) %dopar% {
  inds <- seq(from=(i-1)*ceiling(nrow(tmpData)/nCores)+1, to=min(i*ceiling(nrow(tmpData)/nCores),nrow(tmpData)), by=1)
  #print(inds)
  tmp <- tmpData[inds, ] %>%
    group_by(V6, V2, V3, V5, V4) %>%
    summarize(Data1 = sum(V7), Data2 = sum(V8), Data3 = n())
  return(tmp)
})
#dim(createdDF)
tymer("at 6")
z<-paste("y",0,sep="_")
write.csv(createdDF,file=z)

stopCluster(cluster)
