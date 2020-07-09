#!/usr/bin/env python
# coding: utf-8

# In[1]:


#sacct -S 2020-03-01 -u $USER --format=User,JobID%20,Submit,start,elapsed,nodelist%25,state,UserCPU%20,NNodes,MaxVMSize  -P |  grep -v "None assigned" > sout
#grep "[0-9][0-9][0-9][0-9][0-9][0-9][0-9].exter" sout > sout.ext
#grep "[0-9][0-9][0-9][0-9][0-9][0-9][0-9].bat" sout > sout.bat
#grep "|[0-9][0-9][0-9][0-9][0-9][0-9][0-9]|2020" sout > sout.non
#jupyter nbconvert --to script proc.ipynb 

def isnotebook():
    try:
        shell = get_ipython().__class__.__name__
        if shell == 'ZMQInteractiveShell':
            return True   # Jupyter notebook or qtconsole
        elif shell == 'TerminalInteractiveShell':
            return False  # Terminal running IPython
        else:
            return False  # Other type (?)
    except NameError:
        return False   
    
import numpy as np  
import pandas as pd  
from pandas import Series, DataFrame  
#import perfplot 
import os
import sys
sys.path.append("/Users/tkaiser2/bin")
sys.path.append("/home/tkaiser2/bin")
from tymer import tymer
tymer(["-i","starting"])

infile="tkaiser2"
if isnotebook() :
    pass
else:
    if len(sys.argv) > 1:
        infile=sys.argv[1]


# In[2]:


print(infile)


# In[3]:


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
def tosec(stime):
    from datetime import datetime
    import time
    wtf=datetime.strptime(stime,"%Y-%m-%dT%H:%M:%S")
    return(time.mktime(wtf.timetuple()))
    
def kmg(smem):
    smem=str(smem)
    smem=smem.replace("K","e3")
    smem=smem.replace("M","e6")
    smem=smem.replace("G","e9")
    return(float(smem))

    return(time.mktime(wtf.timetuple()))
    


import swifter


# In[4]:


tymer(["-i","reading"])
dat=pd.read_csv(infile,sep='|')
tymer(["-i","done - converting"])


dat["wall"] = dat.Elapsed.swifter.apply(tohr)
dat["user"] = dat.UserCPU.swifter.apply(tohr)
dat["Submit"]=dat.Submit.swifter.apply(tosec)
dat["Start"]=dat.Start.swifter.apply(tosec)
dat["MaxVMSize"]=dat.MaxVMSize.swifter.apply(kmg)
tymer(["-i","did - convertion"])







# In[5]:


dat['wait']=dat["Start"]-dat["Submit"]
dat


# In[6]:


jobs=dat.loc[pd.notna(dat.User),['JobID','NNodes','wall','user','wait','ReqGRES']]


# In[7]:


tymer(["-i","memory"])
junk=pd.DataFrame(columns=['JID','SIZE'])
i=list(jobs.index)
i.append(i[-1]+10)
k=0
cstart=0
#dat.MaxVMSize=dat.MaxVMSize.str.replace('K',"e3")
for j in jobs.JobID:
    datb=dat[i[k]:i[k+1]]
    ajob=datb.loc[datb.JobID.str.contains(j),['MaxVMSize']]
    junk.loc[k]=[j,float(ajob.dropna(axis=0).max())]
    k=k+1
tymer(["-i","got it"])
junk


# In[8]:


# memory
# queue time
# core usage
# node usage


# In[9]:


jobs['mem']=list(junk['SIZE'])


# In[ ]:





# In[10]:


jobs['cores']=jobs.user/(jobs.wall*jobs.NNodes)


# In[11]:


nc=jobs.NNodes.unique()


# In[12]:


nc.sort()


# In[13]:


summary=pd.DataFrame(columns=['Nodes','Count','Wait','Average Core','Max Core','Ave Mem','Max Mem'])
l=0
for n in nc:
    subset=jobs.loc[jobs['NNodes']== n]
    count=len(subset)
    wait=subset.wait.mean()
    mcore=subset.cores.max()
    acore=subset.cores.mean()
    mmem=subset.mem.max()
    amem=subset.mem.mean()
    summary.loc[k]=[int(n),int(count),wait,acore,mcore,amem/1e9,mmem/1e9]
    k=k+1
    #print(n,count,wait,acore,mcore)
summary = summary.reset_index(drop=True)
print(summary)

# In[14]:


tymer(["-i","end"])


# In[15]:


summary


# In[16]:


if True :
    tymer(["-i",""])

    tymer(["-i","write sum"])

    outfile=infile+"_sum"
    if os.path.exists(outfile):
        os.remove(outfile)
    summary.to_hdf(outfile, key='sum', mode='w')
    tymer(["-i","write jobs"])
    outfile=infile+"_jobs"
    if os.path.exists(outfile):
        os.remove(outfile)
    #jobs.to_hdf(outfile, key='jobs', mode='w')
    outfile=infile+".zip"
    if os.path.exists(outfile):
        os.remove(outfile)
    jobs.to_pickle(outfile,protocol=4)
    tymer(["-i","end"])
    #outfile=infile+"_sum"
    #back=pd.read_hdf(outfile, 'sum')
