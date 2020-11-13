#!/usr/bin/env python3
from mpi4py import MPI
import h5py

comm=MPI.COMM_WORLD
rank=comm.Get_rank()
numprocs=comm.Get_size()
myname= MPI.Get_processor_name()
#print(rank,myname)

f = h5py.File('parallel_test.hdf5', 'w', driver='mpio', comm=MPI.COMM_WORLD)

#dset = f.create_dataset('test', (numprocs,), dtype='i')
#dset[rank] = rank


#we assume the name lengthe are the same across nodes
wlen=len(myname)

#write name as set of characters or as a string
dochar=False
dochar=True

if dochar :
    dset = f.create_dataset('test', (numprocs,wlen), dtype='c')
    for i in range(0,wlen):
        dset[rank,i] = myname[i]
else:
    mytype="S%2.2d" %(wlen+5)
    #if rank == 0:
    #    print("my data type is: ",mytype)
    dset=f.create_dataset('xxx', (numprocs,1),dtype=mytype)
    #output is name and rank
    astr="%s %4.4d" % (myname,rank)
    dset[rank]=astr.encode("ascii", "ignore")
    
f.close()

"""
  module load hdf5/1.12.0/intel-impi
  module load intel-mpi/2020.1.217
  export CC=mpiicc
  export HDF5_MPI="ON"
  export HDF5_DIR=/nopt/nrel/apps/hdf5/1.12.0-intel-impi
  git clone https://github.com/h5py/h5py.git
  cd h5py
  pip install .
"""
