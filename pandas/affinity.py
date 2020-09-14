#!/usr/bin/env python
# coding: utf-8

# In[ ]:


script="""
#!/bin/bash 
#SBATCH --job-name="hybrid"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=18
#SBATCH --export=ALL
#SBATCH --time=00:10:00
#SBATCH --account=hpcapps
#SBATCH --partition=debug
#SBATCH -o stdout.%j
#SBATCH -e stderr.%j
#set up our environment
module purge
ml comp-intel/2018.0.3 intel-mpi/2018.0.3   

#make a dir and go there, copy our script
mkdir -p $SLURM_JOB_ID/ajob
cat $0 > $SLURM_JOB_ID/script
cd $SLURM_JOB_ID/ajob

#get hello world and compile it with mpicc 
wget -q https://raw.githubusercontent.com/timkphd/examples/master/hybrid/phostone.c 
wget -q https://raw.githubusercontent.com/timkphd/examples/master/openmp/affinity.c
 
mpicc -fopenmp phostone.c -o phostone

export OMP_NUM_THREADS=18

export KMP_AFFINITY=verbose,scatter
srun -n 2 ./phostone -t 20 -F  > output.scatter

export KMP_AFFINITY=verbose
srun -n 2 ./phostone -t 20 -F  > output.verbose

unset KMP_AFFINITY
export OMP_PLACES=cores
export OMP_PROC_BIND=spread
srun -n 2 ./phostone -t 20 -F  > output.omp

"""

postit="""
(base) el1:affinity> cat postit 
#!/bin/bash 
cd $1
echo $1
egrep "source|cpus|nodes|icc |THREADS|PLACES|BIND|GOMP|KMP|mpiexec|srun|module use|ml" script | grep -v world
cd ajob
for s in output.scatter output.verbose output.omp ; do 
  echo $s ; cat $s | grep ^00 | awk '{print $3," ", $6}' | sort -u  | wc
done
cd ../..
"""

runit="""
ddirs=`ls -1d 3* | grep -v "\."`

for d in $ddirs ; do
   ./postit $d > out.$d
done
"""

backit="""
backup out.*
"""

getit="""
scp tkaiser2@eagle:/scratch/tkaiser2/affinity/0807_105905el1_tkaiser2.tgz >(cd ~ && tar -x)
"""


# In[ ]:


import pandas as pd
thehead=["Modules","use","source","cpus-per-task","Program","Compiler","OMP_NUM_THREADS",
         "OMP_PLACES","OMP_PROC_BIND","GOMP_CPU_AFFINITY","KMP_AFFINITY","Job","Tasks","Launch","Nodes","Cores"]
dat=pd.DataFrame(columns=thehead)

import tarfile
out_tgz=tarfile.open("out.tgz")
out_tgz.extractall()

import os
arr = os.listdir('.')
#print(arr)
flist=[]
for l in arr:
    if l.find("out.3") == 0 :
        flist.append(l)
print(flist)

for ifile in flist:
    file=open(ifile,"r")
    bonk=file.read()

    bonk

    for l in ["srun","mpirun","mpiexec"] :
              if bonk.find(l) > 0:
                launch=l
    print(launch)
    for l in ["mpiicc","mpicc"]:
        if bonk.find(l) > 0:
            compiler=l
    print(compiler)

    bonk=bonk.split("\n")

    use=""
    source=""
    mods=""
    for l in bonk:
        x=l.split("--nodes=")
        if len(x)>1:
            nodes=int(x[1])
        x=l.split("--cpus-per-task=")
        if len(x)>1:
            cpus=int(x[1])
        x=l.split(" -n ")
        if len(x)>1:
            tasks=x[1].split()
            tasks=int(tasks[0])
        x=l.split("OMP_NUM_THREADS=")
        if len(x)>1:
            threads=int(x[1])
        x=l.split("use")
        if l.find("use")> -1:
            use=l
        if l.find("source")> -1:
            source=l
        if l.find("ml") == 0:
            mods=l






    

    #bonk

    run=[]
    k=0
    for l in bonk:
        if l.find("phostone") > -1  :
            run.append(k)
        k=k+1
        

    #run

    envs=["a","b","c"]
    envs[0]=bonk[run[0]+2:run[1]]
    envs[1]=bonk[run[1]+1:run[2]]
    envs[2]=bonk[run[2]+1:run[3]]

    #print(envs[2])

    cores=[]
    k=0
    for l in bonk:
        if l.find("     ") > -1  :
            l=l.split()
            cores.append(l[0])
        k=k+1
    print(cores)
    job=bonk[0]





    for i in [0,1,2] :
        OMP_PLACES=""
        for x in envs[i]:
            l=x.split("OMP_PLACES=")
            if len(l) > 1:
                OMP_PLACES=l[1]
        OMP_PROC_BIND=""
        for x in envs[i]:
            l=x.split("OMP_PROC_BIND=")
            if len(l) > 1:
                OMP_PROC_BIND=l[1]
        GOMP_CPU_AFFINITY=""
        for x in envs[i]:
            l=x.split("GOMP_CPU_AFFINITY=")
            if len(l) > 1:
                GOMP_CPU_AFFINITY=l[1]
        KMP_AFFINITY=""
        for x in envs[i]:
            l=x.split("KMP_AFFINITY=")
            if len(l) > 1:
                KMP_AFFINITY=l[1]
        row=[mods,use,source,cpus,"phostone.c",compiler,threads,OMP_PLACES,OMP_PROC_BIND,GOMP_CPU_AFFINITY,KMP_AFFINITY,job,tasks,launch,nodes,cores[i]]
        a_series = pd. Series(row, index = dat.columns)
        dat=dat.append(a_series, ignore_index=True)


# In[ ]:


pd.set_option('display.max_rows', 500)
dat


# In[ ]:


dat.to_csv("out.csv")


# In[ ]:


num={}
for n in range(0,73):
    i=len(dat.loc[dat['Cores']== str(n)])
    if i > 0 :
        num[n]=i
from sortedcontainers import SortedDict
s = SortedDict(num)
s


# num

# In[ ]:


len(dat.loc[dat['Cores']== 72])


# In[ ]:


dat.loc[dat['Cores']== '0']


# In[ ]:


len(dat.query('Cores=="72" or Cores=="36"'))


# In[ ]:





# In[ ]:


dat.query('Cores!="72" and Cores!="36" and Compiler=="mpiicc" and Cores!="0"')


# In[ ]:


len(dat.query('Cores!="72" and Cores!="36" and Compiler=="mpiicc" and Cores!="0"'))


# In[ ]:


dat.query('(Cores=="72" or Cores=="36") and Compiler=="mpiicc"')


# In[ ]:


len(dat.query('(Cores=="72" or Cores=="36") and Compiler=="mpiicc"'))


# In[ ]:


dat.query('(Cores!="72" and Cores!="36") and Compiler=="mpicc" and Cores!="0" and Cores!="2"')


# In[ ]:


dat.query('(Cores!="72" and Cores!="36") and Compiler=="mpiicc" and Cores!="0" and Cores!="2"')


# In[ ]:


len(dat.query('(Cores=="72" or Cores=="36") and Compiler=="mpicc" and OMP_NUM_THREADS!=1'))


# In[ ]:


len(dat.query('(Cores!="72" and Cores!="36") and Compiler=="mpicc" and OMP_NUM_THREADS!=1'))


# In[ ]:


dat.query('(Cores!="72" and Cores!="36" and Cores!="2" and Cores!="0") and Compiler=="mpicc"')


# In[ ]:


dat.query('(Cores!="72" and Cores!="36") and Compiler=="mpiicc" and Cores!="0"')


# In[ ]:


dat.query('Cores!="72" and Cores!="36" and Compiler=="mpicc" and Cores!="0" and Cores!="2"')


# In[ ]:


dat.query('(Cores=="72" or Cores=="36") and Compiler=="mpicc"')


# In[ ]:


failed=dat.query('(Cores=="0")')


# In[ ]:


len(failed)


# In[ ]:


success=dat.query('(Cores=="72" or Cores=="36")')


# In[ ]:


len(success)


# In[ ]:


started=dat.query('(Cores!="0")')


# In[ ]:


len(started)


# In[ ]:


wrong=started.query('(Cores!="72" and Cores!="36")')

print(len(wrong))
# In[ ]:


wrong


# In[ ]:


print(len(wrong))


# In[ ]:


41+58+9


# In[ ]:


sub=wrong.query('(Cores!="2")')


# In[ ]:


len(sub)


# In[ ]:


sub


# In[ ]:


sub_icc=sub.query('(Compiler!="mpiicc")')


# In[ ]:


print(sub_icc)


# In[ ]:


sub_gcc=sub.query('(Compiler!="mpicc")')


# In[ ]:


print(sub_gcc)


# In[ ]:


suc_icc=success.query('(Compiler=="mpiicc")')


# In[ ]:


suc_gcc=success.query('(Compiler=="mpicc")')


# In[ ]:


suc_icc


# In[ ]:


len(suc_icc)


# In[ ]:


len(suc_gcc)


# In[ ]:


print(suc_icc)


# In[ ]:


print(suc_gcc)


# In[ ]:




