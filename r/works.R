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

# assume energy goes as (10^mag)/(d^2.5)
whack <- function(lat1,lon1,lat2,lon2,mag,dep) {
	lat1<-lat1*0.01745329
	lat2<-lat2*0.01745329
	lon1<-lon1*0.01745329
	lon2<-lon2*0.01745329
	d <- 6377.83 * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2-lon1))
	d <- sqrt(d*d+dep*dep)
	if(mag > 0.0){
	i <-(quake(mag))/(d^2.5)
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
library(multidplyr) 
library(doParallel)
states <- map_data("state")
ca <- states[which(states$region == "california"),]
# or 
ca<-states[states$region == "california",]
#plot(ca$lat,ca$lon)

 
latb<-c(32,35)
lonb<-c(-115,-121)
dlon<-abs(4*((lonb[2]-lonb[1])+1))
# dlon should be a multiple of cores
dlat<-abs(4*((latb[2]-latb[1])+1))
lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
if(TRUE){
	print(lat.seq)
	print(lon.seq)
}

cores<-4
cluster <- create_cluster(cores)  
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
		row<-100
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
if(TRUE){
	# put our values back in df
	mymax<-matrix(df$max,nrow=dlat,ncol=dlon)
	mymax<-as.data.frame(mymax,row.names=lat.seq)
	colnames(mymax)<-lon.seq
	mytot<-matrix(df$tot,nrow=dlat,ncol=dlon)
	mytot<-as.data.frame(mytot,row.names=lat.seq)
	colnames(mytot)<-lon.seq
	#sanity check
	writeLines(paste("at",lat.seq[1],lon.seq[1],"sum=",mytot[1,1],"max=",mymax[1,1]))
	writeLines(paste("at",lat.seq[dlat],lon.seq[dlon],"sum=",mytot[dlat,dlon],"max=",mymax[dlat,dlon]))
	save(mytot,file="mytotp.Rda")
	save(mymax,file="mymaxp.Rda")
	write.csv(mytot,file="mytotp.csv")
	write.csv(mymax,file="mymaxp.csv")
}

#// source("works.R")
#//  [1] 32.0 32.2 32.4 32.6 32.8 33.0 33.2 33.4 33.6 33.8 34.0 34.2 34.4 34.6 34.8 35.0
#//  [1] -115.0000 -115.3158 -115.6316 -115.9474 -116.2632 -116.5789 -116.8947 -117.2105 -117.5263 -117.8421 -118.1579 -118.4737 -118.7895
#// [14] -119.1053 -119.4211 -119.7368 -120.0526 -120.3684 -120.6842 -121.0000
#// Initialising 4 core cluster.
#// [1] "1563385665.6437  2019-07-17 11:47:45       0.000       0.000  "
#// [1] "1563385798.21385  2019-07-17 11:49:58     132.570     132.570  done 32"
#// [1] "1563385940.96755  2019-07-17 11:52:20     142.754     275.324  done 32.2"
#// [1] "1563386084.56227  2019-07-17 11:54:44     143.595     418.919  done 32.4"
#// [1] "1563386228.3128  2019-07-17 11:57:08     143.751     562.669  done 32.6"
#// [1] "1563386372.91999  2019-07-17 11:59:32     144.607     707.276  done 32.8"
#// [1] "1563386517.14894  2019-07-17 12:01:57     144.229     851.505  done 33"
#// [1] "1563386661.67954  2019-07-17 12:04:21     144.531     996.036  done 33.2"
#// [1] "1563386806.42596  2019-07-17 12:06:46     144.746    1140.782  done 33.4"
#// [1] "1563386952.14672  2019-07-17 12:09:12     145.721    1286.503  done 33.6"
#// [1] "1563387097.4287  2019-07-17 12:11:37     145.282    1431.785  done 33.8"
#// [1] "1563387241.90718  2019-07-17 12:14:01     144.478    1576.263  done 34"
#// [1] "1563387386.32168  2019-07-17 12:16:26     144.415    1720.678  done 34.2"
#// [1] "1563387532.04752  2019-07-17 12:18:52     145.726    1866.404  done 34.4"
#// [1] "1563387677.4395  2019-07-17 12:21:17     145.392    2011.796  done 34.6"
#// [1] "1563387822.42928  2019-07-17 12:23:42     144.990    2156.786  done 34.8"
#// [1] "1563387967.46503  2019-07-17 12:26:07     145.036    2301.821  done 35"
#// at 32 -115 sum= 10.9537545357705 max= 0.313088961389165
#// at 35 -121 sum= 0.818898371033864 max= 0.0195149043051868
#// > 




