!Allocate space for globalIDarray
module stuff 
  integer myThreadID
!$OMP THREADPRIVATE(myThreadID)
end module

program aprog 
  use stuff
  integer,allocatable ::  globalIDarray(:)
  integer numThreads,myMPIRank
  integer,allocatable ::  localReduceBuf(:)
  integer omp_get_thread_num
  integer omp_get_num_threads
  integer dataSize,dmax
  integer ierr
  character(len=32) :: arg
  
#ifdef DOMPI
  include "mpif.h"
  call MPI_INIT( ierr )
  call MPI_COMM_RANK( MPI_COMM_WORLD, myMPIRank, ierr )
#endif
  dmax=8
  call get_command_argument(1,arg)
  if (len_trim(arg) .gt. 0)then
    read(arg,*)dmax
  endif
  
#ifdef DOMPI
  call MPI_Bcast(dmax,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
#else
  myMPIRank=0 
  call get_command_argument(2,arg)
  if (len_trim(arg) .gt. 0)then
    read(arg,*)myMPIRank
  endif
#endif
  dataSize=8
  do while(dataSize .le. dmax)
  if(myMPIRank == 0)write(*,*)"dataSize=",dataSize

  allocate(localReduceBuf(dataSize))

!$OMP PARALLEL DEFAULT(NONE), &
!$OMP SHARED(numThreads,globalIDarray,myMPIRank)
  numThreads = omp_get_num_threads()
  myThreadID = omp_get_thread_num() + 1
!$OMP SINGLE
  allocate(globalIDarray(numThreads))
!$OMP END SINGLE
    !Calculate the globalID for each thread
  globalIDarray(myThreadID) = (myMPIRank * numThreads) + myThreadID

!$OMP END PARALLEL
  write(*,*)"threads=",numThreads,"  rank=",myMPIRank

  write(*,*)"globalIDarray",globalIDarray

!initialise all reduce arrays to ensure correct results
  localReduceBuf = 0
!##########################################################################
! This is what is crashing in the full program for large values of dataSize,
! that is, the size of localReduceBuf.

!Open the parallel region and declare localReduceBuf
!as a reduction variable.
!$OMP PARALLEL DEFAULT(NONE), &
!$OMP PRIVATE(i),&
!$OMP SHARED(dataSize,globalIDarray),&
!$OMP REDUCTION(+:localReduceBuf)
  DO i = 1, dataSize
    localReduceBuf(i) = localReduceBuf(i) + globalIDarray(myThreadID)
  END DO
!$OMP END PARALLEL
!##########################################################################

  write(*,*)" #1 localReduceBuf",localReduceBuf(1:4)

! This produces the same results without allocating temporary arrays.  

  localReduceBuf = 0
  do j=1,numThreads
    DO i = 1, dataSize
      localReduceBuf(i) = localReduceBuf(i) + globalIDarray(j)
    enddo
  enddo
  write(*,*)" #2 localReduceBuf",localReduceBuf(1:4)

  localReduceBuf = 0
  if (.false.)then

! This works also but in a rather silly way.
!$OMP PARALLEL DEFAULT(NONE), &
!$OMP PRIVATE(i),&
!$OMP SHARED(dataSize,globalIDarray,localReduceBuf)
  DO i = 1, dataSize
!$omp critical
    localReduceBuf(i) = localReduceBuf(i) + globalIDarray(myThreadID)
!$omp end critical
  END DO
!$OMP END PARALLEL
!##########################################################################
  write(*,*)" #3 localReduceBuf",localReduceBuf(1:4)
  endif
  dataSize=DataSize*2
  deallocate(localReduceBuf)
  deallocate(globalIDarray)
  enddo
#ifdef DOMPI
  call MPI_FINALIZE(ierr)
#endif  


end program
