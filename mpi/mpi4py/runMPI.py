#!/usr/bin/env python3
# coding: utf-8
##### Generated via
##### jupyter nbconvert --to script runMPI.ipynb 
# In[0]:
import sys
import os

# In[1]:
doit=os.popen("srun -n 4 ./P_ex02.py")
output=doit.readlines()

# In[2]:
for o in output:
    print(o.strip())

# In[3]:
# Assumes this program has been built
doit=os.popen("srun -n 4 ../c_ex02")
output=doit.readlines()

# In[9]:
for o in output:
    print(o.strip())
