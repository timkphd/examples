module more_mpi
    use numz
    use mympi
    integer MY_MPI_VALUE
    integer,allocatable :: MPI_STATUS(:)
    integer myid,mpi_err,numnodes
    integer, parameter:: mpi_master = 0
    integer MPI_CALC_WORLD,MPI_GA_WORLD
end module

