!*************************************************************
!  Hello world but here we add a subroutine that can take 
!  command line arguments and optionally sleep for some number
!  of seconds and create a file.
!*************************************************************
      program hello
      include "mpif.h"
      character (len=MPI_MAX_PROCESSOR_NAME):: name
      character (len=8) :: datestr
      character (len=10) :: timestr
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(name,nlen,ierr)
      call date_and_time(datestr,timestr)
      write(*,10)myid, numprocs ,trim(name),datestr,timestr
10    format("Fort says Hello from",i4," of ",i4 " on ",a,a15,a15)
      call dostuff(myid)
      call MPI_FINALIZE(ierr)
      stop
      end
      
      subroutine dostuff(myid)
      include "mpif.h"
      character(len=20) :: aline
      character (len=8) :: datestr
      character (len=10) :: timestr
      integer len,stat,isleep
      if(myid .eq. 0)then
        call get_command_argument(1, aline, len, stat)
        if(stat .eq. 0)then
          read(aline,*)isleep
          call sleep(isleep)
        endif
        call get_command_argument(2, aline, len, stat)
        if(stat .eq. 0)then
          call date_and_time(datestr,timestr)
          open(file=trim(aline),unit=17)
          write(17,"(3a12)")"hello",datestr,timestr
          close(17)
        endif
      endif
      call MPI_Barrier(MPI_COMM_WORLD, ierr )
      end subroutine
