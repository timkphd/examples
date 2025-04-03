#!/usr/bin/env python3
def acquire(lock_file):
#https://gist.github.com/jirihnidek
#  flock_example.py

    open_mode = os.O_RDWR | os.O_CREAT | os.O_TRUNC
    fd = os.open(lock_file, open_mode)

    pid = os.getpid()
    lock_file_fd = None
    
    timeout = 5.0
    start_time = current_time = time.time()
    while current_time < start_time + timeout:
        try:
            # The LOCK_EX means that only one process can hold the lock
            # The LOCK_NB means that the fcntl.flock() is not blocking
            # and we are able to implement termination of while loop,
            # when timeout is reached.
            # More information here:
            # https://docs.python.org/3/library/fcntl.html#fcntl.flock
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except (IOError, OSError):
            pass
        else:
            lock_file_fd = fd
            break
        print(f'  {pid} waiting for lock')
        time.sleep(0.5)
        current_time = time.time()
    if lock_file_fd is None:
        os.close(fd)
    return lock_file_fd


def release(lock_file_fd):
    # Do not remove the lockfile:
    #
    #   https://github.com/benediktschmitt/py-filelock/issues/31
    #   https://stackoverflow.com/questions/17708885/flock-removing-locked-file-without-race-condition
    fcntl.flock(lock_file_fd, fcntl.LOCK_UN)
    os.close(lock_file_fd)
    return None

import os
import sys 
import numpy as np
import time
inv=np.linalg.inv
n=np.ones([5],dtype=int)
n[0]=10
n[1]=20
n[2]=30
n[3]=40
n[4]=100
iargs=len(sys.argv)
if iargs > 6:
    iargs=6
if iargs > 1:
    for i in range(1,iargs):
        try:
            n[i-1]=int(sys.argv[i])
        except:
            n[i-1]=100
        if  n[i-1] == 1 :  n[i-1]=-1

size=n[4]
for k in range(0,10) :
    print(k,n)
    ray1=np.ones([size,size])*0.1
    for i in range(0,size):
        ray1[i,i]=n[0]
    ray2=np.ones([size,size])*0.1
    for i in range(0,size):
        ray2[i,i]=n[1]
    ray3=np.ones([size,size])*0.1
    for i in range(0,size):
        ray3[i,i]=n[2]
    ray4=np.ones([size,size])*0.1
    for i in range(0,size):
        ray4[i,i]=n[3]
    
    tstart=time.time()
    ####
    t1s=time.time()
    over1=inv(ray1)
    t1e=time.time()
    
    ####
    t2s=time.time()
    over2=inv(ray2)
    t2e=time.time()
    
    ####
    t3s=time.time()
    over3=inv(ray3)
    t3e=time.time()
    
    #####
    t4s=time.time()
    over4=inv(ray4)
    t4e=time.time()
    
    print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray1, over1), np.eye(size)),t1s-tstart,t1e-t1s))
    print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray2, over2), np.eye(size)),t2s-tstart,t2e-t2s))
    print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray3, over3), np.eye(size)),t3s-tstart,t3e-t3s))
    print("%s %10.6f %10.6f" % (np.allclose(np.dot(ray4, over4), np.eye(size)),t4s-tstart,t4e-t4s))
    #time.sleep(5)
x=os.popen("hostname","r")
hostname=x.readline().strip()
x.close()
taskid=os.environ.get('SLURM_ARRAY_TASK_ID','-1')
jobid=os.environ.get('SLURM_ARRAY_JOB_ID','-1')
wd=os.environ.get('SLURM_SUBMIT_DIR',os.getcwd())
print(jobid,taskid,hostname,wd)
REPORT=True
if REPORT :
    import fcntl
    pid = os.getpid()
    print(f'{taskid} is waiting for lock')
    fd = acquire(wd+'/myfile.lock')
    if fd is None:
        print(f'ERROR: {taskid} lock NOT acquired')
    print(f"{taskid} lock acquired...")
    file1 = open(wd+'/myfile.txt', "a")
    aline=f"{jobid} {taskid} {hostname} {wd}"
    file1.write(aline+"\n")
    file1.close()
    time.sleep(0.10)
    release(fd)
    print(f"{taskid} lock released")  
