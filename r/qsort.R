#!/usr/bin/env Rscript
#https://cran.r-project.org/web/packages/foreach/foreach.pdf
# clear stuff
rm(list=ls())

qsort <- function(x) {
  n <- length(x)
  if (n == 0) {
    x
  } else {
    p <- sample(n, 1)
#    smaller <- foreach(y=x[-p], .combine=c) %:% when(y <= x[p]) %do% y
#    smaller <- foreach(y=x[-p], .combine=c) %:% when(y <= x[p]) %d0% y
    smaller <- foreach(y=x[-p], .combine=c) %:% when(y <= x[p]) %dopar% y
    larger  <- foreach(y=x[-p], .combine=c) %:% when(y > x[p]) %dopar% y
    c(qsort(smaller), x[p], qsort(larger))
  }
}
library(parallel)
library(dplyr)
library(doParallel)
print("Use 4 cores for our parallel machine")
cores=4
ct <- makeCluster(cores)
registerDoParallel(ct)

years=c(2017,2018,2019,2025,2026,2021,2022,2040,2052,2036,2020,2032,2044,2028)
syears<-qsort(years)
print(syears)
stopCluster(ct)
