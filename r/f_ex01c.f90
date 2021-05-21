      module fmpi
        include "mpif.h"
      end module
!****************************************************************
!  This is a simple send/receive program in MPI
!  Processor 0 sends an integer to processor 1,
!  while processor 1 receives the integer from proc. 0
!****************************************************************
      program hello
      use fmpi
!     include "mpif.h"
      integer myid, ierr,numprocs
      integer tag,source,destination
      integer count,times
      integer,allocatable :: buffer(:)
      integer status(MPI_STATUS_SIZE)
      integer nargs,command_argument_count
      character(len=32)aarg
      character (len=MPI_MAX_PROCESSOR_NAME):: myname
      integer len
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(myname,nlength,ierr)
      write (*,2)trim(myname),myid,numprocs
 2    format("Fortran Hello from ",a6," # ",i2," of ",i2)       
      tag=1234
      source=0
      destination=1
! number of times we will exchange data
      times=3
! length of the vector to exchange
      count=4
! these can be on the command line
! srun -n 2 ./f_ex01c 3 4
! NOTE: there is no error checking for this
      if (myid .eq. 0)then
          nargs=command_argument_count()
          !write(*,*)"nargs=",nargs
          if(nargs .gt. 0)then
            call get_command_argument (1, aarg,len)
            !write(*,*)aarg(1:len)
            read(aarg(1:len),*)times
          endif
           if(nargs .gt. 1)then
            call get_command_argument (2, aarg,len)
            !write(*,*)aarg(1:len)
            read(aarg(1:len),*)count
          endif
      endif
      call mpi_bcast(times,1,mpi_integer,0, MPI_COMM_WORLD,ierr)
      call mpi_bcast(count,1,mpi_integer,0, MPI_COMM_WORLD,ierr)
      !write(*,*)count,times
      allocate(buffer(count))
      do i =1,times
      if(myid .eq. source)then
!k+5678,k-5678
         do ic=1,count
          buffer(ic)=5678-1000*ic+(i-1)
         enddo
         Call MPI_Send(buffer, count, MPI_INTEGER,destination,&
          tag, MPI_COMM_WORLD, ierr)
         write(*,1)myid,"sent",buffer
      endif
      if(myid .eq. destination)then
         Call MPI_Recv(buffer, count, MPI_INTEGER,source,&
          tag, MPI_COMM_WORLD, status,ierr)
         write(*,1)myid,"got",buffer
      endif
      enddo 
      call MPI_FINALIZE(ierr)
 1    format("Fortran processor ",i4,a6,1x,8(i8))
      end



