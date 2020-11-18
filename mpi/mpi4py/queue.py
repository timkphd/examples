#!/usr/bin/env python
import mpi4py
from mpi4py.futures import MPIPoolExecutor
from random import random,randint

def ranword():
    back=""
    for j in range(0,20) :
        set=random()
        if set < 1./3 :
            myrange=[33,64]
        else:
            if set > 2./3. :
                myrange=[65,90]
            else:
                myrange=[97,122]
        i=randint(myrange[0],myrange[1])
        back=back+chr(i)
    return back
	

def task(*args, **kargs) :
    import time
    myval = 0
    # Iterating over the Python args tuple
    st=time.asctime()
    astr=""
    for x in args:
        astr=astr+str(x)+" "
    time.sleep(3+5*random())
    et=time.asctime()
    return st+" "+et+" "+astr+" "+mpi4py.MPI.Get_processor_name()


if __name__ == '__main__' :
    import time
    now1=time.time()
    print("start time ",time.asctime())
    # our dictionary to hold things in progress
    future={}
    # number of runs to do
    nruns=30
    # maximum number to be running at one time
    maxq=3
    done = 0
    started = 0
    with MPIPoolExecutor() as executor:
        while done < nruns :
            if len(future) < maxq  and  started < nruns :
                # our input is just a random word, could be a list of inputs or directories
                x=ranword()
                # put the work in the queue
                future[x]=executor.submit(task,x,started)
                started=started+1
                print("added work ",done,started,x)
            # check our list for done work
            for key in  list(future) : 
                f=future[key]
                if f.done() :
                    # print result and remove it from the dictionary
                    done = done+1
                    print(f.result(),started,done)
                    del future[key]
    now2=time.time()
    print(" end time ",time.asctime(),now2-now1)
     
"""
(dompi) hexagon:mpi4py tkaiser$ mpirun -n 1 ./queue.py 
... 
"""

"""

el1:mpi4py> srun  --x11 --account=hpcapps --time=1:00:00 --partition=debug --ntasks=8 --nodes=2 --pty bash
srun: job 5139628 queued and waiting for resources
srun: job 5139628 has been allocated resources
r105u33:mpi4py> source ~/conda_init
(base) r105u33:mpi4py> conda activate /home/tkaiser2/.conda-envs/dompi
(/home/tkaiser2/.conda-envs/dompi) r105u33:mpi4py> srun -n 7 python -m mpi4py.futures ./queue.py 
...
"""

