import numpy as np  
import pandas as pd  
from pandas import Series, DataFrame  
#import perfplot 
import os
import sys
import h5py 

q=h5py.File('myhd2.h5','r')
print(q.keys())
if False:
    dep=q['depth']
    two=np.array(dep)
    three=pd.DataFrame(two)
    print(three.keys())
    dep=three['depth']
else:
    dep=pd.DataFrame(np.array(q['depth']))['depth']

print("one ******\n",type(dep),dep)


thehead=["year","month","day","hour","minute","second","cuspid","latitude","longitude","depth","SCSN","PandS","statino","residual","tod","method","ec","nen","dt","stdpos","stddepth","stdhorrel","stddeprel","le","ct","poly"]
dat=pd.read_csv('start',sep='\s+',names=thehead)
dat=dat['depth']

print("two ******\n",type(dat),dat)

# we are getting truncation type errors
print(np.count_nonzero(np.isclose(dat,dep)))
print(np.count_nonzero(dat == dep))
print(dat[1]-dep[1])
print(np.sum(np.abs(dat-dep)))