
!****************************************************************
!  This is a simple isend/ireceive program in MPI
!****************************************************************
      program hello
      use mpi
      integer myid, ierr,numprocs
      integer tag,source,destination,count
      integer, allocatable :: buffer(:)
      integer status(MPI_STATUS_SIZE),request
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      tag=1234
      source=0
      destination=1
      count=100000
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
      call MPI_Wait(request,status,ierr)
      if(myid .eq. destination)then
         write(*,*)"processor ",myid," got ",buffer(1)
      endif
      if(myid .eq. source)then
         write(*,*)"processor ",myid," sent ",buffer(1)
      endif
      call MPI_FINALIZE(ierr)
      stop
      end




