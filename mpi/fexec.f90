program fmpmd
  implicit none
  include "mpif.h"
  character (len=MPI_MAX_PROCESSOR_NAME+1):: myname
  integer mpi_err,np,myid,nlength
  character(len=128) exec,fstr
  call MPI_INIT( mpi_err )
  call MPI_COMM_SIZE( MPI_COMM_WORLD, np, mpi_err )
  call MPI_Comm_rank(MPI_COMM_WORLD, myid, mpi_err)
  call MPI_Get_processor_name(myname,nlength,mpi_err)
  call get_command_argument(0, exec)
  fstr="(i4,' of ',i4,' on ',a,' running ',a)"
  write(*,fstr)myid,np,trim(myname),trim(exec)
  call mpi_finalize(mpi_err)
end program
  
