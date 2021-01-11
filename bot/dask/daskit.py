#!/usr/bin/env python

import time
import os
import sys
import numpy as np
import socket
from distributed import Client, LocalCluster
import dask
from collections import Counter

# get our start time
global st
st=time.time()

def test(i,j=10):
# get pid, start time, host  and sleep for j seconds
   pid=os.getpid()
   when=time.time()-st
   print("%6d   %6.2f" % (pid,when))
   time.sleep(j)
   back="%s %6.2f %s" % (str(os.getpid()),when,socket.gethostname())
   return back

def main():
#get command line arguments controling launch
   threads=1
   workers=8
   for x in sys.argv[1:] :
     if x.find("threads") > -1 :
        z=x.split("=")
        threads=int(z[1])
     if x.find("workers") > -1 :
        z=x.split("=")
        workers=int(z[1])

# launch with either threads and/or workers specified (0 = default)
   if threads == 0 and workers != 0 :
      print("lanching  %d workers, default threads" % (workers))
      cluster = LocalCluster(n_workers=workers)
   if threads != 0 and workers == 0 :
      print("lanching  %d threads, defalut workers" % (threads))
      cluster = LocalCluster(threads_per_worker=threads)
   if threads != 0 and workers != 0 :
      print("lanching  %d workers  with %d threads" % (workers,threads))
      cluster = LocalCluster(n_workers=workers,threads_per_worker=threads)
   print(cluster)
   client = Client(cluster)
   print(client)

# do serial
# NOTE: it is possible to launch an asynchronous client
# but here we just do serial synchronous.  See:
# https://distributed.dask.org/en/latest/asynchronous.html
   result = []
   print("   pid  Start T")
   for i in range (0,5):
      j=2
      result.append(client.submit(test,i,j).result())
   print(result)   
   print (Counter(result))
#do parallel
   n=15
   np.random.seed(1234)
   x=np.random.random(n)*20
#set to uniform nonzero to get uniform run times for each task
   x=np.ones(n)*10
   print(x)
   print("   pid  Start T")
   L=client.map(test,range(n),x)
   mylist=client.gather(L)
   pids=[]
   for m in mylist:
     x=m.split()[0]
     pids.append(x)
     print(m)
   pids=sorted(set(pids))
   print(len(pids),pids)

if __name__ == '__main__':
   main()

