module my_collective

    interface myy_alltoallv
    module procedure imyall2allv
    module procedure rmyall2allv
    module procedure dmyall2allv
    end interface
    
    integer ncalls,nsend,nget
    double precision t1,t2,btime,ttime
    data ncalls,nsend,nget / 0,      0,     0 /
    data t1,t2,btime,ttime / 0.0d0 , 0.0d0, 0.0d0, 0.0d0 /
    private ncalls,nsend,nget,t1,t2,btime,ttime
    

contains

    subroutine dump_stat(base)
    implicit none
    character(len=*) , optional :: base
    character (len=80) temp
    integer myid, ierr
    include "mpif.h"
    call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
    if (present(base) )then
    	write(temp,"(a,i5.5)")trim(base),myid
    else
    	write(temp,"(a,i5.5)")trim("myall2allv"),myid
    endif
    open(58,file=temp,access="append")
    write(58,'(i5,i12,i12,4f10.5)')ncalls,nsend,nget,btime,ttime
    close(58)
    end subroutine


! myall2allv is a replacement for the MPI_ALLTOALLV
! i could not get the mpi version to work correctly
! myall2allv is based on the hypercube algorithm presented
! in class but it does not require a power of 2 processors
subroutine imyall2allv(sendbuf,sendcounts,sdispls,it1,&
                       recvbuf,recvcounts,rdispls,it2,&
                       comm,ierr)
  include "mpif.h"

  integer sendbuf(*),recvbuf(*)
  integer sendcounts(0:*),sdispls(0:*),recvcounts(0:*),rdispls(0:*)
  integer comm,ierr

  integer myid,numnodes,status(MPI_STATUS_SIZE)
  integer i,n2,xchng,my_tag

  call MPI_COMM_RANK( comm, myid, ierr )
  call MPI_COMM_SIZE( comm, numnodes, ierr )
  my_tag=49256
  if ( it1 .ne. MPI_INTEGER .or. it2 .ne. MPI_INTEGER)then
  	write(*,*)"type mismatch in myall2allv",it1,it2," not",MPI_INTEGER
  endif

  ncalls=ncalls+1
  nsend=nsend+sum(sendcounts(0:numnodes-1))
  nget=nget+sum(recvcounts(0:numnodes-1))
  t1=MPI_Wtime()

! find the power of two >= numnodes
  n2=nint(log((1.0d0*numnodes))/log(2.0d0))
  if(2**n2 < numnodes)n2=n2+1
  n2=2**n2
  n2=n2-1
  do i=1,n2
! do xor to find the processor xchng
      xchng=ieor(i,myid)
      if(xchng .le. (numnodes-1))then
          if(myid < xchng)then
          	if ( sendcounts(xchng) .gt. 0)then
              call MPI_SEND(sendbuf(sdispls(xchng)+1),sendcounts(xchng),&
                  MPI_INTEGER,xchng,my_tag,comm,ierr)
            endif
            if ( recvcounts(xchng) .gt. 0) then
              call MPI_RECV(recvbuf(rdispls(xchng)+1),recvcounts(xchng),&
                  MPI_INTEGER,xchng,my_tag,comm,status,ierr)
            endif
          else
            if ( recvcounts(xchng) .gt. 0) then
              call MPI_RECV(recvbuf(rdispls(xchng)+1),recvcounts(xchng),&
                  MPI_INTEGER,xchng,my_tag,comm,status,ierr)
            endif
            if ( sendcounts(xchng) .gt. 0) then
              call MPI_SEND(sendbuf(sdispls(xchng)+1),sendcounts(xchng),&
                  MPI_INTEGER,xchng,my_tag,comm,ierr)
            endif
          endif
      endif
  enddo
! exchange data with myself
  if( sendcounts(myid) .gt. 0)then
  do i=1,sendcounts(myid)
      recvbuf(rdispls(myid)+i)=sendbuf(sdispls(myid)+i)
  enddo
  endif
  
! gather stats part two
    t2=MPI_Wtime()
    ttime=ttime+(t2-t1)
    t1=t2
    call MPI_Barrier(comm,ierr)
    t2=MPI_Wtime()
    btime=btime+(t2-t1)
! gather stats part two
    
  return
end subroutine imyall2allv
subroutine rmyall2allv(sendbuf,sendcounts,sdispls,it1,&
                       recvbuf,recvcounts,rdispls,it2,&
                       comm,ierr)
  include "mpif.h"

  real sendbuf(*),recvbuf(*)
  integer sendcounts(0:*),sdispls(0:*),recvcounts(0:*),rdispls(0:*)
  integer comm,ierr

  integer myid,numnodes,status(MPI_STATUS_SIZE)
  integer i,n2,xchng,my_tag

  call MPI_COMM_RANK( comm, myid, ierr )
  call MPI_COMM_SIZE( comm, numnodes, ierr )
  my_tag=49258
  if ( it1 .ne. MPI_REAL .or. it2 .ne. MPI_REAL)then
  	write(*,*)"type mismatch in myall2allv",it1,it2," not",MPI_REAL
  endif
  
  ncalls=ncalls+1
  nsend=nsend+sum(sendcounts(0:numnodes-1))
  nget=nget+sum(recvcounts(0:numnodes-1))
  t1=MPI_Wtime()
  
! find the power of two >= numnodes
  n2=nint(log((1.0d0*numnodes))/log(2.0d0))
  if(2**n2 < numnodes)n2=n2+1
  n2=2**n2
  n2=n2-1
  do i=1,n2
! do xor to find the processor xchng
      xchng=ieor(i,myid)
      if(xchng .le. (numnodes-1))then
          if(myid < xchng)then
          	if ( sendcounts(xchng) .gt. 0)then
              call MPI_SEND(sendbuf(sdispls(xchng)+1),sendcounts(xchng),&
                  MPI_REAL,xchng,my_tag,comm,ierr)
            endif
            if ( recvcounts(xchng) .gt. 0) then
              call MPI_RECV(recvbuf(rdispls(xchng)+1),recvcounts(xchng),&
                  MPI_REAL,xchng,my_tag,comm,status,ierr)
            endif
          else
            if ( recvcounts(xchng) .gt. 0) then
              call MPI_RECV(recvbuf(rdispls(xchng)+1),recvcounts(xchng),&
                  MPI_REAL,xchng,my_tag,comm,status,ierr)
            endif
            if ( sendcounts(xchng) .gt. 0) then
              call MPI_SEND(sendbuf(sdispls(xchng)+1),sendcounts(xchng),&
                  MPI_REAL,xchng,my_tag,comm,ierr)
            endif
          endif
      endif
  enddo
! exchange data with myself
  if( sendcounts(myid) .gt. 0)then
  do i=1,sendcounts(myid)
      recvbuf(rdispls(myid)+i)=sendbuf(sdispls(myid)+i)
  enddo
  endif
  
! gather stats part two
    t2=MPI_Wtime()
    ttime=ttime+(t2-t1)
    t1=t2
    call MPI_Barrier(comm,ierr)
    t2=MPI_Wtime()
    btime=btime+(t2-t1)
! gather stats part two
    
  return
end subroutine rmyall2allv
subroutine dmyall2allv(sendbuf,sendcounts,sdispls,it1,&
                       recvbuf,recvcounts,rdispls,it2,&
                       comm,ierr)
  include "mpif.h"

  double precision sendbuf(*),recvbuf(*)
  integer sendcounts(0:*),sdispls(0:*),recvcounts(0:*),rdispls(0:*)
  integer comm,ierr

  integer myid,numnodes,status(MPI_STATUS_SIZE)
  integer i,n2,xchng,my_tag

  call MPI_COMM_RANK( comm, myid, ierr )
  call MPI_COMM_SIZE( comm, numnodes, ierr )
  my_tag=49257
  if ( it1 .ne. MPI_REAL8 .or. it2 .ne. MPI_REAL8)then
  	write(*,*)"type mismatch in myall2allv",it1,it2," not",MPI_REAL8
  endif
  
  ncalls=ncalls+1
  nsend=nsend+sum(sendcounts(0:numnodes-1))
  nget=nget+sum(recvcounts(0:numnodes-1))
  t1=MPI_Wtime()
  
! find the power of two >= numnodes
  n2=nint(log((1.0d0*numnodes))/log(2.0d0))
  if(2**n2 < numnodes)n2=n2+1
  n2=2**n2
  n2=n2-1
  do i=1,n2
! do xor to find the processor xchng
      xchng=ieor(i,myid)
      if(xchng .le. (numnodes-1))then
          if(myid < xchng)then
          	if ( sendcounts(xchng) .gt. 0)then
              call MPI_SEND(sendbuf(sdispls(xchng)+1),sendcounts(xchng),&
                  MPI_REAL8,xchng,my_tag,comm,ierr)
            endif
            if ( recvcounts(xchng) .gt. 0) then
              call MPI_RECV(recvbuf(rdispls(xchng)+1),recvcounts(xchng),&
                  MPI_REAL8,xchng,my_tag,comm,status,ierr)
            endif
          else
            if ( recvcounts(xchng) .gt. 0) then
              call MPI_RECV(recvbuf(rdispls(xchng)+1),recvcounts(xchng),&
                  MPI_REAL8,xchng,my_tag,comm,status,ierr)
            endif
            if ( sendcounts(xchng) .gt. 0) then
              call MPI_SEND(sendbuf(sdispls(xchng)+1),sendcounts(xchng),&
                  MPI_REAL8,xchng,my_tag,comm,ierr)
            endif
          endif
      endif
  enddo
! exchange data with myself
  if( sendcounts(myid) .gt. 0)then
  do i=1,sendcounts(myid)
      recvbuf(rdispls(myid)+i)=sendbuf(sdispls(myid)+i)
  enddo
  endif
   
! gather stats part two
    t2=MPI_Wtime()
    ttime=ttime+(t2-t1)
    t1=t2
    call MPI_Barrier(comm,ierr)
    t2=MPI_Wtime()
    btime=btime+(t2-t1)
! gather stats part two
    
  return
end subroutine dmyall2allv

end module

      module fmpi
      include "mpif.h"
      end module
! This program shows how to use fmpi_Alltoallv.  Each processor 
! send/rec a different and random amount of data to/from other
! processors.  
! We use fmpi_Alltoall to tell how much data is going to be sent.

module global
    integer numnodes,myid,mpi_err
    integer, parameter :: my_root=0
end module
subroutine init
    use fmpi
    use global
    implicit none
! do the mpi init stuff
    call MPI_INIT( mpi_err )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
    call MPI_Comm_rank(MPI_COMM_WORLD, myid, mpi_err)
end subroutine init

program test1
! poe a.out -procs 3 -rmpool 1
    use fmpi
    use global
    use my_collective
    implicit none
    real, allocatable :: sray(:),rray(:)
    integer, allocatable :: sdisp(:),scounts(:),rdisp(:),rcounts(:)
    integer ssize,rsize,i,k,j
    real z
    integer mytype
    call init   
! counts and displacement arrays
    allocate(scounts(0:numnodes-1))
    allocate(rcounts(0:numnodes-1))
    allocate(sdisp(0:numnodes-1))
    allocate(rdisp(0:numnodes-1))
! set counts to send to other processors
! seed the random number generator with a
! different number on each processor
    call seed_random
    do i=0,numnodes-1
        call random_number(z)
        scounts(i)=nint(10.0*z)+1
    enddo
! tell the other processors how much data is coming
    write(*,*)"myid= ",myid," scounts= ",scounts
    call MPI_alltoall(  scounts,1,MPI_INTEGER, &
                        rcounts,1,MPI_INTEGER, &
                        MPI_COMM_WORLD,mpi_err)
    write(*,*)"myid= ",myid," rcounts= ",rcounts
! calculate displacements and the size of the arrays
    sdisp(0)=0
    do i=1,numnodes-1
        sdisp(i)=scounts(i-1)+sdisp(i-1)
    enddo
    rdisp(0)=0
    do i=1,numnodes-1
        rdisp(i)=rcounts(i-1)+rdisp(i-1)
    enddo
    ssize=sum(scounts)
    rsize=sum(rcounts)
! allocate send and rec arrays
    allocate(sray(0:ssize-1))
    allocate(rray(0:rsize-1))
    sray=myid
! send/rec different amounts of data to/from each processor 
    mytype=MPI_REAL
    call MPI_alltoallv( sray,scounts,sdisp,mytype, &
                        rray,rcounts,rdisp,mytype, &
                        MPI_COMM_WORLD,mpi_err)
    write(*,*)"myid= ",myid,"    rray= ",rray
    call MYY_Alltoallv( sray,scounts,sdisp,mytype,  &
                        rray,rcounts,rdisp,mytype,  &
                        MPI_COMM_WORLD,mpi_err)
                    
    write(*,*)"myid= ",myid,"    rray= ",rray
    call dump_stat()
    call mpi_finalize(mpi_err)
end program

!typical output
! myid=  0  scounts=  1 5 2
! myid=  0  rcounts=  1 1 1
! myid=  0     rray=  0 1 2
  
! myid=  1  scounts=  1 7 3
! myid=  1  rcounts=  5 7 5
! myid=  1     rray=  0 0 0 0 0 1 1 1 1 1 1 1 2 2 2 2 2
  
! myid=  2  scounts=  1 5 10
! myid=  2  rcounts=  2 3 10
! myid=  2     rray=  0 0 1 1 1 2 2 2 2 2 2 2 2 2 2

              
subroutine seed_random
    use global
    implicit none
    integer the_size,j
    integer, allocatable :: seed(:)
    real z
    call random_seed(size=the_size) ! how big is the intrisic seed? 
    allocate(seed(the_size))        ! allocate space for seed 
    do j=1,the_size                 ! create the seed 
        seed(j)=abs(myid*10)+(j*myid*myid)+100  ! abs is generic 
    enddo 
    call random_seed(put=seed)      ! assign the seed 
    deallocate(seed)
end subroutine
