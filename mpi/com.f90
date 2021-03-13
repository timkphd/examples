!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank and total number of processors 
!  in the current MPI run. 
!****************************************************************
      program hello

      include "mpif.h"
      logical aflag

      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_COMM_TEST_INTER(MPI_COMM_WORLD, aflag, ierr)

      write (*,'("Hello from task ",i4," of ",i4,l10)')myid,numprocs,aflag

      call MPI_FINALIZE(ierr)
      stop
      end



