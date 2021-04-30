#!/usr/bin/env Rscript
#' A nice timing routine: tymer
#' 
#' @param lab A label for the output
#' @param reset Reset the timer so dt is measured from current time.
#' @return Returns time since epoch, date string, dt since last call ,dt since first call and an optional label.'

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
#   usethis::create_package("/Users/tkaiser/examples/r/bonk")
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
	print(paste(b1,b2,b3,b4,lab,sep="  "))
}
