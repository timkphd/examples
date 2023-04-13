#!/usr/bin/env python
# coding: utf-8

# ```
# 
# export BIND=v,cores
# export CRAY_OMP_CHECK_AFFINITY=TRUE
# #export OMP_PROC_BIND=spread
# export nc=`cat cases | wc -l`
# #for bindit in none rank rank_ldom threads ldoms ; do
# for il in `seq $nc` ; do
#   aline=`cat cases | head -$il | tail -1`
#   ntpn=`echo $aline | awk {'print $1'}`
#   nthrd=`echo $aline | awk {'print $2'}`
#   export OMP_NUM_THREADS=$nthrd
# #for bindit in MASK ; do
# for bindit in NONE MASK ; do
#   export KMP_AFFINITY=scatter
#   export OMP_PROC_BIND=spread
#   export BIND=--cpu-bind=v,${bindit}
#   unset CPUS_TASK
#   #export CPUS_TASK="--cpus-per-task=$nthrd"
#   if [ $bindit == MASK ] ; then
#      cores=`expr $ntpn \* $nthrd`
#      MASK=`./maskgenerator.py $cores $ntpn`
#      BIND="--cpu-bind=v,mask_cpu:$MASK"
#   fi
#   if [ $bindit == NONE ] ; then
#      BIND="--cpu-bind=v"
#      export CPUS_TASK="--cpus-per-task=$nthrd"
#   fi
#   echo $ntpn $nthrd >> srunsettings
#   echo $BIND $CPUS_TASK >> srunsettings
#   printenv | egrep "OMP_|KMP_" >> srunsettings
#   echo --mpi=pmi2 $BIND  --tasks-per-node=$ntpn $CPUS_TASK >> srunsettings
# 
# 
# #Run each version
# module purge
# module load craype-x86-spr
# module load PrgEnv-cray
# srun --mpi=pmi2 $BIND  --tasks-per-node=$ntpn $CPUS_TASK  ./f.cray $CLA > f.cray.out_${ntpn}_${nthrd}_${bindit} 2> f.cray.err_${ntpn}_${nthrd}_${bindit}
# srun --mpi=pmi2 $BIND  --tasks-per-node=$ntpn $CPUS_TASK  ./c.cray $CLA > c.cray.out_${ntpn}_${nthrd}_${bindit} 2> c.cray.err_${ntpn}_${nthrd}_${bindit}
# ...
# ...
# 
# ```

# In[ ]:


#thenode="X9000C3S2B0N0"
pal1='gist_rainbow'
pal2='gist_ncar'

def procit(f_in):
    x=open(f_in,"r")
    f1="threads."+f_in
    f2="tasks."+f_in
    x1=open(f1,"w")
    x2=open(f2,"w")
    dat=x.readlines()
    for d in dat:
        d=d.split()
        try:
            if int(d[0]) == 0 and int(d[1]) == 0 :
                thenode=d[2]
                #print(thenode)
                break
        except:
            pass
    for d in dat:
        if d.find(thenode) > -1:
            d=d.split()
            #print(d)
            core=d[5]
            task=d[0]
            thread=d[1]
            x1.write(str(core)+" "+str(thread)+"\n")
            x2.write(str(core)+" "+str(task)+"\n")
    x.close()
    x1.close()
    x2.close()
    return(f1,f2,f_in+".pdf")


# In[ ]:


def alternate(amap,newsize):
    b2=amap.resampled(newsize)
    bonk=[]
    lower=0
    if(newsize % 2 ) == 1 :
        upper=b2.N-2
    else:
        upper=b2.N-1
    for k in range(0,b2.N):
        if k % 2 == 0:
            #print(k,lower)
            bonk.append(b2(lower))
            lower=lower+2
        else:
            #print(k,upper)
            bonk.append(b2(upper))
            upper=upper-2
    col2=ListedColormap(bonk)
    return col2

def domine():
    import numpy as np
    from matplotlib.colors import ListedColormap
    base=[[0,0,1],[0,1,0],[0,1,1],[1,0,0],[1,0,1],[1,1,0],[1,1,1]]
    bonk=[]
    bonk.append((0.0,0.0,0.0))
    for x in np.arange(.5,1,.035):
        for k in base:
            bonk.append((k[0]*x,k[1]*x,k[2]*x))
    print(len(bonk))
    return ListedColormap(bonk)


mycol=domine()


# In[ ]:


def plotit(f1,f2,savefile="",showit=True):
    import matplotlib.pyplot as plt
    from matplotlib.cm import get_cmap
    import numpy.random as rnd
    from matplotlib.patches import Ellipse
    import time
    from matplotlib.pyplot import gcf
    amap=get_cmap(pal1)
    cmap=get_cmap(pal2)
    
    dat=open(f1,"r")
    input=dat.readlines()
    len(input)
    NUM = len(input)
    #threads
    ells=[]
    tmax=0
    for x in input:
        x=x.split()
        x=int(x[1])
        if x > tmax : tmax=x
    b2=amap.resampled(tmax+1)
    #for i in range(0,tmax+1):
    #    print(i,b2(i))
    for x in input:
        x=x.split()
        tile=int(x[0]) // 13;
        subcore=int(x[0]) % 13
        ells.append(Ellipse(xy=(tile,subcore), width=0.5, height=0.5, angle=0,facecolor=b2(int(x[1]))))    
    #tasks
    dat=open(f2,"r")
    input=dat.readlines()
    len(input)
    NUM = len(input)
    k=0
    ells2=[]
    ells2=[]
    tmax=0
    for x in input:
        x=x.split()
        x=int(x[1])
        if x > tmax : tmax=x
    b2=cmap.resampled(tmax+1)
    #for i in range(0,tmax+1):
    #    print(i,b2(i))
    for x in input:
        x=x.split()
        tile=int(x[0]) // 13;
        subcore=int(x[0]) % 13
        ells2.append(Ellipse(xy=(tile,subcore), width=1.0, height=1.0, angle=0,facecolor=b2(int(x[1]))))    

    #fig, ax = plt.subplots(figsize=(4*.9,4*1.2), nrows=1, ncols=2)
    fig, ax = plt.subplots(figsize=(7.25,6), nrows=1, ncols=2)
    col1=0
    col2=1
    for e in ells:
        ax[col2].add_artist(e)
    ax[col2].set_xlim(-1,8)
    ax[col2].set_ylim(13,-1)
    ax[col2].set_title(f1)

    for e in ells2:
        ax[col1].add_artist(e)
    ax[col1].set_xlim(-1,8)
    ax[col1].set_ylim(13,-1)
    ax[col1].set_title(f2)



    dat.close()
    x=time.localtime()
    stime=("%2.2d%2.2d%2.2d%2.2d%2.2d%2.2d" % (x[0]-2000,x[1],x[2],x[3],x[4],x[5]))
    sfile=stime+".pdf"

    if (showit) : plt.show()
    if len(savefile)> 0: fig.savefig(savefile)
    plt.close()


# In[ ]:


def plot1(f1,f2,savefile="",showit=True):
    import matplotlib.pyplot as plt
    from matplotlib.cm import get_cmap
    import numpy.random as rnd
    from matplotlib.patches import Ellipse
    import time
    from matplotlib.pyplot import gcf
    amap=get_cmap(pal1)
    cmap=get_cmap(pal2)

    dat=open(f1,"r")
    input=dat.readlines()
    len(input)
    NUM = len(input)
    #threads
    ells=[]
    tmax=0
    for x in input:
        x=x.split()
        x=int(x[1])
        if x > tmax : tmax=x
    b2=amap.resampled(tmax+1)
    #for i in range(0,tmax+1):
    #    print(i,b2(i))
    for x in input:
        x=x.split()
        tile=int(x[0]) // 13;
        subcore=int(x[0]) % 13
        ells.append(Ellipse(xy=(tile,subcore), width=0.5, height=0.5, angle=0,facecolor=b2(int(x[1]))))    
    #tasks
    dat=open(f2,"r")
    input=dat.readlines()
    len(input)
    NUM = len(input)
    k=0
    ells2=[]
    ells2=[]
    tmax=0
    for x in input:
        x=x.split()
        x=int(x[1])
        if x > tmax : tmax=x
    b2=cmap.resampled(tmax+1)
    #for i in range(0,tmax+1):
    #    print(i,b2(i))
    for x in input:
        x=x.split()
        tile=int(x[0]) // 13;
        subcore=int(x[0]) % 13
        ells2.append(Ellipse(xy=(tile,subcore), width=1.0, height=1.0, angle=0,facecolor=b2(int(x[1]))))    

    fig, ax = plt.subplots(figsize=(4*.9,4*1.2), nrows=1, ncols=1)
    k=0
    for e in ells2:
        ax.add_artist(e)
        k=k+1

    k=0
    for e in ells:
        ax.add_artist(e)
        k=k+1


    ax.set_xlim(-1,8)
    ax.set_ylim(13,-1)
    ax.set_title(f1.replace("threads.",""))

    dat.close()
    x=time.localtime()
    stime=("%2.2d%2.2d%2.2d%2.2d%2.2d%2.2d" % (x[0]-2000,x[1],x[2],x[3],x[4],x[5]))
    sfile=stime+".pdf"

    if (showit) : plt.show()
    if len(savefile)> 0: fig.savefig(savefile)
    plt.close()


# In[ ]:





# In[ ]:


aset=["c.cray.out_X_Y_NONE" ,
      "c.cray.out_X_Y_MASK" ,
      "c.intel.out_X_Y_NONE",
      "c.intel.out_X_Y_MASK",
      "c.gnu.out_X_Y_NONE"  ,
      "c.gnu.out_X_Y_MASK"  ,
      "c.impi.out_X_Y_NONE" ,
      "c.impi.out_X_Y_MASK"]
all=[[104,1],[52,2],[52,1],[26,4],[26,2],[26,1],[13,4],[13,2],[13,1],[8,13],[4,26],[4,13],[4,8],[2,52],[2,26],[2,13],[2,8],[1,104],[1,91],[1,78],[1,65],[1,52],[1,26],[1,13],[1,8]]
all=[[26,4]]
pal1='terrain_r'
pal1='gist_rainbow'
pal2='RdYlBu_r'
pal1='RdYlBu_r'
pal2=mycol
saveit=False
see=True

for select in all:
    threads=str(select[0])
    tasks=str(select[1])
    for a in aset:
        a=a.replace("X",threads)
        a=a.replace("Y",tasks)
        #print(a)
        [f1,f2,f3]=procit(a)
        f4=f3.replace(".pdf","_s.pdf")
        if saveit :
            plotit(f1,f2,savefile=f3,showit=see)
            plot1(f1,f2,savefile=f4,showit=see)
        else:
            plotit(f1,f2,showit=see)
            plot1(f1,f2,showit=see)
print("DONE")


# In[ ]:




