!****************************************************************
!  This is a simple send/receive program in MPI to which was
!  added a call to find the maxtag.
!  Processor 0 sends an integer to processor 1,
!  while processor 1 receives the integer from proc. 0
!****************************************************************

!*****
!  PMPI_Send(97).: Invalid tag, value is 1196597
!  In: PMI_Abort(537515524, Fatal error in PMPI_Send: Invalid tag, error
!  stack:
!  PMPI_Send(159): MPI_Send(buf=0x63ec7e0, count=60, MPI_INTEGER, dest=597,
!  tag=1196597, MPI_COMM_WORLD) failed
!  PMPI_Send(97).: Invalid tag, value is 1196597)
!*****
      program hello
      use mpi
!     include "mpif.h"
      integer myid, ierr,numprocs
      integer tag,source,destination,count
      integer buffer
      integer status(MPI_STATUS_SIZE)
      integer (selected_int_kind (18)) :: maxtag
      LOGICAL FLAG 
      LOGICAL :: getuniverse = .false.
      INTEGER (KIND=MPI_ADDRESS_KIND) VAL
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      ! is this call working correctly?
      val=-1
      if (getuniverse)then
		  call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_UNIVERSE_SIZE, val, flag, ierr)
		  ! val should be equal to numprocs and no error
		  if (ierr .ne. 0 .or. val .eq. 0 .and. myid .eq. 0)then
			write(*,*)"Somthing wrong with call to MPI_COMM_GET_ATTR with"
			write(*,*)"             MPI_UNIVERSE_SIZE"
			write(*,*)"It might need to be set outside of this program"
			write(*,*)"For example:"     
			write(*,*)"mpirun -usize 6 -n 4 ./maxtag_f"  
		  endif 
	  endif
      call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_TAG_UB, val, flag, ierr)
      if(myid == 0)write(*,'("maxtag ",i14," flag ",l4," ierr ",i4)')val, flag, ierr
      maxtag=VAL
      tag=14227094
!      tag=maxtag-1
      if(tag .gt. maxtag) then
        write(*,*)"warning maxtag is ",maxtag," tag is ",tag
      endif
      source=0
      destination=1
      count=1
      if(myid .eq. source)then
         buffer=5678
         Call MPI_Send(buffer, count, MPI_INTEGER,destination,&
          tag, MPI_COMM_WORLD, ierr)
         write(*,*)"processor ",myid," sent ",buffer
      endif
      if(myid .eq. destination)then
         Call MPI_Recv(buffer, count, MPI_INTEGER,source,&
          tag, MPI_COMM_WORLD, status,ierr)
         write(*,*)"processor ",myid,"  got ",buffer
      endif
      call MPI_FINALIZE(ierr)
      stop
      end
