program hybrid
    implicit none
    include 'mpif.h'
    integer numnodes,myid,my_root,ierr
    character (len=MPI_MAX_PROCESSOR_NAME):: myname
    integer mylen
    integer OMP_GET_MAX_THREADS,OMP_GET_THREAD_NUM
    call MPI_INIT( ierr )
    call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, ierr )
    call MPI_Get_processor_name(myname,mylen,ierr)
!$OMP PARALLEL
!$OMP CRITICAL
    write(unit=*,fmt="(i4,a,a)",advance="no")myid," running on ",trim(myname)
    write(unit=*,fmt="(a,i2,a,i2)")" thread= ",OMP_GET_THREAD_NUM()," of ",OMP_GET_MAX_THREADS()
!$OMP END CRITICAL
!$OMP END PARALLEL
    call MPI_FINALIZE(ierr)
end program
