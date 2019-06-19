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
	b1=format(now,digits=3,nsmall=3,width=13)
	b2=toString(ds)
	b3=format(dt1,digits=3, nsmall=3,width=10)
	b4=format(dt2,digits=3, nsmall=3,width=10)
	paste(bonk,b2,b3,b4,lab,sep="  ")
}