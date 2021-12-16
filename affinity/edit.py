#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os


# In[2]:


command="find . -name two.sh"
d=os.popen(command,"r")


# In[4]:


files=d.readlines()


# In[5]:


files


# In[37]:


for f in files:
    f=f.rstrip()
    print(f)
    d=open(f,"r")
    lines=d.readlines()
    nf=open(f,"w")
    for l in lines:
        if l.find("srun") > -1 and l.find("nodelist") < 0 :
            l=l.replace("srun","srun --nodelist=$n1 --nodes=1-1 ")
        nf.write(l)
    nf.close()


# In[28]:


lines


# In[35]:


nf=open(f,"w")
for l in lines:
    #l=l.rstrip()
    if l.find("srun") > -1 and l.find("nodelist") < 0 :
        l=l.replace("srun","srun --nodelist=$n1 --nodes=1-1 ")
    nf.write(l)
nf.close()


# In[34]:


f


# In[36]:


cat ./close/32o/rank/two.sh


# In[ ]:




