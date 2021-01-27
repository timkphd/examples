#!/usr/bin/env python
import mpi4py
from mpi4py.futures import MPIPoolExecutor
from mpi4py.futures import MPICommExecutor
from random import random,randint
import sys
import os
global done
done=0

notes="""
This program shows how to use mpi4py's built in bag of task feature.
The work being performed is defined in the dummy function task.  task
gets values from its argument list.  In this case we are passing it
a random word from the function ranword and an integer.  The integer 
is just the index of the task that is being run.  task creates a 
string out of the arguments, sleeps for some time and then returns.

We create a dictionary "marty" to hold a list of running tasks.

In the main program we set the total number of runs to be 30 and the
number of simultaneous tasks to maxq=3.  

We go into the while loop checking if the number of tasks in marty
is less than maxq and we have not launched our whole set of runs.   We
print when we have added work.

We then check our list of tasks in marty for ones that are done.  If
it is done we print the result and remove it from the list of work.

Note that the call to done is nonblocking.

The srun commands shown at the bottom is for running with mpi4py with
IntelMPI as the backend MPI inside of a interactive session. 

srun  -u -n 4 --nodes=2 python -m mpi4py.futures ./primes.py 
hangs on multiple nodes with Intel MPI, works with mpt and openmpi
"""

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
    global done
    myval = 0
    # Iterating over the Python args tuple
    st=time.asctime()
    astr=""
    streal=time.time()
    for x in args:
        astr=astr+str(x)+" "
    time.sleep(3+5*random())
    etreal=time.time()
    et=time.asctime()
    return mpi4py.MPI.Get_processor_name()+" "+str(etreal-streal)+" "+st+" "+et+" "+astr+" "+" "+str(done)


def test_work(marty,nruns,maxq,done,started):
    work={}
    with MPICommExecutor(comm, root=0) as executor:
        if executor is None: return # worker process
        while done < nruns :
            if len(marty) < maxq  and  started < nruns :
                # our input is just a random word, could be a list of inputs or directories
                x=ranword()
                # put the work in the queue
                marty[x]=executor.submit(task,x,started)
                started=started+1
                print("added work ",done,started,x)
            # check our list for done work
            for key in  list(marty) : 
                f=marty[key]
                if f.done() :
                    # print result and remove it from the dictionary
                    done = done+1
                    dt=str(f.result())
                    dt=dt.split()
                    if dt[0] in work:
                        work[dt[0]]=float(dt[1])+work[dt[0]]
                    else:
                        work[dt[0]]=float(dt[1])
                    print(f.result(),started,done," myid ",myid)
                    del marty[key]
        return(work)
        executor.shutdown(False)
if __name__ == '__main__' :
    import time
    now1=time.time()
    from mpi4py import MPI
    comm=MPI.COMM_WORLD
    print("start time ",time.asctime())
    # our dictionary to hold things in progress
    marty={}
    # number of runs to do
    nruns=10
    # maximum number to be running at one time
    maxq=3
    done = 0
    myid=comm.Get_rank()
    t1=time.time()
    bonk=test_work(marty,nruns,maxq,0,0)
    t2=time.time()
    print("back loop",time.asctime(),myid)
    if myid == 0:
        work=0
        for w in bonk.values() :
            work=work+w
        print(bonk)
        fstr="dt: {:5.2f} work: {:5.2f} speedup: {:5.2f}"
        print(fstr.format(t2-t1,work,work/(t2-t1)))
    MPI.Finalize()
"""
(dompi) hexagon:mpi4py tkaiser$ mpirun -n 1 ./queue.py 
... 
"""

"""

el1:mpi4py> srun  --x11 --account=hpcapps --time=1:00:00 --partition=debug --ntasks=8 --nodes=2 --pty bash
srun: job 5139628 queued and waiting for resources
srun: job 5139628 has been allocated resources
r105u33:mpi4py> module load conda
r105u33:mpi4py> module load mpt
(base) r105u33:mpi4py> source activate dompt
(/home/tkaiser2/.conda-envs/dompi) r105u33:mpi4py> srun -u -n 4 python  ./q4.py
...
...
back loop Tue Jan 26 12:18:31 2021 2
back loop Tue Jan 26 12:18:31 2021 3
back loop Tue Jan 26 12:18:31 2021 1
back loop Tue Jan 26 12:18:31 2021 0
{'r103u21': 16.681427478790283, 'r103u23': 38.87218260765076}
dt: 23.05 work: 55.55 speedup:  2.41

hangs on multiple nodes with Intel MPI, works with mpt and openmpi
"""

