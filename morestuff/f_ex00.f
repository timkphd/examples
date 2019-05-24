!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank and total number of processors 
!  in the current MPI run. 
!****************************************************************
      program hello
      include "mpif.h"
      character (len=MPI_MAX_PROCESSOR_NAME):: name
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(name,nlen,ierr)
      write(*,'("Fort says Hello from",i4," on ",a)')myid,trim(name)
!      write (*,*) "Numprocs is ",numprocs
      call MPI_FINALIZE(ierr)
      stop
      end



