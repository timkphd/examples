subroutine init
    use numz
    use global
    use mympi
    use more_mpi
    implicit none
    character (len=8) c_date
    character (len=10)c_time
    call date_and_time(c_date,c_time)
    write(c_starttime,"(a4,a4,'.')")c_date(5:8),c_time(1:4)
! do the mpi init stuff
    call MPI_INIT( mpi_err )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
    call MPI_COMM_DUP( MPI_COMM_WORLD, TIMS_COMM_WORLD, mpi_err )
    call MPI_COMM_RANK( TIMS_COMM_WORLD, myid, mpi_err )
    call MPI_COMM_SIZE( TIMS_COMM_WORLD, numnodes, mpi_err )
    call MPI_BCAST(c_starttime,9,MPI_CHARACTER,0,TIMS_COMM_WORLD,mpi_err)
end subroutine init
