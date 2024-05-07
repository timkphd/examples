#!/usr/bin/env python3
import numpy as np  
import pandas as pd  
from pandas import Series, DataFrame  
import perfplot 
import os
import sys
# here we need to point to the directory that contains tymer
sys.path.append("/Users/tkaiser2/bin")
sys.path.append("/home/tkaiser2/bin")
try :
    from tymer import tymer
except:
    print("Can't import tymer.  You need to change the line: ")
    print('sys.path.append("/home/tkaiser2/bin")')
    print("to point to the directory containing tymer.py")

from math import log10,acos,sqrt,sin,cos

#see https://engineering.upside.com/a-beginners-guide-to-optimizing-pandas-code-for-speed-c09ef2c6a4d6
dummy = [1, 2, 3, 4]
tymer(["-i","reading data"])
thehead=["year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly"]
dat=pd.read_csv('start',sep=r'\s+',names=thehead)
tymer(["-i","got data"])

#The following enables memory cleanup that can be seen with map
dodel=False #set to True for cleanup
sixty=True  #set to True to delay for 2*wt seconds when not doing cleanup
dosubs=True #Delete the "pointers" into the df
domain=True #Delete the df
wt=30       #Time to pause before and after del to make it easier to see in traces
# False True True True 
try:
    setfile=open("settings","r")
    input=setfile.read()
    input=input.strip()
    input=input.split()
    from distutils.util import strtobool
    try:
        dodel=strtobool(input[0]) == 1
    except:
        dodel=False
    try:
        sixty=strtobool(input[1]) == 1
    except:
        sixty=True
    try:
        dosubs=strtobool(input[2]) == 1
    except:
        dosubs=True
    try:
        domain=strtobool(input[3]) == 1
    except:
        domain=True
except:
    pass

print(dodel,sixty,dosubs,domain)
    
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

def atin(disin):
    dis=disin
    if(dis > 100.0):
        y=5.333253/(dis**2)
    else:
        if(dis < 3.0):
            dis=3.0
        x=log10(dis)
        y=1.56301016+x*(0.54671034+x*(-0.54724666))
        y=0.017535744506694952*(10.8**y)
    return(y)

def whack(latin1,lonin1,latin2,lonin2,mag,dep):
    inwhack = [1, 2, 3, 4]
    x=1234
    lat1=latin1*0.017453292519943295
    lat2=latin2*0.017453292519943295
    lon1=lonin1*0.017453292519943295
    lon2=lonin2*0.017453292519943295
    ang1=(np.sin(lat1) * np.sin(lat2)) + np.cos(lat1) * np.cos(lat2) * np.cos(lon2-lon1)
    if(ang1 > 1.0):
        ang1=1.0
    ang=np.arccos(ang1)
    d = 6377.83 * ang
    d = np.sqrt(d*d+dep*dep)
    if(d < 3.0):
        d=3.0
    if(mag > 0.0):
        i =atin(d)*(quake(mag))
    else:
        i=0
    whack=i
    return(i)

def whack2(latin1,lonin1,latin2,lonin2,mag,dep):
    lat1=latin1*0.017453292519943295
    lat2=latin2*0.017453292519943295
    lon1=lonin1*0.017453292519943295
    lon2=lonin2*0.017453292519943295
    ang1=(sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2-lon1)
    if(ang1 > 1.0):
        ang1=1.0
    ang=acos(ang1)
    d = 6377.83 * ang
    d = sqrt(d*d+dep*dep)
    if(d < 3.0):
        d=3.0
    if(mag > 0.0):
        i =atin(d)*(mag)
    else:
        i=0
    whack=i
    return(i)

def haversine(lat1, lon1, lat2, lon2):
    MILES = 3959
    lat1, lon1, lat2, lon2 = map(np.deg2rad, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1 
    dlon = lon2 - lon1 
    a = np.sin(dlat/2)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2)**2
    c = 2 * np.arcsin(np.sqrt(a)) 
    total_miles = MILES * c
    return total_miles

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
    
b1=[32.0,35.0,6]
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

lat1=dat['latitude']
lon1=dat['longitude']
dep=dat['depth']
mag=dat['SCSN']


iline=dat.shape[0]
mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])
tymer(["-i","start 1"])
for mline in range(0,iline):
    slat=lat1.iloc[mline]
    slon=lon1.iloc[mline]
    magin=mag.iloc[mline]
    depin=dep.iloc[mline]
    i=0
    if (mline % 10000 == 0):
        print(mline)
    for mylat in lat_seq:
        #print(mylat)
        j=0
        for mylon in lon_seq:
            #print(mylon)
            ouch=whack(mylat,mylon,slat,slon,magin,depin)
            #print(ouch,mylat,mylon,mymax[i,j])
            if(ouch > mymax[i,j]):
                mymax[i,j]=ouch
            mytot[i,j]=mytot[i,j]+ouch
            j=j+1
        i=i+1
tymer(["-i","done 1"])

print("at", lat_seq[0],lon_seq[0],"sum=",mytot[0,0],"max=",mymax[0,0])
print("at", lat_seq[0],lon_seq[dlon-1],"sum=",mytot[0,dlon-1],"max=",mymax[0,dlon-1])
print("at", lat_seq[dlat-1],lon_seq[0],"sum=",mytot[dlat-1,0],"max=",mymax[dlat-1,0])
print("at", lat_seq[dlat-1],lon_seq[dlon-1],"sum=",mytot[dlat-1,dlon-1],"max=",mymax[dlat-1,dlon-1])

#lat1=None
#lon1=None
#dep=None
#mag=None

tymer(["-i","define mymag"])
mymag=dat.apply(lambda row: quake(row['SCSN']),axis=1)
tymer(["-i","did mymag"])

iline=dat.shape[0]
mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])
tymer(["-i","start 2"])
for mline in range(0,iline):
    slat=lat1.iloc[mline]
    slon=lon1.iloc[mline]
    magin=mymag.iloc[mline]
    depin=dep.iloc[mline]
    i=0
    if (mline % 10000 == 0):
        print(mline)
    for mylat in lat_seq:
        #print(mylat)
        j=0
        for mylon in lon_seq:
            #print(mylon)
            ouch=whack2(mylat,mylon,slat,slon,magin,depin)
            #print(ouch,mylat,mylon,mymax[i,j])
            if(ouch > mymax[i,j]):
                mymax[i,j]=ouch
            mytot[i,j]=mytot[i,j]+ouch
            j=j+1
        i=i+1
tymer(["-i","used mymag"])

tymer(["-i","done 2"])

print("at", lat_seq[0],lon_seq[0],"sum=",mytot[0,0],"max=",mymax[0,0])
print("at", lat_seq[0],lon_seq[dlon-1],"sum=",mytot[0,dlon-1],"max=",mymax[0,dlon-1])
print("at", lat_seq[dlat-1],lon_seq[0],"sum=",mytot[dlat-1,0],"max=",mymax[dlat-1,0])
print("at", lat_seq[dlat-1],lon_seq[dlon-1],"sum=",mytot[dlat-1,dlon-1],"max=",mymax[dlat-1,dlon-1])



iline=dat.shape[0]
mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])
dat["SCSN"]=mymag
tymer(["-i","using mymag and rows"])
tymer(["-i","start 3"])

for index, row in dat.iterrows():
    slat=row['latitude']
    slon=row['longitude']
    magin=row['SCSN']
    depin=row['depth']
    i=0    
    if (index % 10000 == 0):
        print(index)
    for mylat in lat_seq:
        #print(mylat)
        j=0
        for mylon in lon_seq:
            #print(mylon)
            ouch=whack2(mylat,mylon,slat,slon,magin,depin)
            #print(ouch,mylat,mylon,mymax[i,j])
            if(ouch > mymax[i,j]):
                mymax[i,j]=ouch
            mytot[i,j]=mytot[i,j]+ouch
            j=j+1
        i=i+1
    if dodel:
        if True : del slat 
        if True : del slon 
        if True : del magin 
        if True : del depin 
    
tymer(["-i"])

tymer(["-i","done 3"])

print("at", lat_seq[0],lon_seq[0],"sum=",mytot[0,0],"max=",mymax[0,0])
print("at", lat_seq[0],lon_seq[dlon-1],"sum=",mytot[0,dlon-1],"max=",mymax[0,dlon-1])
print("at", lat_seq[dlat-1],lon_seq[0],"sum=",mytot[dlat-1,0],"max=",mymax[dlat-1,0])
print("at", lat_seq[dlat-1],lon_seq[dlon-1],"sum=",mytot[dlat-1,dlon-1],"max=",mymax[dlat-1,dlon-1])

if dodel:
    from time import sleep
    import gc
    tymer(["-i","cleaning up"])
    sleep(wt)
    try:
        if dosubs : del index
    except:
        print("nope index")
    try:
        if dosubs : del row
    except:
        print("nope row")
    try:
        if dosubs : del lat1
        if dosubs : del lon1
    except:
        print("nope lat1 lat2")
    try:
        if dosubs : del dep 
        if dosubs : del mag 
        if dosubs : del mymag 
    except:
        print("nope dep mag mymag")
    try:    
        if dosubs : del slat 
        if dosubs : del slon
    except:
        print("nope slat slon")
    try:    
        if dosubs : del magin 
        if dosubs : del depin 
    except:
        print("nope magin depin")
    try:    
        if dosubs : del mytot 
        if dosubs : del mymax 
    except:
        print("nope mytot mymax")
    try:        
        import objgraph
        objgraph.show_refs([dat], filename='sample-graph.png')
    except:
        print("nope plot")
    try:                
        if domain : del dat 
    except:
        print("nope dat")
    gc.collect()
    sleep(wt)
    tymer(["-i","done cleaning up"])
else:
# sync for memory tracing
    if sixty:
        from time import sleep
        tymer(["-i","start sleep"])
        sleep(wt*2)
        tymer(["-i","end sleep"])


mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])

tymer(["-i","reading data"])
thehead=["year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly"]
dat=pd.read_csv('start',sep=r'\s+',names=thehead)
dep=dat['depth']
tymer(["-i","got data"])


tymer(["-i","define mymag"])
mymag=dat.apply(lambda row: quake(row['SCSN']),axis=1)
if dodel:
    dat["SCSN"]=mymag
    mag=dat['SCSN']
tymer(["-i","did mymag"])

mytot=np.zeros([dlat,dlon])
mymax=np.zeros([dlat,dlon])

tymer(["-i","start 4"])
j=0
for mylat in lat_seq:
    #print(mylat)
    i=0
    for mylon in lon_seq:
        #tymer(["-i","get dist"])
        dist=whack4b(mylat,mylon,dat['latitude'],dat['longitude'])
        #tymer(["-i","got dist"])
        tin=vatin(dist)
        #tymer(["-i","got reduction"])
        result=tin*mag
        #print(j,i,np.max(result),np.sum(result))
        mymax[j,i]=np.max(result)
        mytot[j,i]=np.sum(result)
        i=i+1
    j=j+1

tymer(["-i","done 4"])
print("at", lat_seq[0],lon_seq[0],"sum=",mytot[0,0],"max=",mymax[0,0])
print("at", lat_seq[0],lon_seq[dlon-1],"sum=",mytot[0,dlon-1],"max=",mymax[0,dlon-1])
print("at", lat_seq[dlat-1],lon_seq[0],"sum=",mytot[dlat-1,0],"max=",mymax[dlat-1,0])
print("at", lat_seq[dlat-1],lon_seq[dlon-1],"sum=",mytot[dlat-1,dlon-1],"max=",mymax[dlat-1,dlon-1])

