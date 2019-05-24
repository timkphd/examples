!****************************************************************
!  This is a hello world program in MPI and OpenMP. Each thread 
!  prints out its thread and MPI id.
!  
!  It also shows how to create a collection of node specific 
!  MPI communicators based on the name of the node on which a 
!  task is running.  Each node has it own "node_com" so each
!  thread also prints its MPI rank in the node specific
!  communicator.
!****************************************************************
     module mympi
        include "mpif.h"
     end module
      module numz
! define the basic real type and pi (not used in this example)
          integer, parameter:: b8 = selected_real_kind(14)
          real(b8), parameter :: pi = 3.141592653589793239_b8
      end module
!
      program hello
      use mympi
      implicit none
      character (len=MPI_MAX_PROCESSOR_NAME):: name
      integer tn,omp_get_thread_num
      integer myid,ierr,numprocs,nlen
      integer mycol,node_comm,new_id,new_nodes
      integer ib,ie
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(name,nlen,ierr)
      call node_color(mycol)
      call MPI_COMM_Split(mpi_comm_world,mycol,myid,node_comm,ierr)
      call MPI_COMM_Rank( node_comm, new_id, ierr )
      call MPI_COMM_Size( node_comm, new_nodes, ierr )
! get the portion of the name that just has the node (BGQ specific)
      ib=index(trim(name)," ",.true.); ie=len_trim(name);
name=name(ib:ie)
      if(myid == 0)then
        write(*,1235)
 1235 format("task   thread    node name    color  newid")
      endif
      tn=-1
!$OMP PARALLEL
!$OMP CRITICAL
!$     tn=omp_get_thread_num()
      write(*,1234)myid,tn,trim(name),mycol,new_id
 1234 Format(i4.4,"   ",i2.2,"     ",a," ",i4.4,"    ",i4.4)
!$OMP END CRITICAL
!$OMP END PARALLEL
!      write (*,*) "Numprocs is ",numprocs
      call MPI_FINALIZE(ierr)
      stop
      end
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

