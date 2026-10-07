
      function idosomething(i)
          idosomething=i+1
      end function
      
!****************************************************************
!  This is a simple isend/ireceive program in MPI
!****************************************************************
      program hello
      use mpi
!     include "mpif.h"
      integer myid, ierr,numprocs
      integer tag,source,destination,count
      integer, allocatable :: buffer(:)
      integer status(MPI_STATUS_SIZE),request
      logical flag
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      tag=1234
      source=0
      destination=1
      count=100000
      ic=0
      request=MPI_REQUEST_NULL
      allocate(buffer(count))
      if(myid .eq. source)then
         buffer=5678
         Call MPI_Isend(buffer, count, MPI_INTEGER,destination,&
          tag, MPI_COMM_WORLD,request, ierr)
      endif
      if(myid .eq. destination)then
         Call MPI_Irecv(buffer, count, MPI_INTEGER,source,&
          tag, MPI_COMM_WORLD, request,ierr)
      endif
      call MPI_Test (request, flag, status, ierr)
      do while (flag .eqv. .false.)
        ic=idosomething(ic)
        call MPI_Test (request, flag, status, ierr)
      enddo
      if(myid .eq. destination)then
         write(*,1)myid,"got",buffer(1),ic
      endif
      if(myid .eq. source)then
         write(*,1)myid,"sent",buffer(1),ic
      endif
 1    format("processor ",i2,a6,i6, " called idosomething ",i6," times")
      call MPI_FINALIZE(ierr)
      stop
      end




