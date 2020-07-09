#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
import numpy as np
from pandas import Series, DataFrame
import swifter
def print_full(x):
    pd.set_option('display.max_rows', len(x))
    print(x)
    pd.reset_option('display.max_rows')


# In[ ]:


infile="mirish"
dat=pd.read_csv(infile,sep='|')


# In[ ]:


dat


# In[ ]:


len(dat)


# In[ ]:


len(dat.loc[dat.State == 'TIMEOUT'])


# In[ ]:


dat.loc[dat.State != 'TIMEOUT'].loc[dat.State != 'FAILED']


# In[ ]:


def tohr(atime):
    atime=str(atime)
    tsplit=atime.split("-")
    if(len(tsplit)> 1):
        days=tsplit[0]
        hms=tsplit[1]
    else:
        days=0
        hms=tsplit[0]
    hms=hms.split(":")
    if(len(hms) == 3):
        h,m,s=hms
    else:
        h=0
        m,s=hms
    h=int(days)*24+int(h)+int(m)/60.0+float(s)/3600.0
    return(h)


# In[ ]:


dat['es']=dat.Elapsed[:]


# In[ ]:


tohr(dat['Elapsed'][0])


# In[ ]:


dat["wall"] = dat.Elapsed.swifter.apply(tohr)


# In[ ]:


dat


# In[ ]:


dat.sort_values(by=['wall'],ascending=False)


# In[ ]:


print_full(dat[['JobID','Elapsed']].loc[dat.wall < .1])


# In[ ]:


pd.set_option('display.max_rows',100)


# In[ ]:


print(dat.sort_values(by=['wall'],ascending=False))


# In[ ]:


dat[['JobID','wall']]


# In[ ]:


dat.wall.plot.hist()


# In[ ]:


dat.wall.loc[dat.wall < .1].plot.hist()


# In[ ]:


dat.loc[dat.wall > .0].loc[dat.wall < .2]


# In[ ]:


dat.loc[dat.wall > .035].loc[dat.wall < .05]


# In[ ]:


dat.loc[dat.wall > .05].loc[dat.wall < .08]


# In[ ]:


0.07*60


# In[ ]:


lower=np.array([0,.5/60,1/60,2/60,3/60,5/60,10/60,15/60,30/60,1,2,4,8,10,12,24,48])
upper=np.empty(len(lower))
upper[0:-1]=lower[1:]
upper[-1]=50
bins=np.zeros(len(upper))


# In[ ]:


upper


# In[ ]:


print("jobs  >=Min   <Min")
for x in range(0,len(upper)) :
    c=len(dat.loc[(dat.wall >= lower[x]) & (dat.wall < upper[x])])
    print("%4d %6.1f %6.1f" %(c,lower[x]*60,upper[x]*60))


# In[ ]:


asum=pd.read_pickle("mirish.zip")


# In[ ]:


asum


# In[ ]:


asum.loc[(asum.wall < .1)].sort_values(by=['mem'],ascending=False)


# In[ ]:


nodeset=asum.loc[(asum.wall < 5/60) & (asum.wall > .5/60)].NodeList.unique()


# In[ ]:


nodeset


# In[ ]:


len(nodeset)


# In[ ]:


asum.loc[(asum.wall < 5/60)]


# In[ ]:


1/60


# In[ ]:


asum.loc[(asum.wall < 5/60) & (asum.wall > .0)].NodeList


# In[ ]:


lower=np.array([0,.5/60,1/60,2/60,3/60,5/60,10/60,15/60,30/60,1,2,4,8,10,12,24,48])
upper=np.empty(len(lower))
upper[0:-1]=lower[1:]
upper[-1]=50
bins=np.zeros(len(upper))
print("jobs  >=Min   <Min   Unique Nodes")
for x in range(0,len(upper)) :
    c=len(asum.loc[(asum.wall >= lower[x]) & (asum.wall < upper[x])])
    bonk=asum.loc[(asum.wall >= lower[x]) & (asum.wall < upper[x])]
    nnode=bonk.NodeList.unique()
    print("%4d %6.1f %6.1f       %8d" %(c,lower[x]*60,upper[x]*60,len(nnode)))



# In[ ]:


dat.loc[dat.wall > .05].loc[dat.wall < .08]


# In[ ]:


asum.loc[asum.wall > .05].loc[asum.wall < .08]


# In[ ]:


asum.loc[asum.JobID=='3621401']


# In[ ]:


asum.loc[asum.NodeList=='r2i7n28']


# In[ ]:


print(dat.loc[dat.NodeList=='r2i7n28'])


# In[ ]:


dat.loc[1814:1849]


# In[ ]:




