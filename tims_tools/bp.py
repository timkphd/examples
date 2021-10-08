#!/usr/bin/env python
# coding: utf-8

# In[1]:


import sys


# In[4]:


sys.version_info


# In[11]:


def bonk(x):
    match x:
        case (1) :
            print("this is one")
        case ("a") :
            print("letter a")
        case _:
            print("nope")


# In[13]:


bonk("1")


# In[16]:


import datetime
from datetime import date
from pylab import figure, show,save
from matplotlib.dates import MONDAY, SATURDAY,SUNDAY
from matplotlib.dates import MonthLocator, WeekdayLocator, DateFormatter


date1 = datetime.date( 2002, 1, 5 )
date2 = datetime.date( 2003, 12, 1 )

# every sunday
sundays   = WeekdayLocator(SUNDAY)

# every 3rd month
months    = MonthLocator(range(1,13), bymonthday=1, interval=1)
monthsFmt = DateFormatter("%b '%y")



nodes=[]
cumu=[]
when=[]
x=[]
####
f=open("bp.txt","r")
lines=f.readlines()
for l in lines:
	l=l.split("\t")
	when.append(l[0])
	nodes.append(int(l[1]))
	cumu.append(int(l[2]))

for d in when:
	d=d.split("-")
	x.append(date.toordinal(date(int(d[0]),int(d[1]),int(d[2]))))
#print x,cumu
fig = figure()
ax = fig.add_subplot(111)
ax.plot_date(x, nodes, 'b+')
ax2 = ax.twinx()
ax2.plot(x, cumu, 'r*')
ax.xaxis.set_major_locator(months)
ax.xaxis.set_major_formatter(monthsFmt)
ax.xaxis.set_minor_locator(sundays)
ax.autoscale_view()
#ax.xaxis.grid(False, 'major')
#ax.xaxis.grid(True, 'minor')
ax.grid(True)
for tl in ax2.get_yticklabels():
    tl.set_color('r')
for tl in ax.get_yticklabels():
    tl.set_color('b')
ax2.set_ylabel('diastolic', color='r')
ax.set_ylabel('systolic', color='b')
ax.set_xlabel('Date')
ax.set_title('Blood Pressure')



fig.autofmt_xdate()

show()
fig.savefig("bp.pdf")


# In[ ]:




