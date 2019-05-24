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
          integer, parameter :: in8 = selected_int_kind(12)

      end module
!
module getit
contains
function get_core_c()
    USE ISO_C_BINDING, ONLY: c_long, c_char,C_NULL_CHAR,c_int
    use numz
    integer(in8) :: get_core_c
    interface 
     !integer(c_long) function cfunc() BIND(C, NAME='pthread_self')
     integer(c_long)  function cfunc() BIND(C, NAME='sched_getcpu')
          USE ISO_C_BINDING, ONLY: c_long, c_char
        end function cfunc
    end interface
    get_core_c=cfunc( )
end function
end module

      program hello
      use mympi
      use getit
      implicit none
      character (len=MPI_MAX_PROCESSOR_NAME):: name
      integer tn,omp_get_thread_num
      integer myid,ierr,numprocs,nlen
      integer mycol,node_comm,new_id,new_nodes
      integer ib,ie
      integer narg,isum
      character (len=32) cmdlinearg
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(name,nlen,ierr)
! you can enter an integer on the command line.  Basically,
! the bigger the integer the longer the program runs in a
! tight loop.  Adding more threads should speed it up. Adding
! more mpi tasks will not.
      if (myid == 0)then
          isum=0
          narg=command_argument_count()
          write(*,*)narg
          if(narg > 0)then
            call get_command_argument(1,cmdlinearg)
            read(cmdlinearg,*)isum
          endif
      endif
      call MPI_BCAST(isum,1,MPI_INTEGER,0,mpi_comm_world,ierr)
      call node_color(mycol)
      call MPI_COMM_Split(mpi_comm_world,mycol,myid,node_comm,ierr)
      call MPI_COMM_Rank( node_comm, new_id, ierr )
      call MPI_COMM_Size( node_comm, new_nodes, ierr )
! get the portion of the name that just has the node (BGQ specific)
      ib=index(trim(name)," ",.true.); ie=len_trim(name); name=name(ib:ie)
      if(myid == 0)then
        write(*,1235)
 1235 format("task   thread            node name    color  newid  core_id")
      endif
      tn=-1
!$OMP PARALLEL
!$OMP CRITICAL
!$     tn=omp_get_thread_num()
      write(*,1234)myid,tn,trim(name),mycol,new_id,get_core_c()
 1234 Format(i4.4,"   ",i2.2,a26,"     ",i4.4,"   ",i4.4," ",i8.2)
!$OMP END CRITICAL
!$OMP END PARALLEL
!      write (*,*) "Numprocs is ",numprocs
      if(isum > 0)call sumit(isum,myid+1)
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
      use mympi
  implicit none
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
  
  subroutine sumit(nvals,val)
  use numz
  integer,allocatable :: block(:)
  integer val,ktimes
  integer(in8) sum
  real(b8)t1,t2,mpi_wtime
  allocate(block(nvals))
  ktimes=50
  t1=mpi_wtime()
!$OMP PARALLEL do
  do i=1,nvals
     block(i)=val
  enddo
  sum=0
  do ijk=1,ktimes
!$omp parallel do reduction(+:sum)
  do i=1,nvals
     sum=sum+block(i)
  enddo
  enddo
  t2=MPI_Wtime()
  write(*,'("sum of integers ",i15,f10.3)')sum/ktimes,t2-t1
  deallocate(block)
  end subroutine
  



