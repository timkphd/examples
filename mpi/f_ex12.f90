! Shows a short cut method to create a collection of communicators.
! All processors with the "same color" will be in the same communicator.
! In this case the color is either 0 or 1 for even or odd processors.
! Index gives rank in new communicator.
      program comm_split
      include "mpif.h"
      integer color,zero_one,split_comm
      call mpi_init( mpi_err )
      call mpi_comm_size( mpi_comm_world, numnodes, mpi_err )
      call mpi_comm_rank( mpi_comm_world, myid, mpi_err )
      color=mod(myid,2) !color is either 1 or 0
      call mpi_comm_split(mpi_comm_world,color,myid,split_comm,mpi_err)
      call mpi_comm_rank( split_comm, new_id, mpi_err )
      call mpi_comm_size( split_comm, new_nodes, mpi_err )
      zero_one = -1
      if(new_id==0)then
        zero_one = color
        	write(*,"('split_comm',i3,' has',i3, ' tasks')")color,new_nodes
      endif
      call MPI_Barrier(mpi_comm_world,mpi_err)
      call mpi_bcast(zero_one,1,mpi_integer,0, split_comm,mpi_err)
      if(zero_one==0)then
       write(*,'("old ",i3," is part of even processor communicator ",i3)')myid,new_id
      endif
      if(zero_one==1)then
       write(*,'("old ",i3," is part of  odd processor communicator ",i3)')myid,new_id
      endif
      call MPI_Barrier(mpi_comm_world,mpi_err)
      write(*,'("old_id=",i3," new_id=",i3," color=",i1)')myid,new_id,color
      call mpi_finalize(mpi_err)
      end program
      
