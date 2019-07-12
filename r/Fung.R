source("tymer")

quake1 <-function(x){
     if(x < 0.1){x=0.1}
     if(x >=0.1 && x <=2.0){
        a<-(-2.146128)
        b<-1.146128
     }
     if(x <= 3.0) {
        a<-(-0.9058116)
        b<-0.5259698
     } else {
        a<-(-0.279157)
        b<-0.3160013
     }
     t<-a+b*x
     10**t
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
	i <-quake(mag)/(d^2.5)
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
dlon=4
lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
cluster <- create_cluster(4)  
registerDoParallel(cluster)  
df<-data.frame(lat=double(),lon=double(),max=double(),tot=double())
tymer(reset=T)
k<-0
j<-0
jkl=1:length(lat.seq)
for (i in jkl){
mylat=lat.seq[i]
k<-k+1
crap <- foreach (ijk=1:length(lon.seq),.combine=cbind,.export=c('df')) %dopar% {
j<-j+1
mylon<-lon.seq[ijk]*lat.seq[jkl]
}
print(crap)
}
mymax=0.0
mytot=0.0
for (row in 1:1000) {
	slat=dat[row,"latitude"]
	slon=dat[row,"longitude"]
	mag=dat[row,"SCSN"]
	dep=dat[row,"depth"]
	ouch=whack(mylat,mylon,slat,slon,mag,dep)
	if(ouch > mymax){mymax=ouch}
	mytot=mytot+ouch
	}
print(tymer())
df[nrow(df) + 1,] <-c(mylat,mylon,mymax,mytot)
}
}
tymer()
print(df)

