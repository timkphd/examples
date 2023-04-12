#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import sys
sys.path.append("/Users/tkaiser/bin")
sys.path.append("/home/tkaiser2/bin")
sys.path.append("/Users/tkaiser2/bin")
from myutils import tymer
from myutils import pdaddrow
from myutils import greenbar
from plsub import myplot
tymer("-i")

dat="""Round	Grains	FPS	width
22	36	1260	5.588
223	55	3240	5.6642
380	95	951	9.017
9	124	1150	9.000"""
dat=dat.split("\n")
header=dat[0].split()
tab=pd.DataFrame(columns=header)
for d in dat[1:] :
    tab=pdaddrow(tab,d,"\t")
tab


# In[ ]:


def grams(grains):
    return(grains*0.0647989)

def cmps(fps):
    return(fps*12.0*2.54)

def mps(cps):
    return(cps/100.0)

def secpmile(fps):
    return(5280.0/fps)

def ergs(cmps,grams):
    return(0.5*grams*cmps**2)

def joules(ergs):
    return(ergs*1e-7)

def ftlb(joules):
    return(joules*0.737562)

def dm(fps):
    return((0.5*32*(5280.0/fps)**2))

def d50(fps):
    return((0.5*32*(150.0/fps)**2*12.0))

def pir2(d):
    from numpy import pi
    r=d/2.0
    return((pi*r*r)/(1000**2))


# In[ ]:


wt=36
fps=1260
gm=grams(wt)
cms=cmps(fps)
ms=mps(cms)
spm=secpmile(fps)
e=ergs(cms,gm)
j=joules(e)
f=ftlb(j)
d5280=dm(fps)
d150=d50(fps)
print(wt,fps,gm,cms,ms,spm,e,j,f,d5280,d150)




# In[ ]:


tab['Grams'] = tab.apply(lambda x: grams(float(x['Grains'])), axis=1)
tab['cm/sec'] = tab.apply(lambda x: cmps(float(x['FPS'])), axis=1)
tab['m/sec'] = tab.apply(lambda x: mps(float(x['cm/sec'])), axis=1)
tab['sec/mile'] = tab.apply(lambda x: secpmile(float(x['FPS'])), axis=1)
tab['ergs'] = tab.apply(lambda x: ergs(float(x['cm/sec']),float(x['Grams'])), axis=1)
tab['Joules'] = tab.apply(lambda x: joules(float(x['ergs'])), axis=1)
tab['Ft-lbs'] = tab.apply(lambda x: ftlb(float(x['Joules'])), axis=1)
tab['mile drop (ft)'] = tab.apply(lambda x: dm(float(x['FPS'])), axis=1)
tab['50 yd drop (in)'] = tab.apply(lambda x: d50(float(x['FPS'])), axis=1)
tab['area'] = tab.apply(lambda x: pir2(float(x['width'])), axis=1)


tab


# In[ ]:


#https://sciencing.com/projectile-motion-physics-definition-equations-problems-w-examples-13720233.html
#https://sciencing.com/calculate-bullet-trajectory-5185428.html

def xt(area=4.8e-5,c=0.295,mass=0.016,v0=400,tmax=1,dt=0.01):
    import numpy as np
    from scipy.integrate import odeint
    def drag(v):
        p=1.2
        f=-(c*p*area*v*v)/2.0
        #f=-(c*p*a*400*400)/2.0
        return(f)
    def dvdt(y,t):
        acc=drag(y[1])/mass
        return(y[1],acc)
    y0=np.array([0,v0])
    #print(y0)
    a=0
    b=tmax+dt
    t=np.arange(a,b,dt)
    y = odeint(dvdt, y0, t)
    arr = np.empty((0,2), float)
    #print(arr)
    for item in zip(t,y):
        #print(item[0],item[1][0])
        #print(item[0],item[1][0])
        arr = np.append(arr, np.array([[item[0],item[1][0]]]), axis=0)
        #arr = np.append(arr,z, axis=0)
    return(arr)


def xvt(area=4.8e-5,c=0.295,mass=0.016,v0=400,tmax=1,dt=0.01):
    import numpy as np
    from scipy.integrate import odeint
    def drag(v):
        p=1.2
        f=-(c*p*area*v*v)/2.0
        #f=-(c*p*a*400*400)/2.0
        return(f)
    def dvdt(y,t):
        acc=drag(y[1])/mass
        return(y[1],acc)
    y0=np.array([0,v0])
    #print(y0)
    a=0
    b=tmax+dt
    t=np.arange(a,b,dt)
    y = odeint(dvdt, y0, t)
    #print(y)
    arr = np.empty((0,2), float)
    #print(arr)
    for item in zip(t,y):
        #print(item[0],item[1][0])
        #print(item[0],item[1][0])
        arr = np.append(arr, np.array([[item[0],item[1][0]]]), axis=0)
        #arr = np.append(arr,z, axis=0)
    v = np.empty((0,2), float)
    #print(arr)
    for item in zip(t,y):
        #print(item[0],item[1][0])
        #print(item[0],item[1][0])
        v = np.append(v, np.array([[item[0],item[1][1]]]), axis=0)
        #arr = np.append(arr,z, axis=0)
    return(arr,v)


def zt(tmax=1,dt=0.01):
    import numpy as np
    from scipy.integrate import odeint
    def grav(y,t):
        return(y[1],-9.8)
    y0=np.array([0,0])
    #print(y0)
    a=0
    b=tmax+dt
    t=np.arange(a,b,dt)
    y = odeint(grav, y0, t)
    arr = np.empty((0,2), float)
    #print(arr)
    for item in zip(t,y):
        #print(item[0],item[1][0])
        #print(item[0],item[1][0])
        arr = np.append(arr, np.array([[item[0],item[1][0]]]), axis=0)
        #arr = np.append(arr,z, axis=0)
    return(arr)


# In[ ]:


# In[ ]:


tt=1.0
delta=0.005

bull="22"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange22,v22)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop22=zt(tmax=tt,dt=delta)

bull="223"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange223,v223)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop223=zt(tmax=tt,dt=delta)

bull="380"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange380,v380)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop380=zt(tmax=tt,dt=delta)

bull="9"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange9,v9)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop9=zt(tmax=tt,dt=delta)


toplot=[[xrange223[0:,1],drop223[0:,1],"223"],[xrange22[0:,1],drop22[0:,1],"22"],[xrange380[0:,1],drop380[0:,1],"380"],[xrange9[0:,1],drop9[0:,1],"9"]]
myplot(sets=toplot,xr="0,50",yr="-0.16,0",bl="Range (m)",sl="Drop (m)",topl="Common Round Ballistics dt=0.005",width=2,do_sym="y",subgrid="2,2")


# In[ ]:


tt=1.0
delta=0.005

bull="22"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange22n,v22n)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop22=zt(tmax=tt,dt=delta)

bull="223"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange223n,v223n)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop223=zt(tmax=tt,dt=delta)

bull="380"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange380n,v380n)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop380=zt(tmax=tt,dt=delta)

bull="9"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
(xrange9n,v9n)=xvt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop9=zt(tmax=tt,dt=delta)




toplot=[[xrange223n[0:,1],drop223[0:,1],"223"],[xrange22n[0:,1],drop22[0:,1],"22"],[xrange380n[0:,1],drop380[0:,1],"380"],[xrange9n[0:,1],drop9[0:,1],"9"]]
myplot(sets=toplot,xr="0,50",yr="-0.16,0",bl="Range (m)",sl="Drop (m)",topl="Common Round Ballistics (No drag) dt=0.005",width=2,do_sym="y",subgrid="2,2")


# In[ ]:


#df = pd.DataFrame([[2000,3000,-3], [3,2,7], [2,4,1]], columns=list("ABC"))
#df.style.apply(lambda x: ["background-color: #ff33aa" if (i >= 2 and (v > x.iloc[0] + x.iloc[1] or v < x.iloc[0] - x.iloc[1])) else "" for i, v in enumerate(x)], axis = 1)
#df = pd.DataFrame([[2000,3000,-3], [3,2,7], [2,4,1]], columns=list("ABC"))
#df.style.format({'B': lambda val: f'${val:,.2f}',})




pd.set_option('display.float_format', lambda x: [f'{x:.4g}' if (x >1e6) else f'{x:10.5g}' ])
tabformated=tab.style.format({
  'Grams': lambda val: f'{val:,.2f}',
  'area': lambda val: f'{val:,.4g}',
  'cm/sec': lambda val: f'{val:,.0f}',
  'm/sec': lambda val: f'{val:,.2f}',
  'sec/mile': lambda val: f'{val:,.2f}',
  'ergs': lambda val: f'{val:,.4g}',
  'Joules': lambda val: f'{val:,.2f}',
  'mile drop (ft)': lambda val: f'{val:,.2f}',    
  '50 yd drop (in)': lambda val: f'{val:,.2f}',
  'Ft-lbs': lambda val: f'{val:,.2f}',

})




pd.set_option('display.float_format', lambda x: [f'{x:g}' if (x >1e5) \
                                                 else (f'{x:,.2f}' if (x >10 )\
                                                                        else  f'{x:10.5g}') ])




# In[ ]:


tab


# In[ ]:


tabformated


# In[ ]:


html=tab.to_html(index=False)
html=greenbar(html)
#f=open("balistics.html","w")
#f.write(html)
#f.close()
html=tabformated.to_html(index=False)
html=greenbar(html)
#need to cut out <table id=" line for green bar to work
#f=open("wtf.html","w")
#f.write(html)
#f.close()


# In[ ]:


tymer("-i")


# In[ ]:


e22=v22[:,1]**2


# In[ ]:


bull="22"
case=tab.loc[tab['Round']==bull]
mass=float(case['Grams']/1000.0)
e22=0.5*mass*v22[:,1]**2
bull="223"
case=tab.loc[tab['Round']==bull]
mass=float(case['Grams']/1000.0)
e223=0.5*mass*v223[:,1]**2
bull="9"
case=tab.loc[tab['Round']==bull]
mass=float(case['Grams']/1000.0)
e9=0.5*mass*v9[:,1]**2
bull="380"
case=tab.loc[tab['Round']==bull]
mass=float(case['Grams']/1000.0)
e380=0.5*mass*v380[:,1]**2


# In[ ]:


time=v223[:,0]


# In[ ]:


toplot=[[xrange223[0:,1],e223,"223"],[xrange22[0:,1],e22,"22"],[xrange380[0:,1],e380,"380"],[xrange9[0:,1],e9,"9"]]
myplot(sets=toplot,xr="0,50",bl="Range (m)",sl="Energy (J)",topl="Common Round Ballistics dt=0.005",width=2,do_sym="y",do_log="y",subgrid="1,1")


# In[ ]:


eb=e380
toplot=[[xrange223[0:,1],e223/eb,"223"],[xrange22[0:,1],e22/eb,"22"],[xrange380[0:,1],e380/eb,"380"],[xrange9[0:,1],e9/eb,"9"]]
myplot(sets=toplot,xr="0,50",bl="Range (m)",sl="Energy Ratio",topl="Common Round Ballistics dt=0.005",width=2,do_sym="y",subgrid="2,2")


# In[ ]:




