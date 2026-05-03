#!/usr/bin/env python
# coding: utf-8

# In[1]:


colors="1 1 1 0 2 1 1 2 3 0 1 2 1 1 0 3 0 0 0 0 2 0 3 2 0 2 2 0 3 3 0 0 3 0 3 2 2 2 3 2 2 3 1 3 1 1 3 1"


# In[2]:


values=[]
for x in colors.split():
    values.append(int(x))


# In[3]:


states="""AL AZ AR CA CO CT DE FL GA ID IA IL IN KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY"""
states=states.split()


# In[4]:


import plotly.express as px
import pandas as pd

# Sample data: state abbreviations and values
data = pd.DataFrame({
    'state': states,
    'value': values
})

fig = px.choropleth(data, 
                    locations='state', 
                    locationmode="USA-states", 
                    color='value',
                    scope="usa")
fig.show()


# In[ ]:




