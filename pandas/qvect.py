import numpy as np  
import pandas as pd  
from pandas import Series, DataFrame  
import perfplot 
import os
import sys
sys.path.append("/Users/tkaiser2/bin")
from tymer import tymer

from math import log10,acos,sqrt,sin,cos

def quakea(x):
    t=np.where(x>0,0.009300039647027131,0)
    return(t)
def quakeb(x):
    t=np.where(x>0.1,10**((-2.146128)+1.146128*x),quakea(x))
    return(t)
def quakec(x):
    t=np.where(x>3.0,10**((-0.279157)+0.3160013*x),10**((-0.9058116)+0.5259698*x))
    return(t)
def quaked(x):
    t=np.where(x>2.0,quakec(x),quakeb(x))
    return(t)


def quake (xin):
    x=xin
    if(x <= 0.0):
    	return(0)
    if(x < 0.1):
        x=0.1
    if(x >=0.1 and x <=2.0) :
       a=(-2.146128)
       b=1.146128
    else:
        if(x <= 3.0):
           a=(-0.9058116)
           b=0.5259698
        else :
           a=(-0.279157)
           b=0.3160013
    t=a+b*x
    t=10.0**t
    return(t)

b1=[35.0,32.0,6]
b2=[-121.0,-115.0,8]
latb1=b1[0]
latb2=b1[1]
dlat=int(b1[2])
lonb1=b2[0]
lonb2=b2[1]
dlon=int(b2[2])
lat_seq=np.zeros([dlat])
lon_seq=np.zeros([dlon])
dx=(lonb2-lonb1)/(dlon-1)
for i in range(0,dlon):
    lon_seq[i]=lonb1+(i)*dx
dx=(latb2-latb1)/(dlat-1)
for i in range(0,dlat):
    lat_seq[i]=latb1+(i)*dx


mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])

tymer(["-i","reading data"])
thehead=["year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly"]
dat=pd.read_csv('start',sep='\s+',names=thehead)
tymer(["-i","got data"])

dep=dat['depth']
tymer(["-i","converting mymag"])
#mymag=dat.apply(lambda row: quake(row['SCSN']),axis=1)
mymag=quaked(dat["SCSN"])
dat["SCSN"]=mymag
tymer(["-i","did mymag"])

if False :
     print("types")
     print("dep",type(dep),dep)
     print("dat['latitude']",type(dat['latitude']),dat['latitude'])
     print("dat['longitude']",type(dat['longitude']),dat['longitude'])
     print("mymag",type(mymag),mymag)

def whack4b(latin1,lonin1,latin2,lonin2):
    lat1, lon1, lat2, lon2 = map(np.deg2rad, [latin1,lonin1,latin2,lonin2])
    ang1=(np.sin(lat1) * np.sin(lat2)) + np.cos(lat1) * np.cos(lat2) * np.cos(lon2-lon1)
    ang=np.arccos(ang1)
    d = 6377.83 * ang
    d = np.sqrt(d*d+dep*dep)
    d= np.where(d < 3.0,3.0,d)
#    i =atin(d)*(mag)
    return(d)

def vatin2(dis):
    x=np.log10(dis)
    y=1.56301016+x*(0.54671034+x*(-0.54724666))
    y=0.017535744506694952*(10.8**y)
    return(y)

def vatin(dis):
    x=np.log10(dis)
    return(np.where (dis > 100.0, 5.333253/(dis**2),vatin2(dis)))


mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])

tymer(["-i","start"])
j=0
for mylat in lat_seq:
    #print(mylat)
    i=0
    for mylon in lon_seq:
        #tymer(["-i","get dist"])
        #dist=whack4b(mylat,mylon,dat['latitude'],dat['longitude'])
        #tymer(["-i","got dist"])
        #tin=vatin(dist)
        result=vatin(whack4b(mylat,mylon,dat['latitude'],dat['longitude']))*mymag
        #tymer(["-i","got reduction"])
        #result=tin*mag
        #print(j,i,np.max(result),np.sum(result))
        mymax[j,i]=np.max(result)
        mytot[j,i]=np.sum(result)
        i=i+1
    j=j+1

tymer(["-i","done"])
print("at", lat_seq[0],lon_seq[0],"sum=",mytot[0,0],"max=",mymax[0,0])
print("at", lat_seq[0],lon_seq[dlon-1],"sum=",mytot[0,dlon-1],"max=",mymax[0,dlon-1])
print("at", lat_seq[dlat-1],lon_seq[0],"sum=",mytot[dlat-1,0],"max=",mymax[dlat-1,0])
print("at", lat_seq[dlat-1],lon_seq[dlon-1],"sum=",mytot[dlat-1,dlon-1],"max=",mymax[dlat-1,dlon-1])

