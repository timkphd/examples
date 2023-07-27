! This is a simple hybrid hello world program.
! Prints MPI information
! For each task/thread
!  task id
!  node name for task
!  thread id
!  # of threads for the task
!  core on which the thread is running

module getit
contains
! Get the core on which a thread is running
  function get_core_c()
      USE ISO_C_BINDING, ONLY: c_long, c_char, C_NULL_CHAR, c_int
      use numz
      implicit none
      integer(in8) :: get_core_c
      interface
         integer(c_long) function cfunc() BIND(C, NAME='sched_getcpu')
            USE ISO_C_BINDING, ONLY: c_long, c_char
         end function cfunc
      end interface
      get_core_c = cfunc()
   end function
end module

program hybrid
    use getit
    implicit none
    include 'mpif.h'
    integer numtasks,myid,ierr
    character (len=MPI_MAX_PROCESSOR_NAME):: myname
    character(len=MPI_MAX_LIBRARY_VERSION_STRING+1) :: version
    integer mylen,vlan,mycore
    integer OMP_GET_MAX_THREADS,OMP_GET_THREAD_NUM
    call MPI_INIT( ierr )
    call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numtasks, ierr )
    call MPI_Get_processor_name(myname,mylen,ierr)
! print the MPI libraty version
if (myid .eq. 0)then
      write(*,*)" Fortran MPI TASKS ",numtasks
      call MPI_Get_library_version(version, vlan, ierr)
      write(*,*)trim(version)
    endif
!$OMP PARALLEL
!$OMP CRITICAL
    mycore=get_core_c()
    write(unit=*,fmt="(a,i4,a,a)",advance="no") &
                " task ",myid, " is running on ",trim(myname)
    write(unit=*,fmt="(a,i4,a,i4,a,i4)") &
            " thread= ",OMP_GET_THREAD_NUM(), &
            " of ",OMP_GET_MAX_THREADS(),     &
            " is on core ",mycore
!$OMP END CRITICAL
!$OMP END PARALLEL
    call MPI_FINALIZE(ierr)
end program
