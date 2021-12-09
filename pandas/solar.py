#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import time
start_time=time.monotonic_ns()
import pandas as pd
from datetime import date, datetime, timezone, timedelta
import pytz
from suntime import Sun, SunTimeException
from suntimes import SunTimes
import sunriset
import astral, astral.sun
def toloc(instr):
    instr=str(instr)
    instr=instr.split(" ")
    d=instr[2]
    print(d)
    d=d.split(":")
    h=int(d[0])+delta
    h=("%2.2d" % (h))
    return(h+":"+d[1]+":"+d[2])
def hms(x):
    h=int(x)
    s=(x-h)*3600
    m=int(s/60.0)
    s=s-m*60
    return("%2d:%2.2d:%2.2d" % (h,m,s))
def pdappend(df,line):   
    a_series = pd.Series(line, index = df.columns)   
    return df.append(a_series, ignore_index=True)   
import os

import sys
import os # if you want this directory

try:
    sys.path.index("/home/tkaiser2/bin") # Or os.getcwd() for this directory
except ValueError:
    sys.path.append("/home/tkaiser2/bin") # Or os.getcwd() for this directory
    pp="/home/tkaiser2/bin"  

import tymer


# In[ ]:


latitude = 39.760696
longitude = -105.117518
altitude = 5489
altitude=0
tz_poland = pytz.timezone('MST')
tz_name = 'MST'
for_date = date(2022,1,1)
print('====== suntime ======')
abd = for_date
sun = Sun(latitude, longitude)
today_sr = sun.get_sunrise_time()
today_ss = sun.get_sunset_time()
print(today_sr.astimezone(tz_poland))
print(today_ss.astimezone(tz_poland))
print('====== suntimes ======')
sun2 = SunTimes(longitude=longitude, latitude=latitude, altitude=altitude)
day = datetime(for_date.year, for_date.month, for_date.day)
print(sun2.risewhere(day, tz_name))
print(sun2.setwhere(day, tz_name))
print('====== sunriset ======')
local = datetime.now()
utc = datetime.utcnow()
local_tz = float(((local - utc).days * 86400 + round((local - utc).seconds, -1))/3600)
number_of_years = 1
start_date = for_date
df = sunriset.to_pandas(start_date, latitude, longitude, 2, number_of_years)
df = sunriset.to_pandas(start_date, latitude, longitude, -7, number_of_years)
for index, row in df.iterrows():
    up=row['Sunrise']
    down=row['Sunset']
    print(index,up)
    print(index,down)
    break
print('====== astral ======')
l = astral.LocationInfo('Custom Name', 'My Region', tz_name, latitude, longitude)
s = astral.sun.sun(l.observer, date=for_date)
print(s['sunrise'].astimezone(tz_poland))
print(s['sunset'].astimezone(tz_poland))


# In[ ]:


df


# In[ ]:


x=time.monotonic_ns()
y=time.monotonic_ns()
y-x
z=time.monotonic_ns()-time.monotonic_ns()
print(y-x,abs(z))


# In[ ]:


df['Sunrise']


# In[ ]:


def mkhr(intime):
    intime=str(intime)
    #0 days 14:10:03.685452
    intime=intime.split(" ")
    days=int(intime[0])
    hms=intime[2]
    hms=hms.split(":")
    hms=float(hms[0])+float(hms[1])/60.0+float(hms[2])/3600.0
    return(hms)
def mintohr(intime):
    intime=intime/60.0
    return(intime)


# In[ ]:


df['Down']=df.apply(lambda row: mkhr(row['Sunset']),axis=1)   
df['Up']=df.apply(lambda row: mkhr(row['Sunrise']),axis=1)   
df['light']=df.apply(lambda row: mintohr(row['Sunlight Durration (minutes)']),axis=1)   



# In[ ]:


p=df.plot(y=['Up','Down','light'],title="Solar Information for 2022",xlabel="Date",ylabel="Time/HR",figsize=[11*.75,8.5*.75])
p
fig=p.get_figure()
fig.savefig('test.pdf')


# In[ ]:


header=["Event","Date","Time"]
tab=pd.DataFrame(columns=header)

d=df.loc[df['Up'].max()==df['Up']].index[0]        ;t=hms(df['Up'].max())    ;e="Latest Rise"    ; print(e,d,t) ; tab=pdappend(tab,[e,d,t])
d=df.loc[df['Down'].min()==df['Down']].index[0]    ;t=hms(df['Down'].min())  ;e="Earliset Set"   ; print(e,d,t) ; tab=pdappend(tab,[e,d,t])
d=df.loc[df['light'].min()==df['light']].index[0]  ;t=hms(df['light'].min()) ;e="Least Light"    ; print(e,d,t) ; tab=pdappend(tab,[e,d,t])

d=df.loc[df['Up'].min()==df['Up']].index[0]        ;t=hms(df['Up'].min())    ;e="Earliset Rise"  ; print(e,d,t) ; tab=pdappend(tab,[e,d,t])
d=df.loc[df['Down'].max()==df['Down']].index[0]    ;t=hms(df['Down'].max())  ;e="Latest Set"     ; print(e,d,t) ; tab=pdappend(tab,[e,d,t])
d=df.loc[df['light'].max()==df['light']].index[0]  ;t=hms(df['light'].max()) ;e="Most Light"     ; print(d,t,e) ; tab=pdappend(tab,[e,d,t])
#tab.to_html("tab.html",index=False)
tab


# In[ ]:


tab_buf=tab.to_html(index=False)
tab_buf=tymer.docss(tab_buf)
tab_buf
ofile=open("tab.html","w")
ofile.write(tab_buf)
ofile.close()


# In[ ]:


#import pandas as pd
#pd.set_option("display.max_rows", None, "display.max_columns", None)


# In[ ]:


sol_buf=df.to_html(index=False)
sol_buf=tymer.docss(sol_buf,color="blue")
ofile=open("solar.html","w")
ofile.write(sol_buf)
ofile.close()


# In[ ]:


sub=df[['light','Up','Down']]
sub['Sunrise']=sub.apply(lambda row: hms(row['Up']),axis=1)   
sub['Sunset']=sub.apply(lambda row: hms(row['Down']),axis=1)   
sub=sub.drop(['Up','Down'],axis=1)


# In[ ]:


sub


# In[ ]:


sub


# In[ ]:


end_time=time.monotonic_ns()
dt=(end_time-start_time)/1e9
print("run time = ",dt)


# In[ ]:




