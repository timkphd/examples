module global
  integer numnodes,myid,mpi_err
  integer, parameter :: my_root=0
end module
program ared
  use mpi
  use global
  integer sendbuf(0:3),recvbuf(0:3)
  integer powers(0:5)
  powers(0)=0;    powers(1)=10;    powers(2)=100;
  powers(3)=1000; powers(4)=10000; powers(5)=100000;
  
  call MPI_INIT( mpi_err )
  call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
  call MPI_Comm_rank(MPI_COMM_WORLD, myid, mpi_err)
  do i=0,3
    sendbuf(i)=i+powers(myid)
  enddo
  write(*,'("sendbuf for ",i2,5x,5i8)')myid,sendbuf
  
  call MPI_Allreduce(sendbuf, recvbuf, 4, MPI_INT, MPI_SUM,MPI_COMM_WORLD,mpi_err)
  write(*,'("recvbuf for ",i2,5x,5i8)')myid,recvbuf
  
  call MPI_Finalize(mpi_err);
end program

