#!/usr/bin/env python
import numpy
from numpy import *
import mpi
import sys
from time import sleep
from os import getcwd

sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)

t1=mpi.mpi_wtime()
tick=mpi.mpi_wtick()

#print the module version 

print "      MYMPI VERSION",mpi.VERSION,"\n"
#test attributes
print "MPI_WTIME_IS_GLOBAL",mpi.mpi_attr_get(mpi.MPI_COMM_WORLD,mpi.MPI_WTIME_IS_GLOBAL)
print "  MPI_UNIVERSE_SIZE",mpi.mpi_attr_get(mpi.MPI_COMM_WORLD,mpi.MPI_UNIVERSE_SIZE)
print "         MPI_TAG_UB",mpi.mpi_attr_get(mpi.MPI_COMM_WORLD,mpi.MPI_TAG_UB)
print "           MPI_HOST",mpi.mpi_attr_get(mpi.MPI_COMM_WORLD,mpi.MPI_HOST)
print "             MPI_IO",mpi.mpi_attr_get(mpi.MPI_COMM_WORLD,mpi.MPI_IO)

print "%s%1.1d%s%1.1d" % ("mpi version ",mpi.MPI_VERSION,".",mpi.MPI_SUBVERSION)
parent=mpi.mpi_comm_get_parent()
if (parent == mpi.MPI_COMM_NULL) :
	print mpi.mpi_get_processor_name(),"running head "
	
copies=3

##### start up remote tasks ####
toRun=getcwd()+"/worker.py"
print mpi.mpi_get_processor_name(),"starting",toRun
newcom1=mpi.mpi_comm_spawn(toRun,"from_P_",copies,mpi.MPI_INFO_NULL,0,mpi.MPI_COMM_WORLD)
errors=mpi.mpi_array_of_errcodes()
print "errors=",errors
newcom1Size=mpi.mpi_comm_size(newcom1)
print "newcom1Size",newcom1Size," yes it is strange but it should be 1"

##### bcast ####
x=array(([1,2,3,4]),"i")
count=4
print "head starting bcast",x
junk=mpi.mpi_bcast(x,count,mpi.MPI_INT,mpi.MPI_ROOT,newcom1)
print "head did bcast"

##### scatter ####
scat=array([10,20,30],"i")
junk=mpi.mpi_scatter(scat,1,mpi.MPI_INT,1,mpi.MPI_INT,mpi.MPI_ROOT,newcom1)

##### send/recv ####
for i in range(0,copies):
	k=(i+1)*100
	mpi.mpi_send(k,1,mpi.MPI_INT,i,1234,newcom1)
	back=mpi.mpi_recv(1,mpi.MPI_INT,i,5678,newcom1)
	print "from ",i,back

##### reduce ####
dummy=1000
final=mpi.mpi_reduce(dummy,1,mpi.MPI_INT,mpi.MPI_SUM,mpi.MPI_ROOT,newcom1)


sleep(5)

print "the final answer is=",final

toRun=getcwd()+"/worker"
print mpi.mpi_get_processor_name(),"starting",toRun
newcom2=mpi.mpi_comm_spawn(toRun,"from_C_",copies,mpi.MPI_INFO_NULL,0,mpi.MPI_COMM_WORLD)
errors=mpi.mpi_array_of_errcodes()
print "errors=",errors
newcom2Size=mpi.mpi_comm_size(newcom2)
print "newcom2Size",newcom2Size
sleep(15)

t2=mpi.mpi_wtime()
print "run time=",t2-t1,"with resolution=",tick

mpi.mpi_comm_free(newcom1)
mpi.mpi_comm_free(newcom2)
mpi.mpi_finalize()

