#!/usr/bin/env python
# coding: utf-8

# In[23]:


import numpy as np  
import pandas as pd  
from pandas import Series, DataFrame  
#import perfplot 
import os
import sys
import h5py 


q=h5py.File('myhd2.h5','r')

q.keys()


qnew=h5py.File('myhd4.h5','r')

qnew.keys()


mnew=qnew['SCSN']

type(mnew)

m=q['SCSN']

type(m)

type(mnew)

m[0]

m[0]

mnew[0]

print(m)

print(mnew)

dep=pd.DataFrame(np.array(q['depth']))['depth']
depnew=pd.DataFrame(np.array(q['depth']))





dep

dep=pd.DataFrame(np.array(q['depth']))


dep


depnew

dep[0:10]

dep[0:10] == depnew[0:10]


# In[22]:


123


# In[ ]:




