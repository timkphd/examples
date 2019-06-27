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

# assume energy goes as (10^mag)/(d^2.5)
whack <- function(lat1,lon1,lat2,lon2,mag,dep) {
	lat1<-lat1*0.01745329
	lat2<-lat2*0.01745329
	lon1<-lon1*0.01745329
	lon2<-lon2*0.01745329
	d <- 6377.83 * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2-lon1))
	d <- sqrt(d*d+dep*dep)
	if(mag > 0.0){
	i <-(10^mag)/(d^2.5)
	} else {
	i=0
	}
	return(i)
}


library(stringr)
if (!is.loaded("mpi_initialize")) {     
    library("Rmpi")     
    }  
mpi_comm_world<-0 
myid <- mpi.comm.rank(comm=mpi_comm_world)
numprocs <- mpi.comm.size(comm=mpi_comm_world)
myname <- mpi.get.processor.name()
source<-0;
paste("I am",myid,"of",numprocs,"on",myname)

# here we assume each task will read in its own data
mysub<-str_replace_all(format(myid,digits=4,width=4)," ","0")
mycwd<-getwd()
to<-paste(mycwd,"/",mysub,sep="")

l1<-myid %/% 26 +1
l2 <- myid %% 26 +1
rfile<-paste("realsx",letters[l1],letters[l2],sep="")
ifile<-paste("intsx",letters[l1],letters[l2],sep="")
afile<-paste("asciix",letters[l1],letters[l2],sep="")
print(paste(rfile,ifile,afile))

# read in our character data
chars<-read.csv(afile,header=F)
lines=nrow(chars)
names(chars)<-c("le","ct","poly")

# read in our real data
reals<-readBin(rfile,what="double",n=lines*10)
r<-matrix(reals,lines,byrow=T)
rm(reals)
rdf=as.data.frame(r)
rm(r)
names(rdf) <- c("second","latitude","longitude","depth","SCSN","residual","stdpos","stddepth","stdhorrel","stddeprel")

# read in our integer data
ints<-readBin(ifile,what="int",n=lines*13)
i<-matrix(ints,lines,byrow=T)
rm(ints)
idf=as.data.frame(i)
rm(i)
names(idf) <- c("year","month","day","hour","minute","cuspid","PandS","statino","tod","method","ec","nen","dt")

dat=cbind(rdf,idf,chars)
rm(rdf)
rm(idf)
rm(chars)

latb<-c(32,42)
lonb<-c(-114,-125)
dlat=4
dlon=8
lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
df<-data.frame(lat=double(),lon=double(),max=double(),tot=double())
if(myid == 0){tymer(reset=T)}
dorows=nrow(dat)
#dorows=10000
print(paste(myid,dorows))
for (i in 1:length(lat.seq)){
	mylat=lat.seq[i]
	for(j in 1:length(lon.seq)) {
		mylon<-lon.seq[j]
		mymax=0.0
		mytot=0.0
		for (row in 1:dorows) {
			slat=dat[row,"latitude"]
			slon=dat[row,"longitude"]
			mag=dat[row,"SCSN"]
			dep=dat[row,"depth"]
			ouch=whack(mylat,mylon,slat,slon,mag,dep)
			if(ouch > mymax){mymax=ouch}
			mytot=mytot+ouch
		}
		df[nrow(df) + 1,]<-c(mylat,mylon,mytot,mymax)
	}
	if(myid == 0){print(tymer())}
}
# turn our df into two vectors mymax and mytot

	mytot<-df$tot
	mymax<-df$max

thetot<-mpi.reduce(mytot, type=2, op="sum",dest = source, comm = mpi_comm_world)
themax<-mpi.reduce(mymax, type=2, op="max",dest = source, comm = mpi_comm_world)


if(myid == source){
	print(themax)
	print(thetot)
	# put our values back in df
}

bonk<-mpi.finalize()
#bonk<-mpi.exit()