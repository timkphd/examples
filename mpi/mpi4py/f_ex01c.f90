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
      integer tag,source,destination,count
      integer,allocatable :: buffer(:)
      integer status(MPI_STATUS_SIZE)
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      tag=1234
      source=0
      destination=1
      count=4
      allocate(buffer(count))
      do i =1,3
      if(myid .eq. source)then
!k+5678,k-5678
         do ic=1,count
          buffer(ic)=5678-1000*ic
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
 1    format("Fortran processor ",i3,a6,1x,8(i5))
      end



