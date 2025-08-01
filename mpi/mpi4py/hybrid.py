#!/usr/bin/env python3
### https://medium.com/@r_bilan/python-3-13-without-the-gil-a-game-changer-for-concurrency-5e035500f0da

import datetime
import sys
#from multiprocessing import Process
from threading import Thread
from typing import Any, Callable
from time import time
import os

global t1,t2,t3
global iterations
global st
iterations=500000
st=1.0

import numpy
from numpy import *
from mpi4py import MPI
import sys
global myid
global omp

# Initialize MPI and print out hello
comm=MPI.COMM_WORLD
myid=comm.Get_rank()
numprocs=comm.Get_size()


def log_time(func: Callable[..., Any]) -> Callable[..., Any]:
    """
    A decorator that logs the execution time of a function.

    :param func: The function to be decorated.
    :return: The wrapped function with execution time logging.
    """

    def wrapper(*args: Any, **kwargs: Any) -> Any:
        start_time = datetime.datetime.now()
        result = func(*args, **kwargs)
        execution_time = datetime.datetime.now() - start_time
        print(
            f"Function '{func.__name__}' executed in {execution_time.total_seconds()} seconds."
        )
        return result

    return wrapper


def do_something(n: int = 1) -> int:
    """
    Computes the n-th Fibonacci number.

    :param n: The position in the Fibonacci sequence to compute (default is 1).
              The first Fibonacci number is at position 1.
    :return: The n-th Fibonacci number.
    """
    global iterations
    global st
    global myid
    if n == 0 :
        n=iterations
        if st > 0  and myid == 0 :
            from os import popen
            from time import sleep
            sleep(st)
            who=os.getenv("USER",'')
            if len(who) > 0 :
                who="-U "+who
            cmd="ps "+who+" -L -o pid,lwp,psr,comm,pcpu | egrep 'COMMAND|python'"
            print(cmd)
            f=popen(cmd,"r")
            z=f.readlines()
            f.close()
            for x in z:
                print(x.strip())
            
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return a


@log_time
def run_multi_thread_task(func: Callable[[Any], Any], input_data: list[Any]) -> None:
    """
    Executes a function in multiple threads concurrently.

    :param func: The function to execute, taking one argument.
    :param input_data: A list of input data that will be passed to the function.
    :return: None
    """
    threads = []
    for data in input_data:
        print("data ",data)
        thread = Thread(target=func, args=(data,))
        threads.append(thread)
        thread.start()
    for thread in threads:
        thread.join()



def main(func: Callable[[Any], Any], input_data: list[Any]) -> None:
    global t1,t2,t3
    global iterations
    global myid
    t3=time()
    run_multi_thread_task(func=func, input_data=input_data)
    t3=time()-t3
    print(f"task/time {myid:6d} {t3:6.3f}")
    MPI.Finalize()


if __name__ == "__main__":
    name = MPI.Get_processor_name()
    print(myid," of ",numprocs," on ",name)


    if myid == 0 :
#"name" fo MPI
        lib=MPI.Get_library_version()
#standard version,subversion
        standard=MPI.Get_version()
        print("MPI Version: ",lib.strip())
        print("Supports MPI standard %d.%d" %(standard[0],standard[1]))
        print(f"Current python v: {sys.version}")

    status = True
#    if sys.version_info == (3, 13):
#        status = sys._is_gil_enabled()
    if (sys.version.find("free-threading") > -1 ):
        status=False

    buffer=array([-1,-1,-1],int)
    if myid == 0 :
        if len(sys.argv) > 1 : st=float(sys.argv[1])
        st=int(st*1000)
        pytrds=os.getenv("PY_THREADS","8")
        pytrds=int(pytrds)
        print("PY_THREADS: ",pytrds)
        omp=os.getenv("OMP_NUM_THREADS","1")
        print("OMP_NUM_THREADS: ",omp)
        buffer[0]=pytrds
        buffer[1]=omp
        buffer[2]=st
    comm.Bcast([buffer,MPI.INT], root=0)
    pytrds=buffer[0]
    omp=buffer[1]
    st=buffer[2]/1000.0
    test_data = [iterations] * pytrds 
    test_data[0]=0
    print(f"Length of test data: {len(test_data)}")

    main(
        func=do_something,
        input_data=test_data,
    )
