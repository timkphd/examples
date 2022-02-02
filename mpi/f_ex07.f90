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
    use fmpi
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
    real z
    call init    
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
    write(*,"(a,i3.3,a,20i3)")"myid= ",myid," sc= ",sc
! send the data
    call MPI_alltoall(    sc,1,MPI_INTEGER, &
                        rc,1,MPI_INTEGER, &
                         MPI_COMM_WORLD,mpi_err)
    write(*,"(a,i3.3,a,20i3)")"myid= ",myid," rc= ",rc
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

    
