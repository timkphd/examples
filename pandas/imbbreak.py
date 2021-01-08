#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
import numpy as np

x=open("pandas.csv","r")
lines=x.readlines()


df=pd.read_csv("pandas.csv")
df.to_excel("imb.xlsx",sheet_name="IMB Eagle")

tests=list(df.test.unique())
tests.remove('test')
print(tests)
heads={}
for t in tests:
    k=0
    #print(t)
    for l in lines:
        if l.find(t) > -1:
            p=lines[k-1]
            heads[t]=p.strip()
            #print(p)
            break
        k=k+1
#print(heads)
            
            

# We create a dictionary of dataframes with tests as the keys.
bonk={}
for w in tests :
    x=pd.DataFrame(df.loc[df.test==w].copy())
    bonk[w]=x
    bonk[w].columns=heads[w].split(",")
        
# Remove the extra columns from pingpong and barrier.
for x in ['a','b','c','d','e','f','g'] :
    bonk['Barrier'] = bonk['Barrier'].drop(x, 1)
for x in ['b','c','d','e','f','g'] :
    bonk['Pingpong'] = bonk['Pingpong'].drop(x, 1)

# If we don't want to work with the dictionary we can break out entires.
# This is general procedure that should work with all dictionaries.
for w in bonk.keys() :
    astr="WHAT=bonk['WHAT']"
    astr=astr.replace('WHAT',w)
    exec(astr)


# In[ ]:


import sys
get_ipython().run_line_magic('matplotlib', 'inline')
sys.path.append("/Users/tkaiser2/bin")
from plsub import myplot



# In[ ]:


TPN="1"
ys1=np.array(Biband.loc[Biband.tpn==TPN]['Msg/sec'])
xs1=np.array(Biband.loc[Biband.tpn==TPN]['size'])
cs1=np.array(Biband.loc[Biband.tpn==TPN]['cores'])
print(ys1)
print(xs1)
print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Biband, TPN="+TPN,bl="Nodes",sl='Msg/sec')


# cs1

# In[ ]:


TPN="36"

ys1=np.array(Biband.loc[Biband.tpn==TPN]['Msg/sec'])
xs1=np.array(Biband.loc[Biband.tpn==TPN]['size'])
cs1=np.array(Biband.loc[Biband.tpn==TPN]['cores'])
#print(ys1)
#print(xs1)
#print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Biband 36,TPN="+TPN,bl="Nodes",sl='Msg/sec')


# In[ ]:


Barrier


# In[ ]:


Pingpong


# In[ ]:


tests


# In[ ]:


Alltoall


# In[ ]:


TPN="1"
ys1=np.array(Alltoall.loc[Alltoall.tpn==TPN]['t_max[usec]'])
xs1=np.array(Alltoall.loc[Alltoall.tpn==TPN]['size'])
cs1=np.array(Alltoall.loc[Alltoall.tpn==TPN]['cores'])
#print(ys1)
#print(xs1)
#print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Alltoall, TPN="+TPN,bl="Nodes",sl='t_max[usec]')


# In[ ]:


Allgather


# In[ ]:


TPN="1"
ys1=np.array(Allgather.loc[Allgather.tpn==TPN]['t_max[usec]'])
xs1=np.array(Allgather.loc[Allgather.tpn==TPN]['size'])
cs1=np.array(Allgather.loc[Allgather.tpn==TPN]['cores'])
#print(ys1)
#print(xs1)
#print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Allgather, TPN="+TPN,bl="Nodes",sl='t_max[usec]')


# In[ ]:


TPN="1"
ys1=np.array(Allreduce.loc[Allreduce.tpn==TPN]['t_max[usec]'])
xs1=np.array(Allreduce.loc[Allreduce.tpn==TPN]['size'])
cs1=np.array(Allreduce.loc[Allreduce.tpn==TPN]['cores'])
#print(ys1)
#print(xs1)
#print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Allreduce, TPN="+TPN,bl="Nodes",sl='t_max[usec]')


# In[ ]:


Allreduce


# In[ ]:


tests


# In[ ]:


Sendrecv


# In[ ]:


TPN="1"
ys1=np.array(Sendrecv.loc[Sendrecv.tpn==TPN]['t_max[usec]'])
xs1=np.array(Sendrecv.loc[Sendrecv.tpn==TPN]['size'])
cs1=np.array(Sendrecv.loc[Sendrecv.tpn==TPN]['cores'])
#print(ys1)
#print(xs1)
#print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Sendrecv, TPN="+TPN,bl="Nodes",sl='t_max[usec]')


# In[ ]:


Exchange


# In[ ]:


TPN="1"
ys1=np.array(Exchange.loc[Exchange.tpn==TPN]['t_max[usec]'])
xs1=np.array(Exchange.loc[Exchange.tpn==TPN]['size'])
cs1=np.array(Exchange.loc[Exchange.tpn==TPN]['cores'])
#print(ys1)
#print(xs1)
#print(cs1)
sets=[]
for j in range(0,len(xs1[0,:])):
    #print(xs1[0,j])
    x=np.empty(len(cs1))
    y=np.empty(len(cs1))
    for i in range(0,len(cs1)):
        #print(cs1[i],ys1[i,j])
        x[i]=cs1[i]
        y[i]=ys1[i,j]
    #print(x)
    #print(y)
    sub=[x,y,str(xs1[0,j])]
    sets.append(sub)
myplot(sets=sets,do_log="y",topl="Exchange, TPN="+TPN,bl="Nodes",sl='t_max[usec]')


# In[ ]: