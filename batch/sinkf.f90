      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank and total number of processors 
!  in the current MPI run. 
!****************************************************************
      program hello
      use fmpi
      double precision the_time
      integer i_got,id_sink
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      write (*,*) "Hello from ",myid," of ",numprocs
!      
      call sinkfile(the_time,i_got,id_sink,"segment")
      write(*,'(" for proc ",i5," time= ",f10.2," for ",i10," bytes")') &
                             id_sink,     the_time,     i_got  
!
      call MPI_FINALIZE(ierr)
      stop
      end
