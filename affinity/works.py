#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
t="IntelMPI/Intel t=99.83 cpu-bind=NONE n=16 cpus-per-task=4 OMP_PROC_BIND=close OMP_NUM_THREADS=4 "
#Type	Compiler	mpi	cpu-bind	OMP_PROC_BIND	threads	tasks	time
global cases,thedirs
cases=[]
thedirs=[]
def topd(t,ofn):
    global cases
    t=t.replace("\n"," ")
    rtype="None"
    mpi="None"
    compiler="None"
    if t.find("ifort") > -1 :
        compiler="ifort"
    if t.find("gfortran") > -1 :
        compiler="gfortran"
    if t.find("IntelMPI/Intel") > -1:
        compiler="ifort"
        mpi="intel"
    if t.find("OpenMPI/Intel") > -1:
        compiler="ifort"
        mpi="openmpi"
    if t.find("IntelMPI/GNU") > -1:
        compiler="gfortran"
        mpi="intel"
    if t.find("OpenMPI/GNU") > -1:
        compiler="gfortran"
        mpi="openmpi"
    x=t.split(" t=")
    x=x[1]
    x=x.split(" ")
    mtime=float(x[0])
    try:
        x=t.split(" cpu-bind=")
        x=x[1]
        x=x.split(" ")
        cpubind=x[0]
    except:
        cpubind="None"
    try:
        x=t.split(" n=")
        x=x[1]
        x=x.split(" ")
        n=x[0]
    except:
        n=1
    try:
        x=t.split(" cpus-per-task=")
        x=x[1]
        x=x.split(" ")
        cpus_per_task=int(x[0])
    except:
        cpus_per_task=0
    try:
        x=t.split(" OMP_PROC_BIND=")
        x=x[1]
        x=x.split(" ")
        omp_proc_bind=x[0]
    except:
        omp_proc_bind="None"
    try:
        x=t.split(" OMP_NUM_THREADS=")
        x=x[1]
        x=x.split(" ")
        omp_num_threads=int(x[0])
    except:
        omp_num_threads=0
    if(mpi == "None"): mtype="openmp"
    if(mpi != "None" and omp_num_threads > 0 ): mtype="hybrid"
    if(mpi != "None" and omp_num_threads ==0 ): mtype="mpi"
    if omp_num_threads == 0 :
        cores=n
    else:
        cores=int(n)*int(omp_num_threads)
    return[mtime,mtype,compiler,mpi,cpubind,cpus_per_task,omp_proc_bind,n,omp_num_threads,cores,ofn]

def pdappend(df,line):   
    a_series = pd.Series(line, index = df.columns)   
    return df.append(a_series, ignore_index=True)   

head=['time','type','compiler','mpi','cpubind','cpus_per_task','omp_proc_bind','tasks','omp_num_threads','cores','file']
results=pd.DataFrame(columns=head) 


# In[ ]:


from os.path import exists
def nfname(path,ex=""):
    if exists(path+ex):
        print(path + " EXISTS")
        return(path+"_a")
    else:
        print(path)
        return(path)
    
    


# In[ ]:



def doit(hdir,base):
    global results
    global cases
    global thedirs
    thedirs.append(hdir)
    nplots=0
    for ver in ["stf_ii","stf_ig","stf_og","stf_oi"] :
    #for ver in ["stf_og"] :
        import os
        import numpy as np
        from plsub import myplot
        import matplotlib.pyplot as plt
        command="grep cpus-per-task "+hdir+"/script* | tail -1"
        #print(command)
        c=os.popen(command,"r")
        lines=c.read()
        #print("lines",lines)
        cpt="NONE"
        if len(lines) > 0 :
            cpt=lines.replace("#SBATCH --","")
            cpt=cpt.strip()
        #print(cpt)
        command="grep -l "   +ver+ " " +hdir+"/2*"
        c=os.popen(command,"r")
        files=c.read()
        #print(files)
        cores=np.array(range(0,64))
        sums=np.zeros(64)
        mins=np.zeros(64)+1e6
        maxs=np.zeros(64)-1e6
        icnt=np.zeros(64)
        nf=0
        files=files.split()
        #print(files)
        nt=len(files)
        heat=np.zeros([nt,64])
        print()
        for f in files:
            #print(f)
            nf=nf+1
            infile=open(f,"r")
            dat=infile.readlines()
            isums=np.zeros(64)
            imins=np.zeros(64)+1e6
            imaxs=np.zeros(64)-1e6
            for d in dat:
                d=d.split()
                l=float(d[4])
                c=int(d[6]) % 64
            #print(c,l)
                isums[c]=isums[c]+l
                heat[nf-1,c]=heat[nf-1,c]+l
                icnt[c]=1
            for c in range(0,64) :
                if isums[c] < imins[c] : imins[c]=isums[c]
                if isums[c] > imaxs[c] : imaxs[c]=isums[c]
            sums=sums+isums
            for c in range(0,64) :
                if imins[c] < 1e5:
                    if imins[c] < mins[c]: mins[c]=imins[c]
                if imaxs[c] > 0.0:
                    if imaxs[c] > maxs[c]: maxs[c]=imaxs[c]
            #print(f)
   
        sums=sums/nf
        cores=[]
        fmins=[]
        faves=[]
        fmaxs=[]
        #print(sums)
        for c in range(0,64):
            if sums[c] > 0.0:
                cores.append(c)
                fmins.append(mins[c])
                faves.append(sums[c])
                fmaxs.append(maxs[c])
                #print(c,mins[c],sums[c],maxs[c])
        #print(len(cores),fmins,faves,fmaxs)
        asets=[[cores,fmins,"min"],[cores,faves,"ave"],[cores,fmaxs,"max"]]
        #myplot(sets=asets,doxkcd=False,width=0,do_sym="y",bl="Physical Core",sl="Load",topl=title,outname=ver+"-"+edir,yr="90,105",xr="0,64")
        command="grep srun "+hdir+"/script* | tail -1"
        c=os.popen(command,"r")
        lines=c.read()
        #print(lines)
        settings="cpu-bind=NONE"
        if lines.find("rank") > -1 : settings="cpu-bind=rank"
        if lines.find("socket") > -1 : settings="cpu-bind=sockets"
        if lines.find("core") > -1 : settings="cpu-bind=cores"
        #command="grep 'run time' "+hdir+"/slurm-*.out | awk {'print $NF }'"
        lines=lines.split(" -n")
        lines=lines[1]
        lines=lines.split()
        ccount=lines[0]
        #print(ccount)
        command="grep 'run time' "+hdir+"/slurm-*.out"
        c=os.popen(command,"r")
        times=c.readlines()
        #print(times)
        j=0
        for t in times:
            t=t.split("=")
            t=t[1]
            ttt=t.split()
            t=float(ttt[0])
            t="%5.2f" % (t)
            times[j]=t
            j=j+1
        #print(times)

        if ver.find("ii") > -1:
            cset="IntelMPI/Intel t="+times[0]+" "
        if ver.find("ig") > -1:
            cset="IntelMPI/GNU t="+times[1]+" "
        if ver.find("og") > -1:
            cset="OpenMPI/GNU t="+times[2]+" "
        if ver.find("oi") > -1:
            cset="OpenMPI/Intel t="+times[3]+" "
        title=cset+settings+" n="+ccount
        title=title+" "+cpt
        settings=settings.replace("cpu-bind=","")
        #get OMP_
        command="grep 'OMP_' "+hdir+"/env*"
        c=os.popen(command,"r")
        omp=c.read()
        print("bonk",omp)
        if len(omp) > 0:
            omp=omp.replace("\n"," ")
            print("OMP=",omp)
            title=title+"\n"+omp
        print(title)
        ofn=base+"/"+ver+"_"+settings+"_"+ccount+"_"+cpt
        ofn=nfname(ofn,".pdf")

        myplot(sets=asets,doxkcd=False,width=0,do_sym="y",bl="Physical Core",sl="Load",topl=title,outname=ofn,xr="0,64")
        t2=title.replace("\n"," ")
        cases.append(t2)
        results=pdappend(results,topd(title,ofn))
        nplots=nplots+1
        fig, ax = plt.subplots( figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
        fig.subplots_adjust(hspace=100.0, wspace=50)

        zmax=np.max(heat)
        zmin=np.min(heat)
        x=np.array(range(0,nt))
        x=x/(nt-1)
        cores=np.array(range(0,64))
        #print(x)
        #print(cores)
        from scipy import interpolate
        #nh= interpolate.interp2d(cores, x, heat)
        #nh= interpolate.RectBivariateSpline(cores, x, heat,kx=1,ky=1)
        #nh= interpolate.RectBivariateSpline(x, cores, heat,kx=1,ky=1,s=0)
        nh=interpolate.RegularGridInterpolator((x,cores), heat,method="nearest")
        #print(nh)
        newx=np.array(range(0,64))/64.0
        nheat=np.zeros([64,64])
        for i in range(0,64):
            for j in range(0,64):
                yi=cores[i]
                xi=newx[j]
                #print(xi,yi)
                #pts=np.array([xi,yi])
                #print(nh([[4,4]]))
                pts = np.array([[xi, yi]])
                nheat[j][i]=nh(pts)
        #c = ax.pcolormesh(x, cores, heat, cmap='RdBu', vmin=zmin, vmax=zmax)
        #heat[3]=0
        c = ax.pcolormesh(cores, x, heat, cmap='rainbow', vmin=zmin, vmax=zmax,shading='nearest')
        #c = ax.pcolormesh(cores, newx, nheat, cmap='rainbow', vmin=zmin, vmax=zmax,shading='nearest')
        #c=plt.imshow(heat,cmap='rainbow',interpolation="none")
        c=plt.imshow(nheat,cmap='rainbow',interpolation="none")
        ax.set_title(title)
        ax.set_ylabel('Relative Time')
        ax.set_xlabel('Physical Core')
        ax.set_xticks(range(0,65,4))
        yticks=range(0,65,4)
        yticks=np.array(yticks)/65
        ax.set_yticks(range(0,65,4))
        #ax.set_size=(20,2)

        #ax.axis([x.max(), x.min(), cores.min(), cores.max()])
        fig.colorbar(c, ax=ax)
        #plt.show()
        outname=base+"/"+"h_"+ver+"_"+settings+"_"+ccount+"_"+cpt
        outname=nfname(outname,".pdf")
        plt.savefig(outname+".pdf")
        nplots=nplots+1
        print(title)
        
#        for h in heat[:] :
#            print(h)
    return(nplots)


# In[ ]:


tplots=0
#base="/home/tkaiser2/bench/affinity/mpi/thu/thu"
#for set in ["32","64","128"]:
#base="/home/tkaiser2/bench/affinity/hybrid/thu/spread"
#for set in ["16","32","64"]:
base="/home/tkaiser2/bench/affinity/redo/hybrid/close"
for set in ["16","16o","32","32o","64o"]:
#for set in ["32"]:
    for ver in ["none","cores","sockets","rank"]:
    #for ver in ["none"]:
        hdir=base+"/"+set+"/"+ver
        print(hdir)
        try:
            heat=doit(hdir,base)
            tplots=tplots+heat
        except:
            print(set,ver,"failed")

print(tplots)


# In[ ]:


cases


# In[ ]:


print(tplots)
print(results)


# In[ ]:


tplots=0
#base="/home/tkaiser2/bench/affinity/mpi/thu/thu"
#for set in ["32","64","128"]:
base="/home/tkaiser2/bench/affinity/redo/hybrid/spread"
for set in ["16","16o","32","32o","64o"]:
#for set in ["16"]:
#base="/home/tkaiser2/bench/affinity/hybrid/thu/close"
#for set in ["16","32","64"]:
    for ver in ["none","cores","sockets","rank"]:
        hdir=base+"/"+set+"/"+ver
        print(hdir)
        try:
            heat=doit(hdir,base)
            tplots=tplots+heat
        except:
            print(set,ver,"failed")

print(tplots)


# In[ ]:


tplots=0
base="/home/tkaiser2/bench/affinity/redo/mpi"
for set in ["32","64","128"]:
#for set in ["128"]:
#base="/home/tkaiser2/bench/affinity/hybrid/thu/spread"
#for set in ["16","32","64"]:
#base="/home/tkaiser2/bench/affinity/hybrid/thu/close"
#for set in ["16","32","64"]:
    for ver in ["none","cores","sockets","rank"]:
        hdir=base+"/"+set+"/"+ver
        print(hdir)
        try:
            heat=doit(hdir,base)
            tplots=tplots+heat
        except:
            print(set,ver,"failed")

print(tplots)


# In[ ]:


def doomp(hdir,base,bind):
    nplots=0
    global results   
    global cases
    global thedirs
    thedirs.append(hdir)
    for ver in ["stf_ii","stf_ig"] :
        import os
        import numpy as np
        from plsub import myplot
        import matplotlib.pyplot as plt
        command="grep -l "   +ver+ " " +hdir+"/2*"
        #print("COMMAND",command)
        c=os.popen(command,"r")
        files=c.read()
        cores=np.array(range(0,64))
        sums=np.zeros(64)
        mins=np.zeros(64)+1e6
        maxs=np.zeros(64)-1e6
        icnt=np.zeros(64)
        nf=0
        files=files.split()
        #print(files)
        nt=len(files)
        heat=np.zeros([nt,64])
        
        for f in files:
            #print(f)
            nf=nf+1
            infile=open(f,"r")
            dat=infile.readlines()
            isums=np.zeros(64)
            imins=np.zeros(64)+1e6
            imaxs=np.zeros(64)-1e6
            for d in dat:
                d=d.split()
                l=float(d[4])
                c=int(d[6]) % 64
            #print(c,l)
                isums[c]=isums[c]+l
                heat[nf-1,c]=heat[nf-1,c]+l
                icnt[c]=1
            for c in range(0,64) :
                if isums[c] < imins[c] : imins[c]=isums[c]
                if isums[c] > imaxs[c] : imaxs[c]=isums[c]
            sums=sums+isums
            for c in range(0,64) :
                if imins[c] < 1e5:
                    if imins[c] < mins[c]: mins[c]=imins[c]
                if imaxs[c] > 0.0:
                    if imaxs[c] > maxs[c]: maxs[c]=imaxs[c]
    
        sums=sums/nf
        #print(sums)
        cores=[]
        fmins=[]
        faves=[]
        fmaxs=[]
        for c in range(0,64):
            if sums[c] > 0.0:
                cores.append(c)
                fmins.append(mins[c])
                faves.append(sums[c])
                fmaxs.append(maxs[c])
                #print(c,mins[c],sums[c],maxs[c])
       # print(len(cores),fmins,faves,fmaxs)
        asets=[[cores,fmins,"min"],[cores,faves,"ave"],[cores,fmaxs,"max"]]
        #myplot(sets=asets,doxkcd=False,width=0,do_sym="y",bl="Physical Core",sl="Load",topl=title,outname=ver+"-"+edir,yr="90,105",xr="0,64")
        command="grep cpus-per-task "+hdir+"/script* | tail -1"
        print(command)
        c=os.popen(command,"r")
        lines=c.read()
        #print(lines)
        settings="NONE"
        settings=lines.replace("#SBATCH --","")
        settings=settings.strip()
        #print(settings)
        
        if lines.find("rank") > -1 : settings="cpu-bind=rank"
        if lines.find("socket") > -1 : settings="cpu-bind=sockets"
        if lines.find("core") > -1 : settings="cpu-bind=cores"
        #command="grep 'run time' "+hdir+"/slurm-*.out | awk {'print $NF }'"
        #print(settings+"01")
        count=0
        try:
            lines=lines.split("-n")
            lines=lines[1]
            lines=lines.split()
            ccount=lines[0]
        except:
            #print("count failed")
            ccount="0"
        #print(settings+"02")
        #print("count=",ccount)
        command="grep 'run time' "+hdir+"/slurm-*.out"
        #print(command)
        c=os.popen(command,"r")
        times=c.readlines()
        #print(times)
        j=0
        for t in times:
            t=t.split("=")
            #print("t=",t)
            t=t[1]
            ttt=t.split()
            t=float(ttt[0])
            t="%5.2f" % (t)
            times[j]=t
            j=j+1
        #print(times)
        #print(settings+"03")
        cset="CSET"
        #print("ver",ver)
        if ver.find("ii") > -1:
            cset="ifort t="+times[0]+" "
        if ver.find("ig") > -1:
            cset="gfortran t="+times[1]+" "
        if ver.find("og") > -1:
            cset="OpenMPI/GNU t="+times[2]+" "
        if ver.find("oi") > -1:
            cset="OpenMPI/Intel t="+times[3]+" "
        #print(cset,settings,ccount)
        title=cset+settings
        #print(title)
        #settings=settings.replace("cpu-bind=","")
        #print(settings+"04")
        #get OMP_
        command="grep 'OMP_' "+hdir+"/env*"
        c=os.popen(command,"r")
        omp=c.read()
        #print("bonk",omp)
        if len(omp) > 0:
            omp=omp.replace("\n"," ")
            #print("OMP=",omp)
            title=title+"\n"+omp
        #print(title)
        ofn=base+"/"+ver+"_"+settings+"_"+ccount+"_"+bind
        ofn=nfname(ofn,".pdf")
        #print(ofn)

        myplot(sets=asets,doxkcd=False,width=0,do_sym="y",bl="Physical Core",sl="Load",topl=title,outname=ofn,xr="0,64")
        t2=title.replace("\n"," ")
        cases.append(t2)
        results=pdappend(results,topd(title,ofn))
        nplots=nplots+1
        fig, ax = plt.subplots( figsize=(12, 6), subplot_kw={'xticks': [], 'yticks': []})
        fig.subplots_adjust(hspace=100.0, wspace=50)

        zmax=np.max(heat)
        zmin=np.min(heat)
        x=np.array(range(0,nt))
        x=x/(nt-1)
        cores=np.array(range(0,64))
        #print(x)
        #print(cores)
        from scipy import interpolate
        #nh= interpolate.interp2d(cores, x, heat)
        #nh= interpolate.RectBivariateSpline(cores, x, heat,kx=1,ky=1)
        #nh= interpolate.RectBivariateSpline(x, cores, heat,kx=1,ky=1,s=0)
        nh=interpolate.RegularGridInterpolator((x,cores), heat,method="nearest")
        #print(nh)
        newx=np.array(range(0,64))/64.0
        nheat=np.zeros([64,64])
        for i in range(0,64):
            for j in range(0,64):
                yi=cores[i]
                xi=newx[j]
                #print(xi,yi)
                #pts=np.array([xi,yi])
                #print(nh([[4,4]]))
                pts = np.array([[xi, yi]])
                nheat[j][i]=nh(pts)
        #c = ax.pcolormesh(x, cores, heat, cmap='RdBu', vmin=zmin, vmax=zmax)
        #heat[3]=0
        c = ax.pcolormesh(cores, x, heat, cmap='rainbow', vmin=zmin, vmax=zmax,shading='nearest')
        #c = ax.pcolormesh(cores, newx, nheat, cmap='rainbow', vmin=zmin, vmax=zmax,shading='nearest')
        #c=plt.imshow(heat,cmap='rainbow',interpolation="none")
        c=plt.imshow(nheat,cmap='rainbow',interpolation="none")
        ax.set_title(title)
        ax.set_ylabel('Relative Time')
        ax.set_xlabel('Physical Core')
        ax.set_xticks(range(0,65,4))
        yticks=range(0,65,4)
        yticks=np.array(yticks)/65
        ax.set_yticks(range(0,65,4))
        #ax.set_size=(20,2)

        #ax.axis([x.max(), x.min(), cores.min(), cores.max()])
        fig.colorbar(c, ax=ax)
        #plt.show()
        outname=nfname(outname,".pdf")
        outname=base+"/"+"h_"+ver+"_"+settings+"_"+ccount+"_"+bind
        plt.savefig(outname+".pdf")
        nplots=nplots+1

        
        
#        for h in heat[:] :
#            print(h)
    return(nplots)


# In[ ]:


cases


# In[ ]:


tplots=0
base="/home/tkaiser2/bench/affinity/redo/omp/128"
tplots=0
for set in ["128"]:
    for ver in ["close","none","spread"]:
        hdir=base+"/"+set+"/"+ver
        print(hdir)
        try:
            heat=doomp(hdir,base,ver)
            tplots=tplots+heat
        except:
            print(set,ver,"failed")
t1=tplots


# In[ ]:


print(t1)
print(results)


# In[ ]:


base="/home/tkaiser2/bench/affinity/redo/omp/64"
for set in ["128","64"]:
    for ver in ["close","none","spread"]:
        hdir=base+"/"+set+"/"+ver
        print(hdir)
        try:
            heat=doomp(hdir,base,ver)
            tplots=tplots+heat
        except:
            print(set,ver,"failed")
t3=tplots


# In[3]:





# In[ ]:


base="/home/tkaiser2/bench/affinity/redo/omp/32"
for set in ["32"]:
    for ver in ["close","none","spread"]:
        hdir=base+"/"+set+"/"+ver
        print(hdir)
        try:
            heat=doomp(hdir,base,ver)
            tplots=tplots+heat
        except:
            print(set,ver,"failed")
t3=tplots


# In[3]:



        


# In[ ]:


def trimf(x):
    return x.replace("/home/tkaiser2/bench/affinity","")
def trimthur(x):
    return x.replace("/thu","")
def trimslash(x):
    return x.replace("/","_")
def trimone(x):
    return x[1:]
results['file']=results.apply(lambda row:trimf(row['file']),axis=1)
results['file']=results.apply(lambda row:trimthur(row['file']),axis=1)
results['file']=results.apply(lambda row:trimslash(row['file']),axis=1)
results['file']=results.apply(lambda row:trimone(row['file']),axis=1)
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)
pd.set_option('display.max_colwidth', None)

results


# In[ ]:


bytime=results.sort_values(by="time")


# In[ ]:


mpi=bytime[(bytime['type']=='mpi')]


# In[ ]:


hybrid=bytime[(bytime['type']=='hybrid')]


# In[ ]:


openmp=bytime[(bytime['type']=='openmp')]


# In[ ]:


results.to_csv('results.csv', index=False)
mpi.to_csv('mpi.csv', index=False)
hybrid.to_csv('hybrid.csv', index=False)
openmp.to_csv('openmp.csv', index=False)


# In[ ]:


bytime


# In[ ]:


bytime.to_csv('bytime.csv', index=False)


# In[ ]:


cases


# In[ ]:


len(cases)

