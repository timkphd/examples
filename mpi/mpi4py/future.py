#!/usr/bin/env python
import mpi4py
from mpi4py.futures import MPIPoolExecutor
from random import random

def task(*args, **kargs) :
    import time
    myval = 0
    # Iterating over the Python args tuple
    st=time.asctime()
    for x in args:
        myval += x
    time.sleep(5)
    et=time.asctime()
    return st+" "+et+" "+str(myval)


if __name__ == '__main__' :
    import time
    now1=time.time()
    print("start time ",time.asctime())
    future=[]
    nruns=15
    with MPIPoolExecutor() as executor:
        for i in range(0,nruns) : 
            future.append(executor.submit(task, i, i/100.0))
            #print(i)

        #print(future)
        for i in range(0,nruns) : 
            f=future[i]
            # We can check on [running,done,cancelled] 
            # or just wait for the result as we do here.
            result1=f.result()
            # This will force a synchronous termination 
            # which is most likely not what you want in
            # a real simulation. 
            print(result1)
    now2=time.time()
    print(" end time ",time.asctime(),now2-now1)
     
"""
(dompi) hexagon:~ tkaiser$ mpiexec -n 1  ./future.py
start time  Mon Nov 16 12:00:21 2020
Mon Nov 16 12:00:21 2020 Mon Nov 16 12:00:26 2020 0.0
Mon Nov 16 12:00:21 2020 Mon Nov 16 12:00:26 2020 1.01
Mon Nov 16 12:00:21 2020 Mon Nov 16 12:00:26 2020 2.02
Mon Nov 16 12:00:21 2020 Mon Nov 16 12:00:26 2020 3.03
Mon Nov 16 12:00:21 2020 Mon Nov 16 12:00:26 2020 4.04
Mon Nov 16 12:00:26 2020 Mon Nov 16 12:00:31 2020 5.05
Mon Nov 16 12:00:26 2020 Mon Nov 16 12:00:31 2020 6.06
Mon Nov 16 12:00:26 2020 Mon Nov 16 12:00:31 2020 7.07
Mon Nov 16 12:00:26 2020 Mon Nov 16 12:00:31 2020 8.08
Mon Nov 16 12:00:26 2020 Mon Nov 16 12:00:31 2020 9.09
Mon Nov 16 12:00:31 2020 Mon Nov 16 12:00:36 2020 10.1
Mon Nov 16 12:00:31 2020 Mon Nov 16 12:00:36 2020 11.11
Mon Nov 16 12:00:31 2020 Mon Nov 16 12:00:36 2020 12.12
Mon Nov 16 12:00:31 2020 Mon Nov 16 12:00:36 2020 13.13
Mon Nov 16 12:00:31 2020 Mon Nov 16 12:00:36 2020 14.14
 end time  Mon Nov 16 12:00:36 2020 15.142319679260254
(dompi) hexagon:~ tkaiser$ 
"""