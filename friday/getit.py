#!/usr/bin/env python
import numpy
import mpi
import sys
import time
sys.argv =  mpi.mpi_init(len(sys.argv),sys.argv)
myid=mpi.mpi_comm_rank(mpi.MPI_COMM_WORLD)
numprocs=mpi.mpi_comm_size(mpi.MPI_COMM_WORLD)
file="g20.pig"
##### read in the matrix in Harwell-Boeing format
if(myid ==0):
##### get the sizes
#	[nrow,ncol,nnz]=boeing.getheader(file)
	[nrow,ncol,nnz]=mpi.boeingheader(file)
	buffer2=numpy.array(([nrow,ncol,nnz]),"i")
else:
	buffer2=numpy.zeros(3,'i')
[nrow,ncol,nnz]=mpi.mpi_bcast(buffer2,3,mpi.MPI_INT,0,mpi.MPI_COMM_WORLD)
if(myid ==0):
##### allocate the space and read in the matix
	values=numpy.zeros(nnz,'d')
#	rowptr=numpy.zeros(nnz,'i')
#	colptr=numpy.zeros(nrow+1,'i')
#	boeing.hbcode1(file,nrow,values,rowptr,colptr,ncol=(len(colptr)-1),nnzero=len(values))
	rowptr=numpy.zeros(nnz,'i')
	colptr=numpy.zeros(nrow+1,'i')
	mpi.boeingdata(values,rowptr,colptr,file)
	print "rowptr= %5d %5d %5d %5d..." % (rowptr[0],rowptr[1],rowptr[2],rowptr[3])
	print "colptr= %5d %5d %5d %5d..." % (colptr[0],colptr[1],colptr[2],colptr[3])	
	print "values= %5.1f %5.1f %5.1f %5.1f..." % (values[0],values[1],values[2],values[3])
	b=numpy.ones(nrow,'d')
	print values
	print rowptr
	print colptr
	for i in range(0,nrow):
		b[i]=i
else:
##### the rest of the processor (!0) can use dummy arrays
	values=numpy.zeros(1,'d')
	rowptr=numpy.zeros(1,'i')
	colptr=numpy.zeros(2,'i')
	b=numpy.ones(1,'d')
nrhs=1
option=1
##### option=1 => do all of the parallel superlu set up 
#####             including allocating data structures.
#####             then do the solve, saving the data
#####             structures internally for future solves
t1b=time.time()
b=mpi.par_slu(values,rowptr,colptr,b,nrow,nnz,nrhs,option)
t1a=time.time()
if(myid == 0):
	print "\n\nsolution=", b[1:5],"\n\n"
if(myid ==0):
	b=numpy.ones(nrow,'d')
	for i in range(0,nrow):
		b[i]=i*2
option=2
##### option=2 => do a solve changing only the right hand
#####             side. reuse the previously factored matrix
t2b=time.time()
b=mpi.par_slu(values,rowptr,colptr,b,nrow,nnz,nrhs,option)
t2a=time.time()
if(myid == 0):
	print "\n\nsolution=", b[1:5],"\n\n"
mpi.mpi_barrier(mpi.MPI_COMM_WORLD)
##### option=3 => clean up the memory allocated by option=1.
#####             this should be done before calling with a
#####             new matrix
option=3
if(myid == 0):
	print "doing option 3"
t3b=time.time()
b=mpi.par_slu(values,rowptr,colptr,b,nrow,nnz,nrhs,option)
t3a=time.time()
print myid,"done with 3"
##### redo with a scaled "values"
option=1
values=values*0.5
if(myid ==0):
	b=numpy.ones(nrow,'d')
	for i in range(0,nrow):
		b[i]=i*0.5
else:
	b=numpy.ones(1,'d')
t4b=time.time()
b=mpi.par_slu(values,rowptr,colptr,b,nrow,nnz,nrhs,option)
t4a=time.time()
#print myid,"done with 1"
if(myid == 0):
	print "\n\nsolution=", b[1:5],"\n\n"
	print "times for %3d processors %10.5f %10.5f %10.5f %10.5f\n" % (numprocs,t1a-t1b,t2a-t2b,t3a-t3b,t4a-t4b)
mpi.mpi_finalize()
