library(graphics)
library(rhdf5)
#library(dplyr)
setwd("/Users/tkaiser2/quake")
h5f=H5Fopen("myquake5.hdf5")
print("h5f")
print(h5f)
h5ls(h5f)
b<-h5ls(h5f)
print(b)
gset<-subset(b,otype=="H5I_GROUP")
lev1<-subset(b,otype=="H5I_DATASET")

dset<-subset(lev1,(name == "lat"))
row<-dset[1,]
x<-paste(row[1,1],row[1,2],sep="/")
y<-h5f&x
lat<-y[]

dset<-subset(lev1,(name == "lon"))
row<-dset[1,]
x<-paste(row[1,1],row[1,2],sep="/")
y<-h5f&x
lon<-y[]

print(lat)
print(lon)

#
# note:  if we did not have lat and lon 
# in the file we coulg just do this
# dset<-subset(b,otype=="H5I_DATASET")
# not needing to know what is in the file
#
dset<-subset(lev1,(name == "max" | name=="tot"))
for(i in 1:nrow(dset)){
  row<-dset[i,]
  x<-paste(row[1,1],row[1,2],sep="/")
  print("***** x *****")
  print(x)
  y<-h5f&x
  print("***** y *****")
  print(y)
  z<-y[,]
  print("***** str(z) *****")
  print(str(z))
  print("***** z *****")
  print(z)
  print(nrow(z))
  print(ncol(z))
  print(lat[1])
  print(lon[1])
  xsq=seq(lon[1], lon[length(lon)], length.out = nrow(z))
  ysq=seq(lat[1], lat[length(lat)], length.out = ncol(z))
  print(xsq)
  print(ysq)
  out<-filled.contour(x = xsq,y = ysq,z)
  print(out)
}
