! Our example will show you how to create a new communicator
! called SUB_COMM_WORLD. This communicator will include all
! the tasks except the last one.
! 
! First, we call MPI_Comm_group with the input communicator,
! MPI_COMM_WORLD. This gives us the associated group,
! old_group. Next, we create an array called will_use that
! contains all the task IDs except the last one. We then pass
! this array and old_group to MPI_Group_incl to create a new
! group called new_group. Finally, we pass new_group and
! MPI_COMM_WORLD to MPI_Comm_create to get a new communicator
! called SUB_COMM_WORLD.
! 
! Then we use the MPI_Group_rank routine to find the rank
! within the new communicator. For the last task, the rank is
! MPI_UNDEFINED because it’s not part of the communicator. The
! last task calls the get_input routine to read data from a
! file, an integer. This integer is then sent to task 0 using
! MPI_COMM_WORLD. If the value is greater than 100, the
! program stops.
! 
! The tasks in SUB_COMM_WORLD pass a token between themselves
! using the pass_token routine. The token starts at task 0.
! Task 0 receives the token from the last task using
! MPI_COMM_WORLD, as mentioned earlier. All other tasks only
! use SUB_COMM_WORLD.



! global variables
module global
	integer numnodes,myid,mpi_err,old_id,old_nodes,ierror
	integer, parameter :: my_root=0
	logical, parameter :: verbose=.false.
end module
subroutine init
    use mpi
    use global
    implicit none
! do the mpi init stuff
    call MPI_INIT( mpi_err )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, old_nodes, mpi_err )
    call MPI_Comm_rank(MPI_COMM_WORLD, old_id, mpi_err)
    write(*,"('hello from ',i4)")old_id
end subroutine init


program test1
! poe a.out -procs 3 -rmpool 1
	use mpi
	use global
	implicit none
	integer, allocatable :: will_use(:)
	integer SUB_COMM_WORLD
	integer ijk,new_group,old_group,num_used,used_id
	real z
	call init
! num_used is the # of processors that are part of the new communicator
! for this case hardwire to not include 1 processor
    num_used=old_nodes-1
    if(old_nodes .gt. num_used)then
! get our old group from MPI_COMM_WORLD
        call MPI_COMM_GROUP(MPI_COMM_WORLD,old_group,mpi_err)
! create a new group from the old group 
! that will contain a subset of the  processors
		allocate(will_use(0:num_used-1))
        do ijk=0,num_used-1
			will_use(ijk)=ijk
        enddo
        call MPI_GROUP_INCL(old_group,num_used,will_use,new_group    ,mpi_err)
! create the new communicator
        call MPI_COMM_CREATE(MPI_COMM_WORLD,new_group,SUB_COMM_WORLD, mpi_err)
! test to see if I am part of new_group.
        call MPI_GROUP_RANK(new_group,used_id, mpi_err)
        if(used_id .eq. MPI_UNDEFINED)then
! if not part of the new group do keyboard i/o.
			call get_input
			call MPI_Barrier(MPI_COMM_WORLD ,mpi_err)
			call MPI_FINALIZE(mpi_err)
 			stop
        endif
    else
       write(*,*)"need to set aside 1 task for input"
       call MPI_Abort(MPI_COMM_WORLD, ierror,mpi_err)
    endif
    call MPI_COMM_RANK( SUB_COMM_WORLD, myid, mpi_err )
    call MPI_COMM_SIZE( SUB_COMM_WORLD, numnodes, mpi_err )
    if(myid == 0)then
        write(*,"('MPI_COMM_WORLD task ',i4,' of ',i4)")old_id,old_nodes
        write(*,"('SUB_COMM_WORLD task ',i4,' of ',i4)")myid,numnodes
    endif
    
    call pass_token(SUB_COMM_WORLD)
    write(*,'("back from pass_token",i4)')old_id
    call MPI_Barrier(MPI_COMM_WORLD ,mpi_err)
    call MPI_FINALIZE(mpi_err)
    stop
end program   
    
    
subroutine pass_token(THE_COMM_WORLD)
	use mpi
	use global
	implicit none
	integer THE_COMM_WORLD
	integer my_tag,j,i,to,from,ierr,status(MPI_STATUS_SIZE)
	logical flag
    my_tag=1234
    j=0
    flag=.false.
    to=myid+1
    if(to .eq. numnodes)to=0
    from=myid-1
    if(from .lt. 0)from=numnodes-1
    i=0
	do while(i < 100)
		if(myid .eq. j)then
			call MPI_IPROBE(MPI_ANY_SOURCE,MPI_ANY_TAG, MPI_COMM_WORLD,flag,status,ierr)
	    	if(flag)then
	    		call MPI_RECV(i,1,MPI_INTEGER,MPI_ANY_SOURCE,MPI_ANY_TAG, &
	    		              MPI_COMM_WORLD,status,ierr)
	    	    write(*,'("got i  ",i3)')i
	    	endif
	    	if(verbose)write(*,"( i4,' sending ',i4,' to ',i4)")myid,i,to
	    	call MPI_SEND(i,1, MPI_INTEGER,to,my_tag,THE_COMM_WORLD,ierr)
	    	j=-1
	    else
	    	call MPI_RECV(i,1,MPI_INTEGER,from,my_tag,THE_COMM_WORLD,status,ierr)
	    	j=myid
	    endif
    enddo
    if(myid .lt. numnodes-1)then
    		if(verbose)write(*,"( i4,' sending ',i4,' to ',i4)")myid,i,to
			call MPI_SEND(i,1, MPI_INTEGER,to,my_tag,THE_COMM_WORLD,ierr)
	endif
end subroutine
    
subroutine get_input
   use mpi
   use global
   implicit none
   integer to,my_tag,i,ierr
   to=0
   my_tag=0
   i=0
   open(12,file="ex10.in")
   do while(i < 100)
   		write(*,*)"waiting for input:"
   		read(12,*)i
   		write(*,'("read i ",i3)')i
   		call MPI_SEND(i,1, MPI_INTEGER,to,my_tag,MPI_COMM_WORLD,ierr)
   		enddo
   return
end subroutine
