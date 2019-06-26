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

# read in our character data
chars<-read.csv("~/eq/ascii",header=F)
lines=nrow(chars)
names(chars)<-c("le","ct","poly")

# read in our real data
reals<-readBin("~/eq/reals",what="double",n=lines*10)
r<-matrix(reals,lines,byrow=T)
rm(reals)
rdf=as.data.frame(r)
rm(r)
names(rdf) <- c("second","latitude","longitude","depth","SCSN","residual","stdpos","stddepth","stdhorrel","stddeprel")

# read in our integer data
ints<-readBin("~/eq/ints",what="int",n=lines*13)
i<-matrix(ints,lines,byrow=T)
rm(ints)
idf=as.data.frame(i)
rm(i)
names(idf) <- c("year","month","day","hour","minute","cuspid","PandS","statino","tod","method","ec","nen","dt")

dat=cbind(rdf,idf,chars)
rm(rdf)
rm(idf)
rm(chars)

library(parallel)
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(dplyr) 
library(multidplyr) 
library(doParallel)
states <- map_data("state")
ca <- states[which(states$region == "california"),]
# or 
ca<-states[states$region == "california",]
#plot(ca$lat,ca$lon)

 
mylat=32.71
mylon=-117.16
latb<-c(32,42)
lonb<-c(-114,-125)
dlat=4
# dlon should be a multiple of cores
dlon=8
lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
cores=4
cluster <- create_cluster(cores)  
registerDoParallel(cluster)  
df<-data.frame(lat=double(),lon=double(),max=double(),tot=double())
tymer(reset=T)
k<-0
j<-0
jkl=1:length(lat.seq)
for (i in jkl){
	mylat=lat.seq[i]
	k<-k+1
	aset <- foreach (ijk=1:length(lon.seq)) %dopar% {
		j<-j+1
		mymax=0.0
		mytot=0.0
		row<-100
		mylon<-lon.seq[ijk]
		for (row in 1:nrow(dat)) {
#		for (row in 1:1000) {
			slat=dat[row,"latitude"]
			slon=dat[row,"longitude"]
			mag=dat[row,"SCSN"]
			dep=dat[row,"depth"]
			ouch=whack(mylat,mylon,slat,slon,mag,dep)
			if(ouch > mymax){mymax=ouch}
			mytot=mytot+ouch
		}
		aset<-c(mylat,mylon,mytot,mymax)
	}
	print(tymer())
	nresults=length(aset)
	for (ijk in 1:nresults){
		df[nrow(df) + 1,] <-aset[[ijk]]
	}
}

stopCluster(cluster)
tymer()
print(df)






#> rm(list=ls())
#> source('~/eq/works.R')
#Initialising 2 core cluster.
#[1] "1561586720.63652  2019-06-26 16:05:20      83.666      83.666  "
#[1] "1561586811.29981  2019-06-26 16:06:51      90.663     174.329  "
#[1] "1561586902.44306  2019-06-26 16:08:22      91.143     265.472  "
#[1] "1561586994.19659  2019-06-26 16:09:54      91.754     357.226  "
#        lat       lon         max          tot
#1  32.00000 -114.0000  318.556379   88.0799794
#2  32.00000 -115.5714 3928.007411 1345.8025950
#3  32.00000 -117.1429  501.361573   37.7788894
#4  32.00000 -118.7143  243.770459   70.4532505
#5  32.00000 -120.2857   82.595238   20.2214244
#6  32.00000 -121.8571   34.668856    2.6676733
#7  32.00000 -123.4286   19.483150    1.5586237
#8  32.00000 -125.0000   12.110231    0.9900041
#9  35.33333 -114.0000  120.515571   19.0374391
#10 35.33333 -115.5714  450.084084  113.7538776
#11 35.33333 -117.1429  979.235932   90.0263599
#12 35.33333 -118.7143 3388.523377  309.9902363
#13 35.33333 -120.2857  392.805034   46.0155048
#14 35.33333 -121.8571  157.267274   49.8679235
#15 35.33333 -123.4286   35.652910    4.3889769
#16 35.33333 -125.0000   16.932477    1.2546866
#17 38.66667 -114.0000   27.685226    2.9062783
#18 38.66667 -115.5714   37.856597    3.5138021
#19 38.66667 -117.1429   53.051298    3.5481063
#20 38.66667 -118.7143   60.571967    4.5465346
#21 38.66667 -120.2857   42.539091    2.2169311
#22 38.66667 -121.8571   29.280867    1.5686149
#23 38.66667 -123.4286   18.167455    1.1049038
#24 38.66667 -125.0000   11.470084    0.7912141
#25 42.00000 -114.0000    8.240508    0.8351722
#26 42.00000 -115.5714    9.196283    0.8899516
#27 42.00000 -117.1429    9.744403    0.8926973
#28 42.00000 -118.7143    9.686408    0.8425564
#29 42.00000 -120.2857    9.005225    0.7541522
#30 42.00000 -121.8571    7.899083    0.6485013
#31 42.00000 -123.4286    6.639128    0.5432289
#32 42.00000 -125.0000    5.436699    0.4485835
#
#> rm(list=ls())
#> source('~/eq/works.R')
#Initialising 4 core cluster.
#[1] "1561587104.11768  2019-06-26 16:11:44      47.818      47.818  "
#[1] "1561587158.01906  2019-06-26 16:12:38      53.901     101.719  "
#[1] "1561587212.85482  2019-06-26 16:13:32      54.836     156.555  "
#[1] "1561587268.53348  2019-06-26 16:14:28      55.679     212.234  "
#        lat       lon         max          tot
#1  32.00000 -114.0000  318.556379   88.0799794
#2  32.00000 -115.5714 3928.007411 1345.8025950
#3  32.00000 -117.1429  501.361573   37.7788894
#4  32.00000 -118.7143  243.770459   70.4532505
#5  32.00000 -120.2857   82.595238   20.2214244
#6  32.00000 -121.8571   34.668856    2.6676733
#7  32.00000 -123.4286   19.483150    1.5586237
#8  32.00000 -125.0000   12.110231    0.9900041
#9  35.33333 -114.0000  120.515571   19.0374391
#10 35.33333 -115.5714  450.084084  113.7538776
#11 35.33333 -117.1429  979.235932   90.0263599
#12 35.33333 -118.7143 3388.523377  309.9902363
#13 35.33333 -120.2857  392.805034   46.0155048
#14 35.33333 -121.8571  157.267274   49.8679235
#15 35.33333 -123.4286   35.652910    4.3889769
#16 35.33333 -125.0000   16.932477    1.2546866
#17 38.66667 -114.0000   27.685226    2.9062783
#18 38.66667 -115.5714   37.856597    3.5138021
#19 38.66667 -117.1429   53.051298    3.5481063
#20 38.66667 -118.7143   60.571967    4.5465346
#21 38.66667 -120.2857   42.539091    2.2169311
#22 38.66667 -121.8571   29.280867    1.5686149
#23 38.66667 -123.4286   18.167455    1.1049038
#24 38.66667 -125.0000   11.470084    0.7912141
#25 42.00000 -114.0000    8.240508    0.8351722
#26 42.00000 -115.5714    9.196283    0.8899516
#27 42.00000 -117.1429    9.744403    0.8926973
#28 42.00000 -118.7143    9.686408    0.8425564
#29 42.00000 -120.2857    9.005225    0.7541522
#30 42.00000 -121.8571    7.899083    0.6485013
#31 42.00000 -123.4286    6.639128    0.5432289
#32 42.00000 -125.0000    5.436699    0.4485835
