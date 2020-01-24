!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank and total number of processors 
!  in the current MPI run. 
!****************************************************************
      program hello

      include "mpif.h"

      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )

      write (*,*) "Hello from task ",myid," of ",numprocs

      call MPI_FINALIZE(ierr)
      stop
      end



