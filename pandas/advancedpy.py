#!/usr/bin/env python3
# coding: utf-8

# In[1]:


who=['alice','tim','tode','bambi','christian']
for i, item in enumerate(who):
    print(i,item)


# In[2]:


first, *middle, last =who
print(first)
print(middle)
print(last)


# In[3]:


first


# In[4]:


a=1
b=2
print(a,b)
b,a=a,b
print(a,b)


# In[5]:


from time import sleep
def start():
    print("starting")
def running():
    print("running")
    sleep(5)
def finishing():
    print("all done")

actions = {
    "start": start,
    "finishing": finishing,
    "running": running,
}
action="start"
actions["start"]()
actions["running"]()
actions["running"]()
actions["finishing"]()



# In[6]:


import numpy as np
from collections import Counter


# In[7]:


rng = np.random.default_rng()
ints=rng.integers(low=1, high=10, size=(100))
counts = Counter(ints)
print(counts)
print()
print(counts.most_common(3))


# In[8]:


counts


# In[9]:


counts.most_common(3)


# In[10]:


for i, item in enumerate(counts):
    print(i,item,counts[item])


# In[11]:


for x in counts:
    print(x,counts[x])


# In[12]:


nints=rng.integers(low=1, high=10, size=(5))


# In[13]:


for a, b in zip(nints, who):
    print(a, b)


# In[14]:


from dataclasses import dataclass

@dataclass
class User:
    name: str
    age: int
    def oldfart(self):
        if(self.age>100):
            print("oldfart")


# In[15]:


person=User("me",1234)


# In[16]:


person.oldfart()


# In[ ]:




