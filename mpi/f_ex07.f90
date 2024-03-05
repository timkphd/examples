      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
! This program shows how to use fmpi_Alltoall.  Each processor
! send/rec a different  random number to/from other processors.  

module global
    integer numnodes,myid,mpi_err
    integer, parameter :: my_root=0
end module
subroutine init
    use fmpi, only : MPI_COMM_WORLD
    use global
    implicit none
! do the mpi init stuff
    call MPI_INIT( mpi_err )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
    call MPI_Comm_rank(MPI_COMM_WORLD, myid, mpi_err)
end subroutine init

program test1
    use fmpi
    use global
    implicit none
    integer, allocatable :: sray(:),rray(:)
    integer, allocatable :: sdisp(:),sc(:),rdisp(:),rc(:)
    integer ssize,rsize,i,k,j
    character(len=128), dimension(:), allocatable :: args
    integer num_args,ix,nlength
    character (len=MPI_MAX_PROCESSOR_NAME+1):: myname
    integer slash,index

    real z
    call init    
    num_args = command_argument_count()
    if (num_args > 0)then
    allocate(args(0:num_args))
    call MPI_Get_processor_name(myname,nlength,mpi_err)
    call get_command_argument(0, args(0))
    slash=index(args(0),"/",back=.true.)+1
    do ix = 1, num_args
         call get_command_argument(ix,args(ix))
         write(*,"(i4,1x,a16,3x,a16,a32)")myid,trim(myname),trim(args(0)(slash:)),trim(args(ix))
     end do
    end if
! counts and displacement arrays
    allocate(sc(0:numnodes-1))
    allocate(rc(0:numnodes-1))
    allocate(sdisp(0:numnodes-1))
    allocate(rdisp(0:numnodes-1))
    call seed_random
    do i=0,100
       call random_number(z)
    enddo
! find  data to send
    do i=0,numnodes-1
        call random_number(z)
        sc(i)=nint(10.0*z)+1
    enddo
    write(*,"(a,i3.3,a,20(i3,1x))")"myid= ",myid," sc=",sc
! send the data
    call MPI_alltoall(    sc,1,MPI_INTEGER, &
                        rc,1,MPI_INTEGER, &
                         MPI_COMM_WORLD,mpi_err)
    write(*,"(a,i3.3,a,20(i3,1x))")"myid= ",myid," rc=",rc
    call mpi_finalize(mpi_err)
end program

              
subroutine seed_random
    use global
    implicit none
    integer the_size,j,p1
    integer, allocatable :: seed(:)
    real z
    p1=myid+99
    call random_seed(size=the_size) ! how big is the intrisic seed? 
    allocate(seed(the_size))        ! allocate space for seed 
    do j=1,the_size                 ! create the seed 
        seed(j)=abs(p1*10)+(j*p1*p1)+100  ! abs is generic 
    enddo 
    call random_seed(put=seed)      ! assign the seed 
    deallocate(seed)
end subroutine

    
