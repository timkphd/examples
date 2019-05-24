! This program is designed to show how to set up a new communicator
! and to do the a manager/worker paradigm
!
! We set up a communicator that includes all but one of the processors,
! The last processor is not part of the new communicator, WORKER_WORLD.
! We use the routine MPI_Group_rank to find the rank within the new
! communicator.  For the last processor the rank is MPI_UNDEFINED because
! it is not part of the communicator.  For this processor we call manager.
! The manager waits results from the workers and then sends more work for
! them to do.
!
! The processors in WORKER_WORLD are the workers.  They get an input
! from the manager and send back the result.   This continues until the
! manager gets back "TODO" results.  It then tells the workers to quit.
!
! Note that the workers communicate to the manager via MPI_COMM_WORLD.  
! They could communicate amongst themselves via WORKER_WORLD.  This
! would enable multiple workers to work in parallel.  You could also
! set up communicators that are subsets of WORKER_WORLD.
module mympi
        include "mpif.h"
end module

! global variables 
module globals

    integer numnodes,myid,mpi_err
    integer, parameter::mpi_root=0
end module
! end of global variables  


subroutine init_it()
    use globals
    use mympi
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, mpi_err )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
end subroutine

program themain
    use mympi
    use globals
	integer,allocatable :: will_use(:)
	integer WORKER_WORLD
	integer new_group,old_group
	integer  ijk,num_used,used_id
	integer  mannum
	call init_it()
	write(*,*)"hello from ",myid,"of",numnodes
	mannum=numnodes-1

! num_used is the # of processors that are part of the new communicator 
! for this case hardwire to not include 1 processor 
	num_used=numnodes-1
! get our old group from MPI_COMM_WORLD
        call MPI_COMM_GROUP(MPI_COMM_WORLD,old_group,mpi_err)
! create a new group from the old group 
! that will contain a subset of the  processors
		allocate(will_use(0:num_used-1))
        do ijk=0,num_used-1
			will_use(ijk)=ijk
        enddo
        call MPI_Group_incl(old_group,num_used,will_use,new_group    ,mpi_err)
! create the new communicator
        call MPI_COMM_CREATE(MPI_COMM_WORLD,new_group,WORKER_WORLD, mpi_err)
! test to see if I am part of new_group. 
! test to see if I am part of new_group.
        call MPI_GROUP_RANK(new_group,used_id, mpi_err)
        if(used_id .eq. MPI_UNDEFINED)then
! if not part of the new group do management. 
		call manager(num_used)
		write(*,*)"manager finished"
		call  MPI_BARRIER(MPI_COMM_WORLD,mpi_err)
		call  MPI_Finalize(mpi_err)
	else
! part of the new group do work. 
		call worker(WORKER_WORLD,mannum)
		write(*,*)"worker finished"
		call  MPI_BARRIER(MPI_COMM_WORLD,mpi_err)
		call  MPI_Finalize(mpi_err)
	endif
end program

subroutine worker( THE_COMM_WORLD, managerid)
	use mympi
	use globals
	real x
	integer status(MPI_STATUS_SIZE)
	x=0.0
	do while(x > -1.0)
! send message says I am ready for data 
		call MPI_SEND(x,1,MPI_REAL,managerid,1234,MPI_COMM_WORLD,mpi_err)
! get a message from the manager 
		call MPI_RECV(x,1,MPI_REAL,managerid,2345,MPI_COMM_WORLD,status,mpi_err)
! process data 
		x=x*2.0
		call sleep(myid+1)
	enddo
end subroutine

subroutine manager(num_used)
    use mympi
    use globals
	integer igot,isent,gotfrom,sendto,i
	integer, parameter::TODO=25
	real inputs(0:TODO-1)
	real x
	integer status(MPI_STATUS_SIZE)
	logical flag
	igot=0   
	isent=0
	do i=0,TODO-1
		inputs(i)=i+1
	enddo
	do while(igot < TODO)
! wait for a request for work 
		call MPI_IPROBE(MPI_ANY_SOURCE,MPI_ANY_TAG,MPI_COMM_WORLD,flag,status,mpi_err)
		if(flag)then
! where is it comming from 
			gotfrom=status(MPI_SOURCE)
			sendto=gotfrom
			call MPI_Recv(x,1,MPI_REAL,gotfrom,1234,MPI_COMM_WORLD,status,mpi_err)
			write(*,*)"worker ",gotfrom," sent ",x
			if(x > 0.0)igot=igot+1
			if(isent < TODO)then
! send real data 
				x=inputs(isent)
				call MPI_Send(x,1, MPI_REAL,sendto,2345,MPI_COMM_WORLD,mpi_err)
				isent=isent+1
			endif
		endif
	enddo 
! tell everyone to quit 
	do i=0,num_used-1
		x=-1000.0
		call MPI_Send(x,1, MPI_REAL,i,2345,MPI_COMM_WORLD,mpi_err)
	end do
end subroutine
