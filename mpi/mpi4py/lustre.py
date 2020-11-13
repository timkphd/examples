#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd


# In[2]:


header=['allocate','open','create','assign','write_close','start','end','total']


# In[3]:


zero_00=pd.read_csv("zero_00",names=header)
zero_01=pd.read_csv("zero_01",names=header)
zero_02=pd.read_csv("zero_02",names=header)
zero_03=pd.read_csv("zero_03",names=header)
zero_04=pd.read_csv("zero_04",names=header)
zero_05=pd.read_csv("zero_05",names=header)


# In[4]:


zero_00['write']=zero_00['assign']+zero_01['write_close']
zero_01['write']=zero_01['assign']+zero_01['write_close']
zero_02['write']=zero_02['assign']+zero_01['write_close']
zero_03['write']=zero_03['assign']+zero_01['write_close']
zero_04['write']=zero_04['assign']+zero_01['write_close']
zero_05['write']=zero_05['assign']+zero_01['write_close']
t_00="lfs setstripe -size=64M -count=1\n4 nodes, 32 GB, 32 tasks"
t_01="lfs setstripe -size=64M -count=-1\n4 nodes, 32 GB, 32 tasks"
t_02="lfs setstripe -size=128M -count=1\n4 nodes, 32 GB, 32 tasks"
t_03="lfs setstripe -size=128M -count=-1\n4 nodes, 32 GB, 32 tasks"
t_04="lfs setstripe -size=64M -count=4\n4 nodes, 32 GB, 32 tasks"
t_05="lfs setstripe -size=128M -count=4\n4 nodes, 32 GB, 32 tasks"
xlab="Seconds"
ylab="Counts"


# In[5]:


def doit(dat,title,file):
    plt=dat.hist(column="write")
    xlab="Seconds"
    ylab="Counts"
    plt[0][0].set_xlim(5,40)
    plt[0][0].set_xlabel(xlab)
    plt[0][0].set_ylabel(ylab)
    plt[0][0].set_title(title)
    fig=plt[0][0].get_figure()
    fig.savefig(file)


# In[6]:


doit(zero_00,t_00,"zero_00.pdf")


# In[7]:


doit(zero_01,t_01,"zero_01.pdf")


# In[8]:


doit(zero_02,t_02,"zero_02.pdf")


# In[9]:


doit(zero_03,t_03,"zero_03.pdf")


# In[10]:


doit(zero_04,t_04,"zero_04.pdf")


# In[11]:


doit(zero_05,t_05,"zero_05.pdf")


# In[12]:


import numpy as np
b=np.zeros(6)
b[0]=32/zero_00['write'].min()
b[1]=32/zero_01['write'].min()
b[2]=32/zero_02['write'].min()
b[3]=32/zero_03['write'].min()
b[4]=32/zero_04['write'].min()
b[5]=32/zero_05['write'].min()
print(b)


# In[13]:


bw=pd.DataFrame(columns=["striping","bandwidth GB/sec"])


# In[14]:


s=np.array(range(0,6),dtype="object")
s[0]="-size=64M -count=1"
s[1]="-size=64M -count=-1"
s[2]="-size=128M -count=1"
s[3]="-size=128M -count=-1"
s[4]="-size=64M -count=4"
s[5]="-size=128M -count=4"
for i in range(0,6):
    bw.loc[len(bw.index)] = [s[i],b[i]] 


# In[15]:


html = bw.to_markdown()


# In[16]:


text_file = open("bw.md","w")
text_file.write(html)
text_file.close()


# In[17]:


zero_00


# In[ ]:




