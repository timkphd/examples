#!/usr/bin/env Rscript
source("tymer.R")

quake <-function(x){
     if(x < 0.1){x=0.1}
     if(x >=0.1 && x <=2.0){
        a<-(-2.146128)
        b<-1.146128
     }
     else {
          if(x <= 3.0) {
             a<-(-0.9058116)
             b<-0.5259698
          } else {
             a<-(-0.279157)
             b<-0.3160013
          }
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
if(FALSE){
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
} else {
	sfile<-paste("start",letters[l1],letters[l2],sep="")
	print(paste(myid,sfile))
	dat<-read.delim(sfile,header=F,sep="")
	thehead=c("year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly")
	colnames(dat)<-thehead
}
#if(myid == 0)print(dat)
latb<-c(35,32)
lonb<-c(-115,-121)
dlon<-abs(4*((lonb[2]-lonb[1])+1))
dlon=5
# dlon should be a multiple of cores
dlat<-abs(4*((latb[2]-latb[1])+1))
dlat=5
myinput<-read.table("bounds")
latb[1]<-as.double(myinput[1,1])
latb[2]<-as.double(myinput[1,2])
dlat<-as.integer(myinput[1,3])
lonb[1]<-as.double(myinput[2,1])
lonb[2]<-as.double(myinput[2,2])
dlon<-as.integer(myinput[2,3])



lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
if(myid == 0){
	print(lon.seq)
	print(lat.seq)
}
df<-data.frame(lat=double(),lon=double(),tot=double(),max=double())
if(myid == 0){tymer(reset=T)}
dorows<-nrow(dat)
drow<-as.integer(dorows/50)
frow=0
dat=subset(dat,,c(latitude,longitude,SCSN,depth))
mytot<-matrix(0,nrow=dlat,ncol=dlon)
mymax<-matrix(0,nrow=dlat,ncol=dlon)
for (row in 1:dorows) {
	slat<-dat[row,"latitude"]
	slon<-dat[row,"longitude"]
	mag<-dat[row,"SCSN"]
	dep<-dat[row,"depth"]
		for (i in 1:length(lat.seq)){
		mylat=lat.seq[i]
		for(j in 1:length(lon.seq)) {
			mylon<-lon.seq[j]
			#if(myid == 0)print(mylon)
			ouch<-whack(mylat,mylon,slat,slon,mag,dep)
			#print(c(ouch,mylat,mylon,slat,slon,mag,dep))
			if(ouch > mymax[i,j]){mymax[i,j]=ouch}
			mytot[i,j]<-mytot[i,j]+ouch
		}
	}
	if(myid == 0) {
		frow<-frow+1
		#if( (frow %% drow) == 0)print(tymer(frow))
	}
}
if(myid == 0)print(tymer(frow))
# pack our dataframe so it is like the original code
for(j in 1:length(lon.seq)) {
for (i in 1:length(lat.seq)){
	mylat=lat.seq[i]
		mylon<-lon.seq[j]
		df[nrow(df) + 1,]<-c(mylat,mylon,mytot[i,j],mymax[i,j])
	}
}
# turn our df into two vectors mymax and mytot
	mytot<-df$tot
	mymax<-df$max
	#print(c(myid,mytot))

thetot<-mpi.reduce(mytot, type=2, op="sum",dest = source, comm = mpi_comm_world)
themax<-mpi.reduce(mymax, type=2, op="max",dest = source, comm = mpi_comm_world)

if(myid == source){
	# put our values back in df
	mymax<-matrix(themax,nrow=dlat,ncol=dlon)
	mymax<-as.data.frame(mymax,row.names=lat.seq)
	colnames(mymax)<-lon.seq
#	mymax<-as.data.frame(mymax,row.names=lon.seq)
#	colnames(mymax)<-lat.seq
	writeLines(" ")
	mytot<-matrix(thetot,nrow=dlat,ncol=dlon)
	mytot<-as.data.frame(mytot,row.names=lat.seq)
	colnames(mytot)<-lon.seq
#	mytot<-as.data.frame(mytot,row.names=lon.seq)
#	colnames(mytot)<-lat.seq
	#sanity check
	writeLines(paste("at",lat.seq[1],lon.seq[1],"sum=",mytot[1,1],"max=",mymax[1,1]))
	writeLines(paste("at",lat.seq[1],lon.seq[dlon],"sum=",mytot[1,dlon],"max=",mymax[1,dlon]))
	writeLines(paste("at",lat.seq[dlat],lon.seq[1],"sum=",mytot[dlat,1],"max=",mymax[dlat,1]))
	writeLines(paste("at",lat.seq[dlat],lon.seq[dlon],"sum=",mytot[dlat,dlon],"max=",mymax[dlat,dlon]))
	save(mytot,file="mytotr.Rda")
	save(mymax,file="mymaxr.Rda")
	write.csv(mytot,file="mytotr.csv")
	write.csv(mymax,file="mymaxr.csv")
}
bonk<-mpi.finalize()
#bonk<-mpi.exit()





#semikln:eq timk$ mpiexec -n 4 Rscript ./stom.R
#[1] "I am 3 of 4 on semikln"
#[1] "I am 0 of 4 on semikln"
#[1] "I am 1 of 4 on semikln"
#[1] "I am 2 of 4 on semikln"
#[1] "3 startad"
#[1] "1 startab"
#[1] "2 startac"
#[1] "0 startaa"
#[1] 32.00000 32.33333 32.66667 33.00000
#[1] -115 -117 -119 -121
#[1] "1563815405.11472  2019-07-22 11:10:05       0.000       0.000  "
#[1] -115
#[1] -117
#[1] -119
#[1] -121
#[1] "1563815429.26368  2019-07-22 11:10:29      24.149      24.149  done 32"
#[1] -115
#[1] -117
#[1] -119
#[1] -121
#[1] "1563815451.98032  2019-07-22 11:10:51      22.717      46.866  done 32.3333333333333"
#[1] -115
#[1] -117
#[1] -119
#[1] -121
#[1] "1563815474.78575  2019-07-22 11:11:14      22.805      69.671  done 32.6666666666667"
#[1] -115
#[1] -117
#[1] -119
#[1] -121
#[1] "1563815497.56085  2019-07-22 11:11:37      22.775      92.446  done 33"
# 
#at 32 -115 sum= 11557.6639761954 max= 21.1651123970782
#at 32 -121 sum= 10096.1418361278 max= 6.71566316741023
#at 33 -115 sum= 16.6253217611748 max= 0.155219186870698
#at 33 -121 sum= 24.3447944967846 max= 0.504810265218713
#semikln:eq timk$ 