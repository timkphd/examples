#!/usr/bin/env python
import mpi4py
from mpi4py.futures import MPIPoolExecutor
from random import random,randint


notes="""
This program shows how to use mpi4py's built in bag of task feature.
The work being performed is defined in the dummy function task.  task
gets values from its argument list.  In this case we are passing it
a random word from the function ranword and an integer.  The integer 
is just the index of the task that is being run.  task creates a 
string out of the arguments, sleeps for some time and then returns.

We create a dictionary "future" to hold a list of running tasks.

In the main program we set the total number of runs to be 30 and the
number of simultaneous tasks to maxq=3.  

We go into the while loop checking if the number of tasks in future
is less than maxq and we have not launched our whole set of runs.   We
print when we have added work.

We then check our list of tasks in future for ones that are done.  If
it is done we print the result and remove it from the list of work.

Note that the call to done is nonblocking.

The srun commands shown at the bottom is for running with mpi4py with
IntelMPI as the backend MPI inside of a interactive session. 
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
r105u33:mpi4py> module load conda
r105u33:mpi4py> module load intel-mpi/2020.1.217
(base) r105u33:mpi4py> source activate dompi
(/home/tkaiser2/.conda-envs/dompi) r105u33:mpi4py> srun -u -n 4 python -m mpi4py.futures ./queue.py
...
"""

