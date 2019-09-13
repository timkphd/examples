#' A nice timing routine: tymer
#' 
#' @param lab A lable for the output
#' @param reset Reset the timer so dt is measured from current time.
#' @return Returns time since epoch, date string, dt since last call ,dt since first call and an optional lable.'

#' @examples

#'  tymer("first call")
#' [1] "1560955569.153295  2019-06-19 11:02:10       0.000       0.000  first call"
#' > tymer("second call")
#' [1] "1560955569.153295  2019-06-19 11:02:48      37.415      37.415  second call"
#' > tymer("third call")
#' [1] "1560955569.153295  2019-06-19 11:03:04      16.503      53.918  third call"
#' > tymer()
#' [1] "1560955569.153295  2019-06-19 11:03:18      13.544      67.461  "
#' 
#' tymer("do reset",reset=TRUE)
#' [1] "1560955569.153295  2019-06-19 11:04:46       0.000       0.000  do reset"
#' > tymer("after reset")
#' [1] "1560955569.153295  2019-06-19 11:05:01      15.705      15.705  after reset"
#
#   devtools::create("/Users/tkaiser/examples/r/bonk")
#   copy tymer to bonk/R
#   devtools::document("/Users/tkaiser/examples/r/bonk")
tymer <-function(lab="",reset=FALSE) {
  ds=Sys.time()
  now<-as.numeric(ds)
  if (!(exists("tymerstart")) || reset) {
    assign("tymerstart", now, envir = .GlobalEnv)
    assign("lastt", now, envir = .GlobalEnv)
    dt1<-0
    dt2<-0
  } else {
    dt1<-now-lastt
    dt2<-now-tymerstart
    assign("lastt", now, envir = .GlobalEnv)
  }
  b1=format(now,digits=15,nsmall=3,width=15)
  b2=toString(ds)
  b3=format(dt1,digits=3, nsmall=3,width=10)
  b4=format(dt2,digits=3, nsmall=3,width=10)
  paste(b1,b2,b3,b4,lab,sep="  ")
}

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
iter=100
tymer(reset=T)
for (i in 1:iter) {
  x=solve(mymat,b)
}
tymer()
print(paste("size=",size,"  Iterations=",iter))



