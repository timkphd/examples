#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#!/usr/bin/env python3
import pandas as pd
import sys
import numpy as np
import os
def print_full(x):
    pd.set_option('display.max_rows', len(x))
    print(x)
    pd.reset_option('display.max_rows')

sys.path.append("/Users/tkaiser2/bin")
sys.path.append("/home/tkaiser2/bin")
from tymer import *
bins=np.zeros(10)
upper=[1,2,4,8,12,18,24,30,36,5000]
lower=[0,1,2,4,8,12,18,24,30,36]
bins=np.zeros(len(upper))
tymer(["-i","start"])
flist=open('zips','r')
people=flist.readlines()
#people=['jjenkins']
#for infile in sys.stdin:
tmin=10./3600
w=0.0
tj=0
infile=people[0].strip()
outfile=infile+"_jobs"
overs=pd.read_pickle(infile+".zip")
overs['who']=infile
overs=overs[0:0]
print(overs)
for infile in people:
    infile=infile.strip()
    outfile=infile+"_jobs"
    #if os.path.exists(outfile):
    #    os.remove(outfile)
    try:
        jobs=pd.read_pickle(infile+".zip")
        jw=sum(jobs.wait)
        w=w+jw
        tj=tj+len(jobs)
        #print(jobs.wall)
        #jobs.to_hdf(outfile, 'jobs')
        #jobs.to_pickle(infile+".zip",protocol=4)
        tjobs=len(jobs.loc[(jobs.wall > tmin)])
        #print("%15s %12d" %(infile,tjobs))
        for x in range(0,len(upper)-1) :
            #print(x,lower[x],upper[x])
            #c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x])])
            c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x]) & (jobs.wall > tmin)])
            bins[x]=bins[x]+c
            #print("%5.2f %4d %5d" %(c*100,lower[x],upper[x]))
        for x in range(len(upper)-1,len(upper)) :
            #c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x])])
            c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x]) & (jobs.wall > tmin)])
            #print("***",x,lower[x],upper[x],c)
            if (c > 0):
                bonk=jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x]) & (jobs.wall > tmin)].copy(deep=True)
                #print(bonk)
                bonk['who']=infile
                overs=overs.append(bonk,ignore_index=True)
                bins[x]=bins[x]+c
    except:
        print(infile+" failed")
 #   tymer(["-i",infile])

tymer(["-i",infile])
tjobs=sum(bins)
bins=bins/tjobs
print("Total Jobs= "+str(tjobs))
print("%CPU usage")
print("   %    >cores  <cores")


for x in range(0,len(upper)) :
    #c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x])])
    bins[x]=bins[x]*100.0
    print("%5.2f    %4d   %5d" %(bins[x],lower[x],upper[x]))
#print(w,tj,(w/tj)/3600.0)


# In[ ]:


flist=open('people','r')
flist=flist.readlines()
over_two=pd.DataFrame(columns=['Nodes','Count','Wait_sum','Wait_max'])
#print(over_jobs)
#for infile in people[0:10]:
for infile in people:
#for infile in people:
    infile=infile.strip()
    outfile=infile+"_jobs"
    asum=pd.read_hdf(outfile)
    nodeset=asum['NNodes'].unique()
    #print(asum)
    count=np.zeros(len(nodeset))
    sumit=np.zeros(len(nodeset))
    maxit=np.zeros(len(nodeset))
    mynodes=np.zeros(len(nodeset))
    k=0
    for n in nodeset:
        c=asum.loc[asum.NNodes == n]
        count[k]=len(c)
        sumit[k]=sum(c.wait)
        maxit[k]=max(c.wait)
        mynodes[k]=n
        k=k+1
    #print(infile)
    #print(nodeset)
    for nzip in zip(nodeset,count,sumit,maxit):
        n,c,s,m=list(nzip)
        #print(n,c,s,m)
        if (len(over_two.loc[(over_two.Nodes == n)]) > 0):
            myrow=over_two.loc[(over_two.Nodes == n)]
            ind=myrow.index[0]
            over_two.at[ind,'Count']=float(over_two.loc[[ind],['Count']].values[0])+c
            over_two.at[ind,'Wait_sum']=s+float(over_two.loc[[ind],['Wait_sum']].values[0])
            pre_max=float(over_two.loc[[ind],['Wait_max']].values[0])
            if m > pre_max:
                over_two.at[ind,'Wait_max']=m
        else:
            df=pd.DataFrame([[n,c,s,m]],columns=over_two.columns)
            over_two=over_two.append(df,ignore_index=True)

over_two['Wait_ave']=over_two.Wait_sum/over_two.Count
over_two.sort_values(by=['Nodes'],inplace=True)
print_full(over_two)


# In[ ]:


from pylab import figure,show,save
import matplotlib.pyplot as plt
plt.bar(over_two.Nodes,over_two.Wait_ave)


# In[ ]:


upper=np.array([1,2,4,8,16,32,64,128,256,762,3000])
lower=np.array([0,1,2,4,8,16,32,64,128,256,762])
bins=np.zeros(len(upper))
upper=upper*1e9
lower=lower*1e9
tymer(["-i","start"])
flist=open('zips','r')
people=flist.readlines()
#people=['jjenkins']
#for infile in sys.stdin:
tmin=1./3600
w=0.0
tj=0
gpus=0
for infile in people:
    infile=infile.strip()
    outfile=infile+"_jobs"
    #if os.path.exists(outfile):
    #    os.remove(outfile)
    try:
        jobs=pd.read_pickle(infile+".zip")
        #print(jobs)
        #print(jobs.wall)
        #jobs.to_hdf(outfile, 'jobs')
        #jobs.to_pickle(infile+".zip",protocol=4)
        tjobs=len(jobs.loc[(jobs.wall > tmin)])
        gjobs=len(jobs.loc[(jobs.wall > tmin) & (jobs.ReqGRES)])
        gpus=gpus+gjobs

        #print("%15s %12d" %(infile,tjobs))
        for x in range(0,len(upper)) :
            #print(x,lower[x],upper[x])
            #c=len(jobs.loc[(jobs.cores >= lower[x]) & (jobs.cores < upper[x])])
            c=len(jobs.loc[(jobs.mem >= lower[x]) & (jobs.mem < upper[x]) & (jobs.wall > tmin)])
            
            bins[x]=bins[x]+c
            c=c/tjobs
            #print("%5.2f %4d %5d" %(c*100,lower[x],upper[x]))
    except:
        print(infile+" failed")
 #   tymer(["-i",infile])

tymer(["-i",infile])
tjobs=sum(bins)
bins=bins/tjobs
print("Total Jobs= "+str(tjobs))
upper=np.array([1,2,4,8,16,32,64,128,256,762,3000])
lower=np.array([0,1,2,4,8,16,32,64,128,256,762])
print("%Jobs Using memory in range")
print("    %  >GB   <GB")
for x in range(0,len(upper)) :
    bins[x]=bins[x]*100.0
    print("%5.2f %4d %5d" %(bins[x],lower[x],upper[x]))
print("GPU USAGE: total jobs %d or %3.2f%s" % (gpus, 100*gpus/tjobs,"%"))


# In[ ]:


tymer(["-i","Done with memory summary"])


# In[ ]:


flist=open('people','r')
flist=flist.readlines()
over_two=pd.DataFrame(columns=['Nodes','Count','Wall_sum'])
#print(over_jobs)
#for infile in people[0:10]:
tmin=10.0/3600
#for infile in ['tkaiser2']:
for infile in people:
    infile=infile.strip()
    outfile=infile+"_jobs"
    asum=pd.read_hdf(outfile)
    nodeset=asum['NNodes'].unique()
    #print(asum)
    count=np.zeros(len(nodeset))
    sumit=np.zeros(len(nodeset))
    maxit=np.zeros(len(nodeset))
    mynodes=np.zeros(len(nodeset))
    k=0
    for n in nodeset:
        c=asum.loc[(asum.wall > tmin) & (asum.NNodes == n)]
        count[k]=len(c)
        sumit[k]=sum(c.wall)
        mynodes[k]=n
        k=k+1
    #print(infile)
    #print(nodeset)
    for nzip in zip(nodeset,count,sumit):
        n,c,s=list(nzip)
        #print(n,c,s,m)
        if (len(over_two.loc[(over_two.Nodes == n)]) > 0):
            myrow=over_two.loc[(over_two.Nodes == n)]
            ind=myrow.index[0]
            over_two.at[ind,'Count']=float(over_two.loc[[ind],['Count']].values[0])+c
            over_two.at[ind,'Wall_sum']=s+float(over_two.loc[[ind],['Wall_sum']].values[0])
            pre_max=float(over_two.loc[[ind],['Wall_sum']].values[0])
        else:
            df=pd.DataFrame([[n,c,s]],columns=over_two.columns)
            over_two=over_two.append(df,ignore_index=True)

over_two['Wall_ave']=3600.0*over_two.Wall_sum/over_two.Count
over_two.sort_values(by=['Nodes'],inplace=True)
over_two.drop(columns='Wall_sum',inplace=True)
print_full(over_two)

tymer(["-i","Done with wall time summary"])


# In[ ]:


startd=['2019-11-01','2019-12-01','2020-01-01','2020-02-01','2020-03-01','2020-04-01','2020-05-01']
endd=  ['2019-11-30','2019-12-31','2020-01-31','2020-02-29','2020-03-31','2020-04-30','2020-05-31']
month=  ['11','12','01','02','03','04','05']
for st,en,mo in zip(startd,endd,month):
    print(st,en,mo)


# In[ ]:


overs=pd.read_pickle("tkaiser2"+".zip") 
overs 


# In[ ]:


overs.ReqGRES.isnull().sum()


# In[ ]:


do_gpu=pd.DataFrame(columns=['who','GPU','Total'])
flist=open('zips','r')
people=flist.readlines()


for w in people:
    w=w.strip()
    overs=pd.read_pickle(w+".zip")
    nope=overs.ReqGRES.isnull().sum()
    total=len(overs)
    gpu=total-nope
    df=pd.DataFrame([[w,gpu,total]],columns=do_gpu.columns)
    do_gpu=do_gpu.append(df,ignore_index=True)
    


# In[ ]:


do_gpu['Precent']=100.0*do_gpu.GPU/do_gpu.Total


# In[ ]:


do_gpu


# In[ ]:


do_gpu.sort_values(by=['GPU'],inplace=True,ascending=False)


# In[ ]:


do_gpu


# In[ ]:


print_full(do_gpu)


# In[ ]:


100*sum(do_gpu.GPU)/sum(do_gpu.Total)


# In[ ]:




