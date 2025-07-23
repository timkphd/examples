#!/usr/bin/env python3
### https://medium.com/@r_bilan/python-3-13-without-the-gil-a-game-changer-for-concurrency-5e035500f0da

import datetime
import sys
from multiprocessing import Process
from threading import Thread
from typing import Any, Callable
from time import time
import os

global t1,t2,t3
global iterations
global st
iterations=500000
st=0


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
    if n == 0 :
        n=iterations
        if st > 0 :
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
        thread = Thread(target=func, args=(data,))
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()


@log_time
def run_multi_processing_task(func: Callable[[Any], Any], input_data: list[Any]) -> None:
    """
    Executes a function in multiple processes concurrently.

    :param func: The function to execute, taking one argument.
    :param input_data: A list of input data that will be passed to the function.
    :return: None
    """
    processes = []

    for data in input_data:
        process = Process(target=func, args=(data,))
        processes.append(process)
        process.start()

    for process in processes:
        process.join()


@log_time
def run_single_thread_task(func: Callable[[Any], Any], input_data: list[Any]) -> None:
    """
    Executes a function in one thread.

    :param func: The function to execute, taking one argument.
    :param input_data: A list of input data that will be passed to the function.
    :return: None
    """
    for data in input_data:
        func(data)


def main(func: Callable[[Any], Any], input_data: list[Any]) -> None:
    global t1,t2,t3
    global iterations
    t1=time()
    run_single_thread_task(func=func, input_data=input_data)
    t1=time()-t1
    t2=time()
    run_multi_processing_task(func=func, input_data=input_data)
    t2=time()-t2
    t3=time()
    run_multi_thread_task(func=func, input_data=input_data)
    t3=time()-t3
    print(f"scaling {t1/t1:6.3f} {t1/t2:6.3f} {t1/t3:6.3f}")



if __name__ == "__main__":
    print(f"Current python v: {sys.version}")
    track=False
    if len(sys.argv) > 1 : st=float(sys.argv[1])

    status = True
#    if sys.version_info == (3, 13):
#        status = sys._is_gil_enabled()
    if (sys.version.find("free-threading") > -1 ):
        status=False

    print(f"Global Interpreter Lock status: {"disabled" if not status else "enabled"}")

    test_data = [iterations] * 16
    test_data[4]=0
    print(f"Length of test data: {len(test_data)}")

    main(
        func=do_something,
        input_data=test_data,
    )
