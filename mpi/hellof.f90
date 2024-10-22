!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its name, rank and  number of processors 
!  in the current MPI run. 
!*********************************************
      program hello
      use iso_fortran_env
      include "mpif.h"
      integer myid,numprocs,ierr,nlength
      character(len=MPI_MAX_LIBRARY_VERSION_STRING+1) :: version
      character (len=MPI_MAX_PROCESSOR_NAME+1):: myname
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(myname,nlength,ierr)
      call MPI_Get_library_version(version, nlength, ierr)
      write (*,*) "Hello from ",trim(myname)," # ",myid," of ",numprocs
      if (myid .eq. 0)then
              write(*,*)trim(version)
              write(*,*)"compiler: ",compiler_version()
      endif
      call MPI_FINALIZE(ierr)
      stop
      end
