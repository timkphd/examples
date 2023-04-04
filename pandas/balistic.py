#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
import sys
sys.path.append("/Users/tkaiser/bin")
sys.path.append("/home/tkaiser2/bin")


# In[ ]:


dat="""Round	Grains	FPS	width
22	36	1260	5.588
223	55	3240	5.6642
380	95	951	9.017
9	124	1150	9.000"""
dat=dat.split("\n")
header=dat[0].split()
tab=pd.DataFrame(columns=header)
for d in dat[1:] :
    line=d.split()
    adict={'Round':[line[0]],'Grains':[line[1]],'FPS':[line[2]],'width':[line[3]]}
    line=pd.DataFrame(adict)
    tab= pd.concat([tab,line],ignore_index = True)


# In[ ]:


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


# In[ ]:


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




# In[ ]:


tab


# In[ ]:


#https://sciencing.com/projectile-motion-physics-definition-equations-problems-w-examples-13720233.html
#https://sciencing.com/calculate-bullet-trajectory-5185428.html


# In[ ]:


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


# In[ ]:


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


#pd.set_option('display.float_format', lambda x: f'{x:.3f}')


# In[ ]:


tab


# In[ ]:


tt=1.0
delta=0.005

bull="22"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange22=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop22=zt(tmax=tt,dt=delta)

bull="223"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange223=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop223=zt(tmax=tt,dt=delta)

bull="380"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange380=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop380=zt(tmax=tt,dt=delta)

bull="9"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange9=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta)
drop9=zt(tmax=tt,dt=delta)


# In[ ]:


from plsub import myplot


# In[ ]:


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
xrange22=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop22=zt(tmax=tt,dt=delta)

bull="223"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange223=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop223=zt(tmax=tt,dt=delta)

bull="380"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange380=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop380=zt(tmax=tt,dt=delta)

bull="9"
case=tab.loc[tab['Round']==bull]
v=float(case['m/sec'])
area=float(case['area'])
mass=float(case['Grams']/1000.0)
print(bull,v,area,mass)
xrange9=xt(area=area,mass=mass,v0=v,tmax=tt,dt=delta,c=0)
drop9=zt(tmax=tt,dt=delta)


# In[ ]:


toplot=[[xrange223[0:,1],drop223[0:,1],"223"],[xrange22[0:,1],drop22[0:,1],"22"],[xrange380[0:,1],drop380[0:,1],"380"],[xrange9[0:,1],drop9[0:,1],"9"]]
myplot(sets=toplot,xr="0,50",yr="-0.16,0",bl="Range (m)",sl="Drop (m)",topl="Common Round Ballistics (No drag) dt=0.005",width=2,do_sym="y",subgrid="2,2")


# In[ ]:


#df = pd.DataFrame([[2000,3000,-3], [3,2,7], [2,4,1]], columns=list("ABC"))
#df.style.apply(lambda x: ["background-color: #ff33aa" if (i >= 2 and (v > x.iloc[0] + x.iloc[1] or v < x.iloc[0] - x.iloc[1])) else "" for i, v in enumerate(x)], axis = 1)


# In[ ]:


#df = pd.DataFrame([[2000,3000,-3], [3,2,7], [2,4,1]], columns=list("ABC"))
#df.style.format({'B': lambda val: f'${val:,.2f}',})


# In[ ]:


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


# In[ ]:


pd.set_option('display.float_format', lambda x: [f'{x:g}' if (x >1e5) \
                                                 else (f'{x:,.2f}' if (x >10 )\
                                                                        else  f'{x:10.5g}') ])
tab


# In[ ]:


tabformated


# In[ ]:




