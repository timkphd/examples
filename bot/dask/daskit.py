#!/scratch/tkaiser2/conda/.conda-envs/oct19/bin/python
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
   if(len(sys.argv) > 1):
     tasks=int(sys.argv[1])
   else:
     tasks=8
   DOTHREADS=False
   if(len(sys.argv) > 2):
     DOTHREADS = (sys.argv[2] == "True")

# launch with either threads or processes
   print('Thread centric:',DOTHREADS)
   if DOTHREADS :
      print("lanching 1 workers %d threads_per_worker" % (tasks))
      cluster = LocalCluster(n_workers=1, threads_per_worker=tasks)
   else:
      print("lanching %d workers" % (tasks))
      #cluster = LocalCluster(n_workers=tasks)
      cluster = LocalCluster(n_workers=tasks,threads_per_worker=1)
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

