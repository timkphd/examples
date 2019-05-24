! This program shows how to create a collection of communicators
! so that each node has its own and all/only the tasks assigned to
! that node are in the communicator.
! We actually do this two times.  The first example we end up with
! an array of communicators, one per node.  This method uses 
! MPI_Comm_create.  The second method is simpler, using MPI_Comm_split.
! We use have a single communicator variable name but it has different
! values, that is collections of tasks, on each node.
      program hello
      implicit none
      include "mpif.h"
      integer cores_node,numnodes
      character (len=MPI_MAX_PROCESSOR_NAME):: myname
      character (len=MPI_MAX_PROCESSOR_NAME), allocatable :: nodes(:),procs(:)
      integer ierr,myid,numtasks,mylen,mynode
      integer newid1,newid2
      logical haveit,looking
      integer new_comm
      integer nc,i,j
      integer old_group
      integer gtotal
      integer, allocatable :: will_use(:)
      integer, allocatable :: new_worlds(:)
      integer, allocatable :: new_groups(:)
      integer, allocatable :: which_node(:)
! Start mpi, get "myid" for each task and the total number of tasks
      call MPI_Init( ierr )
      call MPI_Comm_rank( MPI_COMM_WORLD, myid, ierr )
      call MPI_Comm_size( MPI_COMM_WORLD, numtasks, ierr )
!
! Each task gets the name of the processor on which it runs
      call MPI_Get_processor_name(myname,mylen,ierr)
!      write(*,*)"Hello from ",myid," of ",numtasks," on ",trim(myname)
!
! There are 8 processing cores per node
      cores_node=8
! We can find the number of nodes in our job from the number of tasks
      numnodes=numtasks/cores_node
! We want a list of the nodes in our job.  We get this by collecting
! the node names for each task and removing duplicates and putting
! the end list in an array "nodes"
      allocate(procs(numtasks))
      allocate(nodes(numnodes))
! We do an allgather so each task has a complete mapping of tasks
! to processor names
      call MPI_Allgather(myname, MPI_MAX_PROCESSOR_NAME, MPI_CHARACTER, &
                         procs,  MPI_MAX_PROCESSOR_NAME, MPI_CHARACTER, &
                         MPI_COMM_WORLD,ierr)
! For every processor in our list we check to see if it is our short
! list and if not add it.
      nodes(1)=procs(1)
      nc=1
      do i=2,numtasks
        haveit=.false.
        do j=1,nc
            if(nodes(j) .eq. procs(i))haveit=.true.
        enddo
        if(haveit .eq. .false.)then
           nc=nc+1
           nodes(nc)=procs(i)
        endif
      enddo
! Now we have our short list on every task but we let just task 0 print it
      if(myid .eq. 0)then
        do i=1,numnodes
          write(*,*)"nodename:",trim(nodes(i))
        enddo  
      endif
! The barriers are only used to "hopefully" make the printing nicer
      call MPI_Barrier(MPI_COMM_WORLD,ierr)
! Each task actually needs a number for its node so we go thru the 
! list of nodenames to find "ours"  
      mynode=0
      looking=.true.
      do while (looking)
        mynode=mynode+1
        if(nodes(mynode) .eq. myname)looking=.false.
      enddo
! Print out our task, nodenumber and nodename
      write(*,*)"task ",myid," is on ",mynode,trim(nodes(mynode))
      call MPI_Barrier(MPI_COMM_WORLD,ierr)
! Gather to all tasks a list of which node holds which task
      allocate(which_node(numtasks))
      call MPI_Allgather(mynode,     1, MPI_INTEGER, &
                         which_node, 1, MPI_INTEGER, &
                         MPI_COMM_WORLD,ierr)
!
! We will create new communicators two ways.
!
! For the first method we have an array of communicators,
! one for each node and each task is in one of them
!
! Allocate space for the list of tasks that will be
! in each communicator, there will be cores_node of them
      allocate(will_use(cores_node))
! Allocate space for the new communicators and the groups
! associated with the communicators, noe for each node
      allocate(new_worlds(numnodes))
      allocate(new_groups(numnodes))
! We will need the group associated with MPI_COMM_WORLD
      call MPI_Comm_group(MPI_COMM_WORLD,old_group,ierr)
! For each node...
      do i=1,numnodes
! Create a list of tasks that will be in the node's communicator
        nc=0
! We go thru the list of tasks and if it is on the "current node", i
! we add it to our list "will_use"
        do j=1,numtasks
          if(i .eq. which_node(j))then
            nc=nc+1
            will_use(nc)=j-1
          endif
        enddo
! We have our list for node "i" print it from task 0
        if(myid .eq. 0)write(*,"('node ',i5,' will use ',8i4)")i,will_use
! Create a group from the list
        call MPI_Group_incl(old_group,nc,will_use,new_groups(i),ierr)
! Create the new communicator from the group
        call MPI_Comm_create(MPI_COMM_WORLD,new_groups(i),new_worlds(i), ierr)
      enddo
      call MPI_Barrier(MPI_COMM_WORLD,ierr)
! At this point we have an array of communicators, one for each node
! each task gets its new id in its new communicator
      call MPI_Comm_rank(new_worlds(mynode), newid1, ierr )
      write(*,*)"old id= ",myid,"  my node= ",mynode,"  new id= ",newid1
      call MPI_Barrier(MPI_COMM_WORLD,ierr)
!
! Now use the new communicator. just use reduce to get a sum of the
! old myids for each task
      call MPI_Reduce(  myid,  gtotal, 1,      &
                        MPI_INTEGER, MPI_SUM,   &
                        0,new_worlds(mynode),ierr)
! We let the root task for each new communicator print the sum
      if(newid1 .eq. 0)then
          write(*,*)"sum for node ",mynode," = ",gtotal
      endif
      call MPI_Barrier(MPI_COMM_WORLD,ierr)
!
! That was too hard. Our second method for creating a communicator
! uses comm_split.  Comm_split creates a collection of communicators
! they have the same name on all tasks, "new_comm" but each member of
! the set contains different original tasks.  Each task that calls
! comm_split with the same value for "mynode" will be in the same
! communicator and since every task on the same node has the same
! value for mynode they each end up in their own version of new_comm
      call MPI_Comm_split(MPI_COMM_WORLD,mynode,myid,new_comm,ierr)
      call MPI_Comm_rank( new_comm, newid2, ierr )
! Now use the new communicator. just use reduce to get a sum of the
! old myids for each task
      call MPI_Reduce(  myid,  gtotal, 1,      &
                        MPI_INTEGER, MPI_SUM,   &
                        0,new_worlds(mynode),ierr)
! We let the root task for each new communicator print the sum
      if(newid2 .eq. 0)then
          write(*,*)"sum for node ",mynode," using split = ",gtotal
      endif
      call MPI_Finalize(ierr)
      stop
      end
