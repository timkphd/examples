#!/usr/bin/env python  
# coding: utf-8  
  
# In[1]:  
import pandas as pd  
import numpy as np  
  
# In[2]:  
def pdappend(df,line):  
    a_series = pd.Series(line, index = df.columns)  
    return df.append(a_series, ignore_index=True)  
  
# In[3]:  
head=['theta','sin','cos']  
df=pd.DataFrame(columns=head)  
  
# In[4]:  
pi=np.pi  
dp=pi/100.0  
a=np.arange(0,2*pi,dp)  
  
# In[5]:  
df['theta']=a  
df['sin']=np.sin(df.theta)  
df['cos']=np.cos(df.theta)  
  
# In[6]:  
def sqit(x,y):  
    return (x*x+y*y)  
  
# In[7]:  
df['one']=sqit(df['sin'],df['cos'])  
  
# In[8]:  
def quake (xin):  
    if xin < 0.0 :  
        return 0.0  
    return xin*xin  
  
# In[9]:  
#quake(df.sin)  This does not work  
  
#this does  
df.apply(lambda row: quake(row['sin']),axis=1)  
  
# In[10]:  
df=pdappend(df,[2*pi,np.sin(2*pi),np.cos(2*pi),1])  
  
# In[11]:  
df  
  
# In[12]:  
# here we need to point to the directory that contains plotting routines
import sys  
sys.path.append("/Users/tkaiser2/bin")  
sys.path.append("/home/tkaiser2/bin")  
  
# In[13]:  
from plsub import myplot  
  
# In[14]:  
try:
    get_ipython().run_line_magic('matplotlib', 'inline')  
except:
    pass

  
# In[15]:  
x=np.array(df.theta)  
s=np.array(df.sin)  
c=np.array(df.cos)  
  
# In[16]:  
to_plot=[[x,s,"sin(x)"],[x,c,"cos(x)"]]  
  
# In[17]:  
myplot(bl="time",sl="out\nVolts",topl="two plots",width=1,sets=to_plot,doxkcd=True)  
 
 
 
 
def mytan (s,c): 
    return s/c 
 
df['tan']=df.apply(lambda row: mytan(row['sin'],row['cos']),axis=1) 

print(df)

