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
      i=myid
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(myname,nlength,ierr)
      call MPI_Get_library_version(version, nlength, ierr)
      write (*,*) "Hello from ",trim(myname)," # ",myid," of ",numprocs
      if(numprocs .gt. 1)call pass(myid,numprocs)
      if (myid .eq. 0)then
              write(*,*)trim(version)
<<<<<<< HEAD
              write(*,*)"compiler: ",compiler_version()
=======
              write(*,*)
              write(*,*)"SUCCESS"
>>>>>>> 23ccfae (add comm test to hello)
      endif
      call MPI_FINALIZE(ierr)
      stop
      end
      subroutine pass(myid,numprocs)
              implicit none
              include "mpif.h"
              integer myid,numprocs
              integer status(MPI_STATUS_SIZE)
              integer my_tag,to,from,i,ierr
              my_tag=1234
              i=myid
              to=myid+1
              from=myid-1
              call mpi_bcast(i,1,mpi_integer,0, MPI_COMM_WORLD,ierr)
              if( i .ne. 0)write(*,*)"bcast failed",myid
              if (myid .eq. 0)then
                      from=numprocs-1
                      call mpi_send(i,1,MPI_INTEGER,to,my_tag,MPI_COMM_WORLD,ierr)
                      call MPI_RECV(i,1,MPI_INTEGER,from,my_tag,MPI_COMM_WORLD,status,ierr)
                      return
              endif
              if (myid .eq. numprocs-1)then
                      to=0
              endif
              call MPI_RECV(i,1,MPI_INTEGER,from,my_tag,MPI_COMM_WORLD,status,ierr)
              call mpi_send(i,1,MPI_INTEGER,to,my_tag,MPI_COMM_WORLD,ierr)
      end subroutine
