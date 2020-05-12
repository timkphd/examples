#!/usr/bin/env python
# coding: utf-8
##### Generated via
##### jupyter nbconvert --to script runMPI.ipynb 
# In[6]:


import sys
import os


# In[7]:


doit=os.popen("srun -n 4 ./P_ex02.py")
output=doit.readlines()


# In[8]:


for o in output:
    print(o.strip())


# In[4]:


doit=os.popen("srun -n 4 ../c_ex02")
output=doit.readlines()


# In[9]:


for o in output:
    print(o.strip())


# In[ ]:




