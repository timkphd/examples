import numpy
from mpi4py import MPI

# Initialize MPI
comm=MPI.COMM_WORLD

# Get information about this run
numprocs=comm.Get_size()
myid=comm.Get_rank()
name = MPI.Get_processor_name()

#"name" fo MPI
lib=MPI.Get_library_version()

#standard version,subversion
standard=MPI.Get_version()

print(myid," of ",numprocs," on ",name," is running:")
print(lib.strip())
print("Supports MPI standard %d.%d" %(standard[0],standard[1]))

