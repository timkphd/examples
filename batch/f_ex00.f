!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its name, rank and  number of processors 
!  in the current MPI run. 
!*********************************************
      program hello
      include "mpif.h"
      integer myid,numprocs,ierr,nlength
      character (len=MPI_MAX_PROCESSOR_NAME):: myname
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(myname,nlength,ierr)
      write (*,*) "Hello from ",trim(myname)," # ",myid," of ",numprocs
      call MPI_FINALIZE(ierr)
      stop
      end
