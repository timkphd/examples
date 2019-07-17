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
latb<-c(32,33)
lonb<-c(-115,-121)
dlon<-abs(4*((lonb[2]-lonb[1])+1))
#dlon=100
# dlon should be a multiple of cores
dlat<-abs(4*((latb[2]-latb[1])+1))
#dlat=2
lon.seq<-seq(lonb[1],lonb[2],length=dlon)
lat.seq<-seq(latb[1],latb[2],length=dlat)
if(myid == 0){
	print(lat.seq)
	print(lon.seq)
}
df<-data.frame(lat=double(),lon=double(),tot=double(),max=double())
if(myid == 0){tymer(reset=T)}
dorows<-nrow(dat)
#dorows=10000
for (i in 1:length(lat.seq)){
	mylat=lat.seq[i]
	for(j in 1:length(lon.seq)) {
		mylon<-lon.seq[j]
		if(myid == 0)print(mylon)
		mymax=0.0
		mytot=0.0
		for (row in 1:dorows) {
			slat<-dat[row,"latitude"]
			slon<-dat[row,"longitude"]
			mag<-dat[row,"SCSN"]
			dep<-dat[row,"depth"]
			ouch<-whack(mylat,mylon,slat,slon,mag,dep)
			#print(c(ouch,mylat,mylon,slat,slon,mag,dep))
			if(ouch > mymax){mymax=ouch}
			mytot<-mytot+ouch
		}
		#if(myid == 0)print(c(myid,mylat,mylon,mytot))
		df[nrow(df) + 1,]<-c(mylat,mylon,mytot,mymax)
	}
	if(myid==0){print(tymer(paste("done",mylat)))}
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
	writeLines(" ")
	mytot<-matrix(thetot,nrow=dlat,ncol=dlon)
	mytot<-as.data.frame(mytot,row.names=lat.seq)
	colnames(mytot)<-lon.seq
	#sanity check
	writeLines(paste("at",lat.seq[1],lon.seq[1],"sum=",mytot[1,1],"max=",mymax[1,1]))
	writeLines(paste("at",lat.seq[dlat],lon.seq[dlon],"sum=",mytot[dlat,dlon],"max=",mymax[dlat,dlon]))
	save(mytot,file="mytotm.Rda")
	save(mymax,file="mymaxm.Rda")
	write.csv(mytot,file="mytotm.csv")
	write.csv(mymax,file="mymaxm.csv")
}
bonk<-mpi.finalize()
#bonk<-mpi.exit()
