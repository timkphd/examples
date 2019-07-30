source("tymer.R")

quake <-function(x){
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

atin<-function(dis){
	if(dis > 100.0){
		y<-5.333253/(dis**2)
	}else{
		if(dis < 3.0)dis<-3.0
		x<-log10(dis)
		y<-1.56301016+x*(0.54671034+x*(-0.54724666))
		y<-0.017535744506694952*(10.8**y)
	}
}

# assume energy goes as (10^mag)/(d^2.5)
whack <- function(lat1,lon1,lat2,lon2,mag,dep) {
	lat1<-lat1*0.01745329
	lat2<-lat2*0.01745329
	lon1<-lon1*0.01745329
	lon2<-lon2*0.01745329
	ang1<-(sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2-lon1)
	if(ang1 > 1.0)ang1<-1.0
	d <- 6377.83 * acos(ang1)
	d <- sqrt(d*d+dep*dep)
	if(mag > 0.0){
#	i <-(quake(mag))/(d^2.5)
	i <-atin(d)*(quake(mag))
	} else {
	i=0
	}
	return(i)
}
if(FALSE){
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
}else {
	sfile<-"start"
	dat<-read.delim(sfile,header=F,sep="")
	thehead=c("year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly")
	colnames(dat)<-thehead
}
#print(dat)
library(parallel)
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(dplyr) 
#library(multidplyr) 
library(doParallel)
states <- map_data("state")
ca <- states[which(states$region == "california"),]
# or 
ca<-states[states$region == "california",]
#plot(ca$lat,ca$lon)

latb<-c(35.0,32.0)
dlat=4
lonb<-c(-121.0,-115.0)
dlon=4
myinput<-read.table("bounds")
latb[1]<-as.double(myinput[1,1])
latb[2]<-as.double(myinput[1,2])
dlat<-as.integer(myinput[1,3])
lonb[1]<-as.double(myinput[2,1])
lonb[2]<-as.double(myinput[2,2])
dlon<-as.integer(myinput[2,3])
lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
if(TRUE){
	print(lon.seq)
	print(lat.seq)
}

cores<-4
#cluster <- create_cluster(cores)  
cluster <- makeCluster(cores)  
registerDoParallel(cluster)  
df<-data.frame(lat=double(),lon=double(),tot=double(),max=double())
tymer(reset=T)
jkl=1:length(lat.seq)


dorows<-nrow(dat)
#dorows=10000
if(TRUE){
	print(tymer(reset=T))
}

for (i in jkl){
	mylat=lat.seq[i]
	aset <- foreach (ijk=1:length(lon.seq)) %dopar% {
		mymax=0.0
		mytot=0.0
		mylon<-lon.seq[ijk]
		for (row in 1:dorows) {
			slat<-dat[row,"latitude"]
			slon<-dat[row,"longitude"]
			mag<-dat[row,"SCSN"]
			dep<-dat[row,"depth"]
			ouch<-whack(mylat,mylon,slat,slon,mag,dep)
			if(ouch > mymax){mymax=ouch}
			mytot=mytot+ouch
		}
		aset<-c(mylat,mylon,mytot,mymax)
	}
	if(TRUE){print(tymer(paste("done",mylat)))}
	nresults=length(aset)
	for (ijk in 1:nresults){
		df[nrow(df) + 1,] <-aset[[ijk]]
	}
}
stopCluster(cluster)
tymer()
#print(df)
if(TRUE){
	# put our values back in df
	mymax<-matrix(df$max,nrow=dlat,ncol=dlon,byrow=TRUE)
	mymax<-as.data.frame(mymax,row.names=lat.seq)
	colnames(mymax)<-lon.seq
	print(mymax)
	mytot<-matrix(df$tot,nrow=dlat,ncol=dlon,byrow=TRUE)
	mytot<-as.data.frame(mytot,row.names=lat.seq)
	colnames(mytot)<-lon.seq
	print(mytot)
	#sanity check
	writeLines(paste("at",lat.seq[1],lon.seq[1],"sum=",mytot[1,1],"max=",mymax[1,1]))
	writeLines(paste("at",lat.seq[1],lon.seq[dlon],"sum=",mytot[1,dlon],"max=",mymax[1,dlon]))
	writeLines(paste("at",lat.seq[dlat],lon.seq[1],"sum=",mytot[dlat,1],"max=",mymax[dlat,1]))
	writeLines(paste("at",lat.seq[dlat],lon.seq[dlon],"sum=",mytot[dlat,dlon],"max=",mymax[dlat,dlon]))
	save(mytot,file="mytotp.Rda")
	save(mymax,file="mymaxp.Rda")
	write.csv(mytot,file="mytotp.csv")
	write.csv(mymax,file="mymaxp.csv")
}

#// source("works.R")
#// [1] 32.00000 32.33333 32.66667 33.00000
#// [1] -115 -117 -119 -121
#// Initialising 4 core cluster.
#// [1] "1563812544.9443  2019-07-22 10:22:24       0.000       0.000  "
#// [1] "1563812573.15413  2019-07-22 10:22:53      28.210      28.210  done 32"
#// [1] "1563812602.76737  2019-07-22 10:23:22      29.613      57.823  done 32.3333333333333"
#// [1] "1563812632.03721  2019-07-22 10:23:52      29.270      87.093  done 32.6666666666667"
#// [1] "1563812661.30538  2019-07-22 10:24:21      29.268     116.361  done 33"
#// at 32 -115 sum= 11557.6639761953 max= 21.1651123970782
#// at 32 -121 sum= 10096.1418361278 max= 6.71566316741023
#// at 33 -115 sum= 16.6253217611744 max= 0.155219186870698
#// at 33 -121 sum= 24.3447944967845 max= 0.504810265218713
#// >



