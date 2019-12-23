library(rhdf5)       
sfile<-"start"
dat<-read.delim(sfile,header=F,sep="")
thehead=c("year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly")
colnames(dat)<-thehead
myhead<-colnames(dat)
myh5="myhd3.h5"
h5createFile(myh5)
#h5createGroup(myh5,"quake")
for (h in myhead) {
  #x<-paste("quake",h,sep="/")
  x<-h
  h5write(dat[h], myh5,x) 
  cat(x)
}

