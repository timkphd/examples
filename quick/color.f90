  subroutine node_color(mycol)
! return a integer which is unique to all mpi
! tasks running on a particular node.  It is
! equal to the id of the first MPI task running
! on a node.  This can be used to create 
! MPI communicators which only contain tasks on
! a node.
!      use mympi
  implicit none
  include "mpif.h"
  integer mycol
  integer status(MPI_STATUS_SIZE)
  integer xchng,i,n2,myid,numprocs
  integer ierr,nlen
  integer ib,ie
  character (len=MPI_MAX_PROCESSOR_NAME):: name
  character (len=MPI_MAX_PROCESSOR_NAME)::nlist
  call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
  call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
  call MPI_Get_processor_name(name,nlen,ierr)
! this next line is required on the BGQ
! the BGQ gives a different MPI name to each MPI task,
! encoding the task id and the location in the torus.
! we need to strip all of this off to just give us the
! node name
  ib=index(trim(name)," ",.true.); ie=len_trim(name); name=name(ib:ie)
  nlist=name
  mycol=myid
  ! find n2, the power of two >= numprocs
  n2=1
  do while (n2 < numprocs)
    n2=n2*2
  enddo
!    write(*,*)"myid=",myid
    do i=1,n2-1
        ! do xor to find the processor xchng
      xchng=xor(i,myid)
      if(xchng <= (numprocs-1))then
      ! do an exchange if our "current" partner exists
        if(myid < xchng)then
!          write(*,*)i,myid,"send from ",myid," to ", xchng
          call MPI_Send(name,MPI_MAX_PROCESSOR_NAME, &
                        MPI_CHARACTER, xchng, 12345, &
                        MPI_COMM_WORLD,ierr)
!          write(*,*)i,myid,"recv from ",xchng," to ",myid
          call MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME,&
                        MPI_CHARACTER,xchng,12345, &
                        MPI_COMM_WORLD, status,ierr)
        else
!          write(*,*)i,myid,"recv from ",xchng," to ",myid
          call MPI_Recv(nlist, MPI_MAX_PROCESSOR_NAME,&
                        MPI_CHARACTER,xchng,12345, &
                        MPI_COMM_WORLD, status,ierr)
!          write(*,*)i,myid,"send from ",myid," to ",xchng
          call MPI_Send(name,MPI_MAX_PROCESSOR_NAME, &
                        MPI_CHARACTER, xchng, 12345, &
                        MPI_COMM_WORLD,ierr)
        endif
        if(nlist == name .and. xchng < mycol)mycol=xchng
      else
      ! skip this stage
      endif
    enddo
!    write(*,*)
  end subroutine

