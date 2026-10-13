
!Shows how to use mpi_Type_vector to send noncontiguous blocks of data
!and MPI_Get_count and MPI_Get_elements to see the number of elements sent
      program do_vect
      use mpi
!     include "mpif.h"
      integer , parameter :: size=30
      integer myid, ierr,numprocs
      real*8 svect(0:size),rvect(0:size)
      integer i,bonk1,bonk2,count,stride,blocklength
      integer MY_TYPE
      integer status(MPI_STATUS_SIZE)
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )    
      stride=5
      count=(size+1)/stride
      blocklength=1
      if(myid == 1)write(*,*)"count=",count," blocklength=",blocklength," stride=",stride
      call MPI_Type_vector(count,blocklength,stride,MPI_DOUBLE_PRECISION,MY_TYPE,ierr) 
      call MPI_Type_commit(MY_TYPE, ierr ) 
      if(myid == 0)then
        do i=0,size
          svect(i)=i
        enddo
        ! write(*,"('svect',25f4.0)")svect
        call MPI_Send(svect,1,MY_TYPE,1,100,MPI_COMM_WORLD,ierr) 
      endif
      if(myid == 1)then
        do i=0,size
          rvect(i)=-1
        enddo
        call MPI_Recv(rvect,1,MY_TYPE,0,100,MPI_COMM_WORLD,status,ierr) 
        ! write(*,"('rvect',25f4.0)")rvect
      endif
      if(myid == 1)then
        call MPI_Get_count(status,MY_TYPE,bonk1, ierr ) 
        call MPI_Get_elements(status,MPI_DOUBLE_PRECISION,bonk2,ierr) 
        write(*,*)"got ", bonk1," elements of type MY_TYPE"
        write(*,*)"which contained ", bonk2," elements of type MPI_DOUBLE_PRECISION"
        do i=0,size
          if(rvect(i) /= -1)write(*,'(i2,f4.0)')i,rvect(i)
        enddo
      endif
      call MPI_Finalize(ierr ) 
      end program














