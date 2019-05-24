!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank and total number of processors 
!  in the current MPI run. 
!****************************************************************
      program hello
      include "mpif.h"
      character (len=MPI_MAX_PROCESSOR_NAME):: myname
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(myname,mylen,ierr)
      write(*,*)"Hello from ",myid," of ",numprocs," on ",trim(myname)
      call MPI_FINALIZE(ierr)
      stop
      end
      