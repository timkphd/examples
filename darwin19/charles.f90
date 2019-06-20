subroutine  chuck(result,doinit)
  use numz
  use problem
  use ran_mod
  use pick_mod
  use galapagos
  use sort_mod
  use my_collective
  use mympi
  use more_mpi
  use global , only : cycle_num,in_file
  use counts
    use tree_data
    use tree_junk
    use splayvars, only : root

!  use face, only : pname
  implicit none
  integer, parameter:: i8 = selected_int_kind(14)
  integer(i8)::malloc_count_peak,malloc_count_current,mp,mc,ml
  external malloc_count_peak,malloc_count_current
  interface mymod
     function mymod(i,j)
        integer i,j,mymod
     end function mymod
  end interface

  integer fnum
!***** some MPI related variables *****
  integer nrow,ncol,myrow,mycol
  integer myid_row, nodes_row, myid_col, nodes_col
  integer  myright , mytop , mybot , myleft , nx

! f90 version of MPI_2DOUBLE_PRECISION used with reduce - minloc
  type mpi_realb8_int
      sequence
      real(b8)value,proc_id
  end type 
  type (mpi_realb8_int) thetop,thetop2
! a row, col  communicator
  integer ROW_COMM,COL_COMM
  integer status(MPI_STATUS_SIZE)
!***** end of some MPI related variables *****

! variables for control when using mpi_master holds all of the population
  character(len=512)namestring(3)
  integer todo,next,next_fit,done,got_back
  logical ready

  real(b8) dummy,best_fit,g_best,g_best_last
  integer best_gen
  real(b8) lt1,lt2,lt3

  integer i,j,k,gen,m,n
  type instance
  sequence
  real(b8)invert_rate,mut_rate,quit_value
  integer pop_size,    generations
  integer gene_size,  seed
  integer shift_rate, shift_num
  integer global_rate,stagnate,hawk_rate
  integer hand_out
  logical do_one,the_top
  end type instance

  logical even
! varaibles used by the allto all communiation routines
  integer, allocatable :: sendcounts(:),recvcounts(:),sdispls(:),&
                          rdispls(:),sendgene(:),contrib(:),recvgene(:),&
                          sendcounts2(:),recvcounts2(:)

! the data structure used to pass startup info to slaves
  type(instance) charles
! MPI_CHARLES is the MPI data structure used to pass instance information
  integer b(3),t(3),MPI_CHARLES,MPI_SORT
  INTEGER(KIND=MPI_ADDRESS_KIND) d(3) 

  integer j_each,k_total,theid,tsend,ijk
  real(b8) ave_fit,fit_time,dt1,dt2,dt3,dt4,dt5,dt6,sort_time,tot_time
  integer sval(8),fval(8)
! we measure the time spent in the fitness function
! the gene sosrting and the total time
  real(b8), allocatable :: fit_time_array(:),tot_time_array(:),sort_time_array(:)

! used to print glob best on master
  integer best_loc(1)
  real(b8), allocatable :: best_fit_vect(:)
  integer , allocatable :: glob_best(:)
  logical, optional,intent (in) :: doinit
  integer, dimension(:):: result
  save
  ml=0
  rtime1=MPI_Wtime()
  cycle_num=0
  theid=0
  fit_time=0.0_b8
  sort_time=0.0_b8
  tot_time=0.0_b8
  dt5=0.0_b8
  dt6=0.0_b8
! start the timer for the total time
  call timer(dt3)
  if(.not. present(doinit))goto 12345
  if(.not. doinit)goto 12345
!  call MPI_INIT( mpi_err )
!  call MPI_COMM_RANK( TIMS_COMM_WORLD, myid, mpi_err )
!  call MPI_COMM_SIZE( TIMS_COMM_WORLD, numnodes, mpi_err )
! print the start time
  if(myid .eq. mpi_master)then
      call date_and_time(values=sval)
      write(out1,*)'program start time ',sval(5),':',sval(6),':',sval(7)
  endif
! find a reasonable grid topology based on the number
! of processors
  nrow=nint(sqrt(float(numnodes)))
  ncol=numnodes/nrow
  
  do while (nrow*ncol .ne. numnodes)
      nrow=nrow+1
      ncol=numnodes/nrow
  enddo
  if(myid .eq. mpi_master)write(out1,*)"nrow,ncol",nrow,ncol
! make the row and col communicators
! all processors with the same row will be in the same ROW_COMM
  myrow=myid/ncol+1
  mycol=myid - (myrow-1)*ncol + 1
   if(myid .eq. mpi_master)write(out1,*)"myrow,mycol",myrow,mycol  
  call MPI_COMM_SPLIT(TIMS_COMM_WORLD,myrow,mycol,ROW_COMM,mpi_err)
  call MPI_COMM_RANK( ROW_COMM, myid_row, mpi_err )
  call MPI_COMM_SIZE( ROW_COMM, nodes_row, mpi_err )
! all processors with the same col will be in the same COL_COMM
  call MPI_COMM_SPLIT(TIMS_COMM_WORLD,mycol,myrow,COL_COMM,mpi_err)
  call MPI_COMM_RANK( COL_COMM, myid_col, mpi_err )
  call MPI_COMM_SIZE( COL_COMM, nodes_col, mpi_err )
! find id of neighbors using the communicators created above
  mytop   = myid_col-1;if( mytop    .lt. 0         )mytop   = nodes_col-1
  mybot   = myid_col+1;if( mybot    .eq. nodes_col )mybot   = 0
  myleft  = myid_row-1;if( myleft   .lt. 0         )myleft  = nodes_row-1
  myright = myid_row+1;if( myright  .eq. nodes_row )myright = 0
  

! read in the problem specific data
    call description("fitfunc.dat",mpi_err)
  if(myid .eq. mpi_master)then
! next we read the genetic algorithm control variables
! default values
    do_one = .false.       ! if true mutate at most one "bit" of a gene
                           ! mut_rate is then the value a single mutation will occur
    the_top = .false.      ! if true reproduce using only top half of population
                           ! each with equal probability.  if false use roulette
                           ! reproduction
    mut_rate = 0.35_b8     ! mutation rate, if mutation rate < 0 then each
                           ! node has a different mut_rate and it must be read
    pop_size = 50          ! the total # of genes
    generations =200       ! how many generations will we run for
    gene_size = 100        ! how big are each of the genes
    seed = -12345          ! seed for the random number generator
    shift_rate = 20        ! how often do we send genes to our neighbors
    shift_num = 2          ! how many genes do we send to our neighbors
    global_rate = 2        ! how often do we find the global best population
    printing =0            ! if > 0 print out the start up data
    hawk_rate=0            ! how often do we allow processors to force part of their
                           ! population onto other processors
                           ! if hawk_rate > 0 then we read the "aggression factor",
                           ! hawk, for each processor.  the larger hawk is the more
                           ! likely a processor will force its genes onto other
                           ! processors
    hand_out=0             ! if hand_out > 0 then the mpi_master keeps all of the
                           ! genes and hands out requests to the workers for
                           ! fitness function evaluations shift_rate, shift_num,
                           ! hawk_rate are ignored
    stagnate=1000000
    invert_rate=0.0_b8
    maxtime=365*24*3600    ! run for a year

! end of default values
      open(in2,file=in_file,err=102)
      read(in2, nml=darwin_dat,err=102)
! if the mutation rate is below 0 the we have
! a rate which is dependent on the processor
      if(mut_rate < 0.0_b8 .and. hand_out < 1)then
          allocate(mute_rate_vect(numnodes))
          read(in2,*)mute_rate_vect
      endif
! if we allow "hawk" processorss then read
! in the "hawk" vaule for each processor
! the higher the value of hawk for a given 
! processor the more likely it will force
! its genes onto other processors
      if(hawk_rate > 0 .and. hand_out < 1)then
          allocate(hawk_rate_vect(numnodes))
          read(in2,*)hawk_rate_vect
      endif

! we collect the data up in the structure to send it to other nodes
      if(seed > 0) seed=-seed
      charles%invert_rate=invert_rate
      charles%mut_rate=mut_rate;       charles%quit_value=quit_value
      charles%pop_size=pop_size;       charles%generations=generations
      charles%stagnate=stagnate
      charles%gene_size=gene_size;     charles%seed=seed
      charles%shift_rate=shift_rate;   charles%shift_num=shift_num
      charles%global_rate=global_rate; charles%hawk_rate=hawk_rate
      charles%hand_out=hand_out;       charles%the_top=the_top
      charles%do_one=do_one
      close(in2)
  endif

! broadcast the fitness function data
! this routine is problem specific
  call broadcast(myid)

! define MPI_SORT to pass fit
  b(1)=1;b(2)=4
  d(1)=0;d(2)=8
  t(1)=MPI_DOUBLE_PRECISION;t(2)=MPI_INTEGER
  !call       MPI_TYPE_STRUCT(2,b,d,t,MPI_SORT,mpi_err)
  write(*,*)"first call"
  call MPI_Type_create_struct(2,b,d,t,MPI_SORT,mpi_err)
  call MPI_TYPE_COMMIT(MPI_SORT,mpi_err)
!  write(out1,*)"MPI_SORT=",MPI_SORT

! create a MPI data type used to pass startup data
  b(1)=3;b(2)=10;b(3)=2
  d(1)=0;d(2)=24;d(3)=64
  t(1)=MPI_DOUBLE_PRECISION;t(2)=MPI_INTEGER;t(3)=MPI_LOGICAL
  !call       MPI_TYPE_STRUCT(3,b,d,t,MPI_CHARLES,mpi_err)
   write(*,*)"second call"
 call MPI_Type_create_struct(3,b,d,t,MPI_CHARLES,mpi_err)
  call MPI_TYPE_COMMIT(MPI_CHARLES,mpi_err)
! broadcast the info to workers
   write(*,*)"third call"
 call MPI_BCAST(charles,1,MPI_CHARLES,mpi_master,TIMS_COMM_WORLD,mpi_err)
  invert_rate=charles%invert_rate
  mut_rate=charles%mut_rate;      quit_value=charles%quit_value
  pop_size=charles%pop_size;      generations=charles%generations
  stagnate=charles%stagnate
  gene_size=charles%gene_size;    seed=charles%seed
  shift_rate=charles%shift_rate;  shift_num=charles%shift_num
  global_rate=charles%global_rate;hawk_rate=charles%hawk_rate
  hand_out=charles%hand_out      ;the_top=charles%the_top
  do_one=charles%do_one
  call MPI_BCAST(maxtime,1,MPI_DOUBLE_PRECISION,mpi_master,TIMS_COMM_WORLD,mpi_err)
  write(*,*)"fourth call"

! seed is a function of processor number
  seed=seed-myid
!  write(out1,nml=darwin_dat)
! write(namestring,nml=darwin_dat)
!  call pname(namestring,2,out1)
  if(myid .eq. 0)then
      write(out1,nml=darwin_dat)
!      call pname(namestring,2,6)
  endif

  dummy=ran1(seed)
! send the processor specific hawk value and mutation rate
  if(hawk_rate > 0 .and. hand_out < 1)&
          call MPI_SCATTER(hawk_rate_vect,1,MPI_DOUBLE_PRECISION,&
             hawk,1,MPI_DOUBLE_PRECISION,&
             mpi_master,TIMS_COMM_WORLD,mpi_err)
  if(mut_rate < 0.0_b8 .and. hand_out < 1)&
          call MPI_SCATTER(mute_rate_vect,1,MPI_DOUBLE_PRECISION,&
             mut_rate,1,MPI_DOUBLE_PRECISION,&
             mpi_master,TIMS_COMM_WORLD,mpi_err)
    return
12345 continue
  call date_and_time(values=sval)
  call timer(dt3)

gene_size=ubound(result,1)
shift_num=nint((real(pop_size)/real(numnodes))*real(shift_num)/100.0)
write(out1,*)"new shift_num=",shift_num
!***********************************************************************
!***********************************************************************
!***********************************************************************
! does the mpi_master holds all of the genes if so do this


if(hand_out > 0)then
    best_fit=-huge(best_fit)
    if(myid .eq. mpi_master)then
        if(allocated( gene ))deallocate(gene)
        allocate(gene(gene_size,pop_size),kids(gene_size,pop_size))
        allocate(best(gene_size))
        allocate(fit(pop_size),fit2(pop_size))
        local_pop=pop_size
        do i=1,pop_size
            call init_gene(gene(:,i))
        enddo
        do gen=1,generations
!            write(*,*)gen,generations
            !call adjust(gen,best_fit)
            todo=pop_size
            next=1
            next_fit=1
            done=0
            do ijk=1,numnodes-1
                if(todo > 0)then
!                    write(out1,*)'sending ',min(hand_out,todo),' to ',ijk,' gene #',next
                    call MPI_SEND(gene(:,next),min(hand_out,todo)*gene_size,MPI_INTEGER,&
                                  ijk,next,TIMS_COMM_WORLD,mpi_err)
                    next=next+min(hand_out,todo)
                    todo=todo-hand_out
!                    write(out1,*)'at 228 todo =',todo
                endif
            enddo
! now wait for results and send additional requests as needed
            do while(done < pop_size)
                call MPI_IPROBE(MPI_ANY_SOURCE,MPI_ANY_TAG,TIMS_COMM_WORLD,&
                                ready,status,mpi_err)
! let the mpi_master do some work
                do while(ready  .EQV. .false.)
                    if(todo > 0)then
!                        write(out1,*)'doing local'
                        call timer(dt1)
                        fit(next_fit)%val=fitness(gene(:,next))
                        call timer (dt2)
                        fit_time=fit_time+(dt2-dt1)
                        fit(next_fit)%index=next
                        fit(next_fit)%proc=myid
                        theid=theid+1
                        next=next+1
                        next_fit=next_fit+1
                        todo=todo-1
                        done=done+1
!                        write(out1,*)'done = ',done
                    endif
                    call MPI_IPROBE(MPI_ANY_SOURCE,MPI_ANY_TAG,TIMS_COMM_WORLD,&
                                    ready,status,mpi_err)
                enddo
! get results
!                write(out1,*)'getting results at ',next_fit
                call MPI_RECV(got_back,1,MPI_INTEGER,MPI_ANY_SOURCE,&
                              63131,TIMS_COMM_WORLD,status,mpi_err)
                done=done+got_back
!                write(out1,*)'at 258 todo =',todo
!                write(out1,*)'done =',done
             
                if(todo > 0)then
                    ijk=status(MPI_SOURCE)
! send the request
!                    write(out1,*)'sending ',min(hand_out,todo),' to ',ijk,' gene #',next
                    call MPI_SEND(gene(:,next),min(hand_out,todo)*gene_size,MPI_INTEGER,&
                                  ijk,next,TIMS_COMM_WORLD,mpi_err)
                        next=next+min(hand_out,todo)
! subtrack the number requested from the todo number
                        todo=todo-hand_out
                endif
            enddo
! do the sort
! tell nodes to sort.  we use the tag number 8888 to signal a sort
!            write(out1,*)'telling nodes to sort'
            do ijk=1,numnodes-1
                call MPI_SEND(gene(1,1),1,MPI_INTEGER,ijk,8888,TIMS_COMM_WORLD,mpi_err)
            enddo
            next_fit=next_fit-1
            call timer(dt1)
            call sort(fit,next_fit)
! MY_MERGE is a parallel merge/sorting algorithm which takes a sorted
! list from each processor and returns to the mpi_master a sorted list
! it basically does a gather operation with a merge/sort along the way
! it is based on the algorithm for gather presented in class feb 9 
            ijk=pop_size
            call MY_MERGE(fit,next_fit,fit2,ijk,mpi_master,7890,TIMS_COMM_WORLD,MPI_SORT)
            call timer (dt2)
            sort_time=sort_time+(dt2-dt1)
            fit=fit2
! save the best
            if(fit(1)%val > best_fit)then
                best=gene(:,fit(1)%index)
                best_fit=fit(1)%val
            endif
            if(mymod(gen,global_rate) == 0)&
                write(out1,"('generataion ',i6,' best fit = ',g20.10)")gen,best_fit
            if(gen < generations)then
! top half reproduce
                call reproduce()    
! do mutation
                call mutate()
            endif
        enddo
! tell nodes to quit.  we use the tag number 9999 to signal a quit
!        write(out1,*)'telling nodes to quit'
        do ijk=1,numnodes-1
            call MPI_SEND(gene(1,1),1,MPI_INTEGER,ijk,9999,TIMS_COMM_WORLD,mpi_err)
        enddo
        call timer(dt4)
        tot_time=dt4-dt3
        allocate(contrib(0:numnodes-1),fit_time_array(0:numnodes-1))
        allocate(tot_time_array(0:numnodes-1),sort_time_array(0:numnodes-1))
        call MPI_GATHER(theid  ,  1   ,MPI_INTEGER,&
                        contrib,  1   ,MPI_INTEGER,&
                        mpi_master,TIMS_COMM_WORLD,mpi_err)
        call MPI_GATHER(fit_time      ,  1   ,MPI_DOUBLE_PRECISION,&
                        fit_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                        mpi_master,TIMS_COMM_WORLD,mpi_err)
        call MPI_GATHER(sort_time  ,  1   ,MPI_DOUBLE_PRECISION,&
                        sort_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                        mpi_master,TIMS_COMM_WORLD,mpi_err)
        call MPI_GATHER(tot_time      ,  1   ,MPI_DOUBLE_PRECISION,&
                        tot_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                        mpi_master,TIMS_COMM_WORLD,mpi_err)

! write out the best
        write(out1,*)'best_fit =',best_fit 
        write(out1,"(25i3)")best
! write out the time statistics         
        write(out1,*)'node  calculated   fitness    sort     total'
        write(out1,*)'         genes    cpu time  cpu time  cpu time'
        do i=0,numnodes-1
            write(out1,"(i4,i12,3f10.3)")&
                i,contrib(i),fit_time_array(i),sort_time_array(i),tot_time_array(i)
        enddo
        call date_and_time(values=fval)
        write(out1,*)'program start time ',sval(5),':',sval(6),':',sval(7)
        write(out1,*)'program stop time  ',fval(5),':',fval(6),':',fval(7)
        write(out1,*)'number of nodes  ',numnodes
        !call MPI_FINALIZE(mpi_err)
        result=best
if(allocated( best ))			deallocate(best)
if(allocated( best_fit_vect ))	deallocate(best_fit_vect)
if(allocated( contrib ))			deallocate(contrib)
if(allocated( fit ))				deallocate(fit)
if(allocated( fit2 ))			deallocate(fit2)
if(allocated( fit_time_array ))	deallocate(fit_time_array)
!!if(allocated( gene ))			deallocate(gene)
if(allocated( glob_best ))		deallocate(glob_best)
if(allocated( kids ))			deallocate(kids)
if(allocated( rdispls ))			deallocate(rdispls)
if(allocated( recvcounts ))		deallocate(recvcounts)
if(allocated( sdispls ))			deallocate(sdispls)
if(allocated( sendcounts ))		deallocate(sendcounts)
if(allocated( sort_time_array ))	deallocate(sort_time_array)
if(allocated( tot_time_array ))	deallocate(tot_time_array)
        return
    else
		if(allocated( gene ))deallocate(gene)
        allocate(gene(gene_size,hand_out))
        allocate(fit(pop_size))
        fit%proc=myid
        next_fit=1
        do
            call MPI_RECV(gene,hand_out*gene_size,MPI_INTEGER,mpi_master,&
            MPI_ANY_TAG,TIMS_COMM_WORLD,status,mpi_err)
            next=status(MPI_TAG)
! if the tag is 9999 the quit
            if(next .eq. 9999)then
               call timer(dt4)
               tot_time=dt4-dt3
!               write(out1,*)theid,fit_time,sort_time,tot_time
               call MPI_GATHER(theid  ,  1   ,MPI_INTEGER,&
                               contrib,  1   ,MPI_INTEGER,&
                               mpi_master,TIMS_COMM_WORLD,mpi_err)
               call MPI_GATHER(fit_time      ,  1   ,MPI_DOUBLE_PRECISION,&
                               fit_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                               mpi_master,TIMS_COMM_WORLD,mpi_err)
               call MPI_GATHER(sort_time  ,  1   ,MPI_DOUBLE_PRECISION,&
                               sort_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                               mpi_master,TIMS_COMM_WORLD,mpi_err)
               call MPI_GATHER(tot_time      ,  1   ,MPI_DOUBLE_PRECISION,&
                               tot_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                               mpi_master,TIMS_COMM_WORLD,mpi_err)
               !call MPI_FINALIZE(mpi_err)
if(allocated( best ))			deallocate(best)
if(allocated( best_fit_vect ))	deallocate(best_fit_vect)
if(allocated( contrib ))			deallocate(contrib)
if(allocated( fit ))				deallocate(fit)
if(allocated( fit2 ))			deallocate(fit2)
if(allocated( fit_time_array ))	deallocate(fit_time_array)
!if(allocated( gene ))			deallocate(gene)
if(allocated( glob_best ))		deallocate(glob_best)
if(allocated( kids ))			deallocate(kids)
if(allocated( rdispls ))			deallocate(rdispls)
if(allocated( recvcounts ))		deallocate(recvcounts)
if(allocated( sdispls ))			deallocate(sdispls)
if(allocated( sendcounts ))		deallocate(sendcounts)
if(allocated( sort_time_array ))	deallocate(sort_time_array)
if(allocated( tot_time_array ))	deallocate(tot_time_array)
               return
! if the tag is 8888 the sort
            elseif(next .eq. 8888)then
! we are doing a global parallel sort
                next_fit=next_fit-1
!                write(out1,*)'starting sort with ',next_fit
                call timer (dt2)
! first sort the local array
                call sort(fit,next_fit)
! do the global merge sort
                ijk=pop_size
                call MY_MERGE(fit,next_fit,fit2,ijk,mpi_master,7890,TIMS_COMM_WORLD,MPI_SORT)
                call timer (dt2)
                sort_time=sort_time+(dt2-dt1)
                next_fit=1
            else
                call MPI_GET_COUNT(status ,MPI_INTEGER, got_back,mpi_err)
                got_back=got_back/gene_size
!                write(out1,*)'doing ',got_back
                call timer(dt1)
                do ijk=1,got_back
!                    write(out1,*)'loading fit ',next_fit
                    fit(next_fit)%val=fitness(gene(:,ijk))
                    call timer (dt2)
                    fit(next_fit)%index=next
                    fit(next_fit)%proc=myid
                    next_fit=next_fit+1
                    next=next+1
                    theid=theid+1
                enddo
                fit_time=fit_time+(dt2-dt1)
!                write(out1,*)'sending back'
                call MPI_SEND(got_back,1,MPI_INTEGER,mpi_master,63131,TIMS_COMM_WORLD,mpi_err)
            endif
       enddo
    endif
endif
!***********************************************************************
!***********************************************************************
!*********************************************************************** 
! if the mpi_master does not keep all of the genes do this

! theid is used to keep track of how many genes a processor
! contributes to the global best
  theid=0
  if(generations.eq.0)then
      call init_gene(result)
      return
  endif
! how big is my part of the population
  local_pop=pop_size/numnodes
  if(local_pop*numnodes .ne. pop_size)then
      if(myid < pop_size-local_pop*numnodes)local_pop=local_pop+1
  endif
    
  best_fit=-huge(best_fit)

  allocate(best(gene_size))
! fit & fit2 are used to store fitness data for the population
  allocate(fit(local_pop))
  allocate(fit2(pop_size))


  if(allocated( gene ))deallocate(gene)
  allocate(gene(gene_size,local_pop),kids(gene_size,local_pop))
  allocate(sendcounts(0:numnodes-1))
  allocate(sdispls(0:numnodes-1))
  allocate(recvcounts(0:numnodes-1))
  allocate(rdispls(0:numnodes-1))
  allocate(best_fit_vect(numnodes))
  allocate(glob_best(gene_size))


! do initialization
!if(cycle_num .eq. -5)then
!	write(out1,*)'doing init =',local_pop,pop_size
	
!endif	

  do i=1,local_pop
     call init_gene(gene(:,i))
!     write(out1,'(65i1)')gene(:,i)
  enddo
! start the evolution
    best_gen=generations
    g_best_last=-1.0_b8
        write(out1,*)"local population size = ", local_pop
        ave_fit=-1234
  lt1=MPI_Wtime()
  lt2=lt1
  lt3=lt1
  do gen=1,generations-1
    mygen=gen
    lt2=MPI_Wtime()
    !mp=malloc_count_peak()
    !mc=malloc_count_current()
    if(myid .eq. 0)write(out1,"('x',2i6,3f12.4,2i8,3i16)") &
        gen,generations,ave_fit/local_pop,lt2-lt1,lt2-lt3, &
        reused,newone !, &
!        mp,mc,mc-ml
    lt3=lt2
    flush(out1)
!    mpi_err=fsync(fnum(out1))
!    call adjust(gen,best_fit) !;write(out1,*)"gen=",gen
! find the fitness of each member of the population
    g_best=-huge(g_best)
    ave_fit=0.0_b8
    call timer(dt1)
    do i=1,local_pop
       fit(i)%val=fitness(gene(:,i))  ! the fitness for a gene
                                      ! when we do a global exchange we use
                                      ! index, to, and proc
       fit(i)%index=i                 ! what offset is in within the array
       fit(i)%to=-1                   ! send to which processor              
       fit(i)%proc=myid               ! what processor is it coming from
       ave_fit=fit(i)%val+ave_fit
    enddo
    call timer (dt2)
    fit_time=fit_time+(dt2-dt1)
! sort the population
    call timer (dt5)
    call sort(fit,local_pop)
    call timer (dt6)
    sort_time=sort_time+(dt6-dt5)

! save the best
    if(fit(1)%val > best_fit)then
      best=gene(:,fit(1)%index)
      best_fit=fit(1)%val
    endif
    write(out1,*)"for ",gen," best_fit=",best_fit

!************************ start of exchange between nodes of best half
    if(mymod(gen,global_rate) == 0)then    ! find the global best half
!    write(out1,"('gen=',i4,' on pid= ',i4      ,f10.6)") &
!                                 gen,  myid,          best_fit
        call timer(dt5)
        call MY_MERGE(fit,local_pop,fit2,i,mpi_master,789,TIMS_COMM_WORLD,MPI_SORT)
        call timer(dt6)
        sort_time=sort_time+(dt6-dt5)
     
! find how many genes we need to send
! k_total is the total number which will be sent
! j_each processor is the number each will get
! note that it is possible for a processor to get
! a number greater than half of its population
          k_total=pop_size/2
          j_each=mod(k_total,numnodes)
          if(j_each .ne. 0)then
              j_each=k_total/numnodes+ 1
              k_total=j_each*numnodes
          else
              j_each=k_total/numnodes
          endif
         call MPI_ALLGATHER(best_fit     ,1,MPI_DOUBLE_PRECISION, &
                            best_fit_vect,1,MPI_DOUBLE_PRECISION, &
                            TIMS_COMM_WORLD,mpi_err)
         best_loc=maxloc(best_fit_vect)-1
         g_best=maxval(best_fit_vect)
!         if(best_loc(1) .ne. mpi_master)then
!             if(best_loc(1) .eq. myid)then
!                 call MPI_SEND(best,    gene_size,MPI_INTEGER,mpi_master  ,5329,&
!                               TIMS_COMM_WORLD,mpi_err)
!             endif
!             if(myid .eq. mpi_master)then
!                 call MPI_RECV(glob_best,gene_size,MPI_INTEGER,best_loc(1),5329,&
!                               TIMS_COMM_WORLD,status,mpi_err)
!             endif
!         else
!             glob_best=best
!         endif
         if(best_loc(1) .eq. myid)glob_best=best
         call MPI_BCAST(glob_best,gene_size,MPI_INTEGER,best_loc,TIMS_COMM_WORLD,mpi_err)
         if(g_best .gt. g_best_last)then
         	g_best_last=g_best
         	best_gen=gen
         endif
          if(myid .eq. mpi_master)then
! put the destination for a gene in fit2%to
! the source for a gene is in fit2%proc at offset fit2%index
              dummy=pick_to(numnodes,j_each)
              do j=1,k_total
                  fit2(j)%to=pick_to()
              enddo

          endif !end of the mpi_masters work for sorting
! bcast the data structure which holds the information about which
! genes go to which processor
          call MPI_BCAST(fit2,k_total,MPI_SORT,mpi_master,TIMS_COMM_WORLD,mpi_err)
          sendcounts=0
          recvcounts=0
! count the number which will be sent/recieved form each processor
         do i=1,k_total
                if(fit2(i)%proc  .eq. myid)&
                    sendcounts(fit2(i)%to)=sendcounts(fit2(i)%to)+1
                if(fit2(i)%to .eq. myid)&
                    recvcounts(fit2(i)%proc) =recvcounts(fit2(i)%proc) +1
          enddo
! vector for the genes we will be receiving
          allocate(recvgene(gene_size*sum(recvcounts)))
! how many are we sending in total
          tsend=sum(sendcounts)
!          write(out1,*)"sendcounts = ",sendcounts
!call flush(out1)
          theid=theid+tsend
! allocate space for the genes we are sending
! we will copy them into this vector.  i can not send them directly
! from the matrix gene because they are in the wrong order
! i could rearrange the ordering in place.  this would save space but
! not time.  
! reorder the genes so we can send them out
          allocate(sendgene(gene_size*tsend))
! adjust the vectors because we are sending genes of length gene_size
! sendcounts,sdispls,recvcounts,rdispls are used in the routine myall2allv
! myall2allv is my version of MPI_alltoallv.  I could not get MPI_alltoallv
! to work.  it deadlocked.  my version takes most of the same variables
! which the MPI version uses.  myall2allv is based on the hypercube algorithm
! presented in class but it does not require a power of 2 processors
          sendcounts=sendcounts*gene_size
          recvcounts=recvcounts*gene_size
          sdispls(0)=0
          rdispls(0)=0
          do i=1,numnodes-1
              sdispls(i)=sdispls(i-1)+sendcounts(i-1)
              rdispls(i)=rdispls(i-1)+recvcounts(i-1)
          enddo
! collect the genes we are sending
          m=0
          do i=0,numnodes-1
              do k=1, k_total
                if((fit2(k)%to .eq. i) .and. (fit2(k)%proc .eq. myid))then
                    do ijk=1,gene_size
                        m=m+1
                        sendgene(m)=gene(ijk,fit2(k)%index)
                    enddo
                endif
              enddo
          enddo
! send/recv genes from all processors
          call MPI_alltoallv(sendgene,sendcounts,sdispls,&
                          MPI_INTEGER,&
                          recvgene,recvcounts,rdispls,&
                          MPI_INTEGER,&
                          TIMS_COMM_WORLD,mpi_err)

! copy the genes we have recieved into the correct location
          m=0
          do i=1,sum(recvcounts)/gene_size
              do ijk=1,gene_size
                  m=m+1
                  gene(ijk,i)=recvgene(m)
              enddo
          enddo
          deallocate(sendgene,recvgene)
! duplicate the genes we have received 
          k=0
          do i=j_each+1,local_pop
              k=k+1
              gene(:,i)=gene(:,k)
          enddo
          do i=1,local_pop
             if(the_top)then
! and give them random fitness because we want them all to have 
! equal probability of reproducing
                 fit(i)%val=ran1()
              else
! changed to equal fitness because we are now using roulette wheel selection 
                  fit(i)%val=1.0_b8
              endif
          enddo
          call sort(fit,local_pop)
		
   	endif
!************************ end of exchange between nodes of best half
! top half reproduce
if(cycle_num .eq. -5)then
	write(out1,*)'doing reproduce for gen =',gen,the_top
	
endif	
    call reproduce()
    
! do mutation
if(cycle_num .eq. -5)then
	write(out1,*)'doing mutate for gen =',gen,do_one,mut_rate
	
endif
    call invert()	
    call mutate()
if(cycle_num .eq. -5)then
	write(out1,*)'did mutate for gen =',gen
	
endif	


    if(mymod(gen,shift_rate) == 0)then      ! migrate genes to neighboors
!write(out1,*)'pick ',shift_num,' genes to send in each direction'
        nx=shift_num*gene_size
        allocate(sendgene(nx*2))
        allocate(recvgene(nx*2))
        if(ncol .ne. 1)then
            m=0
            do i=1,shift_num*2
                ijk=nint((local_pop-1)*ran1())+1
                do k=1,gene_size
                    m=m+1
                    sendgene(m)=gene(k,ijk)
                enddo
            enddo
            if(even(mycol))then
! send to left
                call MPI_SEND(sendgene,nx,MPI_INTEGER,myleft,100,ROW_COMM,mpi_err)
! rec from left
                call MPI_RECV(recvgene,nx,MPI_INTEGER,myleft,100,ROW_COMM,status,mpi_err)
! rec from right
                call MPI_RECV(recvgene(nx+1),nx,MPI_INTEGER,myright,100,ROW_COMM,status,mpi_err)
! send to right
                call MPI_SEND(sendgene(nx+1),nx,MPI_INTEGER,myright,100,ROW_COMM,mpi_err)
            else    ! we are on an odd col processor
! rec from right
                call MPI_RECV(recvgene,nx,MPI_INTEGER,myright,100,ROW_COMM,status,mpi_err)
! send to right
                call MPI_SEND(sendgene,nx,MPI_INTEGER,myright,100,ROW_COMM,mpi_err)
! send to left
                call MPI_SEND(sendgene(nx+1),nx,MPI_INTEGER,myleft,100, ROW_COMM,mpi_err)
! rec from left
                call MPI_RECV(recvgene(nx+1),nx,MPI_INTEGER,myleft,100, ROW_COMM,status,mpi_err)
            endif
! put the new genes in a random location
            m=0
            do i=1,shift_num*2
                ijk=nint((local_pop-1)*ran1())+1
                do k=1,gene_size
                    m=m+1
                    gene(k,ijk)=recvgene(m)
                enddo
            enddo
        endif
8888 continue
       if(nrow .ne. 1)then
            m=0
            do i=1,shift_num*2
                ijk=nint((local_pop-1)*ran1())+1
                do k=1,gene_size
                    m=m+1
                    sendgene(m)=gene(k,ijk)
                enddo
            enddo

! again the send ordering is dependent on the odd/even row #
! for a particular processor
            if(even(myrow))then  
! send to top
                call MPI_SEND(sendgene,nx,MPI_INTEGER,mytop,10, COL_COMM,mpi_err)  
! rec from top
                call MPI_RECV(recvgene,nx,MPI_INTEGER,mytop,10,COL_COMM,status,mpi_err)  
! rec from bot
                call MPI_RECV(recvgene(nx+1),nx,MPI_INTEGER,mybot,10,COL_COMM,status,mpi_err)
! send to bot
                call MPI_SEND(sendgene(nx+1),nx,MPI_INTEGER,mybot,10, COL_COMM,mpi_err)
            else
! rec from bot
                call MPI_RECV(recvgene,nx,MPI_INTEGER,mybot,10,COL_COMM,status,mpi_err)
! send to bot
                call MPI_SEND(sendgene,nx,MPI_INTEGER,mybot,10,COL_COMM,mpi_err)
! send to top
                call MPI_SEND(sendgene(nx+1),nx,MPI_INTEGER,mytop,10,COL_COMM,mpi_err)
! rec from top
                call MPI_RECV(recvgene(nx+1),nx,MPI_INTEGER,mytop,10,COL_COMM,status,mpi_err)
            endif
! put the new genes in a random location
            m=0
            do i=1,shift_num*2
                ijk=nint((local_pop-1)*ran1())+1
                do k=1,gene_size
                    m=m+1
                    gene(k,ijk)=recvgene(m)
                enddo
            enddo
        endif
 9999        deallocate(sendgene,recvgene)
   endif

! do takeover exchanges   
  if(mymod(gen,hawk_rate) == 0)then
! decide how many genes to send. we will send up to the size of our population
      n=min(local_pop,nint(ran1()*hawk))
!      write(out1,*)'sending ',n
      sendcounts=0
      allocate(sendgene(n*gene_size))
      if(n > 0)then
! where are they going to
          do i=1,n
              j=nint(ran1()*(numnodes-1))
              sendcounts(j)=sendcounts(j)+1
          enddo
      endif
! use myall2allv to pass out the numbers
      allocate(sendcounts2(numnodes),recvcounts2(numnodes))
      sendcounts2=1
      recvcounts2=1
      sdispls(0)=0
      rdispls(0)=0
      do i=1,numnodes-1
         sdispls(i)=sdispls(i-1)+1
         rdispls(i)=rdispls(i-1)+1
      enddo
!      write(out1,*)'sendcounts ',sendcounts
! tell each processor how many to expect and find out how 
! many we will be getting from each processor
!      call myall2allv(sendcounts,sendcounts2,sdispls,&
!                      recvcounts,recvcounts2,rdispls,&
!                      TIMS_COMM_WORLD,mpi_err)
      call MPI_alltoallv(sendcounts,sendcounts2,sdispls,&
                      MPI_INTEGER, &
                      recvcounts,recvcounts2,rdispls,&
                      MPI_INTEGER, &
                      TIMS_COMM_WORLD,mpi_err)
!      write(out1,*)'recvcounts ',recvcounts
! load the genes into sendgene
      m=0
      do i=1,n
          ijk=nint((local_pop-1)*ran1())+1
          do k=1,gene_size
              m=m+1
              sendgene(m)=gene(k,ijk)
          enddo
      enddo              
! alocate space for the recvgenes
     tsend=sum(recvcounts)
     allocate(recvgene(tsend*gene_size))
! use myall2allv to pass out the genes
      sendcounts=sendcounts*gene_size
      recvcounts=recvcounts*gene_size
      sdispls(0)=0
      rdispls(0)=0
      do i=1,numnodes-1
          sdispls(i)=sdispls(i-1)+sendcounts(i-1)
          rdispls(i)=rdispls(i-1)+recvcounts(i-1)
      enddo
!      call myall2allv(sendgene,sendcounts,sdispls,&
!                      recvgene,recvcounts,rdispls,&
!                      TIMS_COMM_WORLD,mpi_err)
      call mpi_alltoallv(sendgene,sendcounts,sdispls,&
      					MPI_INTEGER,&
                      recvgene,recvcounts,rdispls,&
      					MPI_INTEGER,&
                      TIMS_COMM_WORLD,mpi_err)
! load the genes into the local space
      m=0
      do i=1,tsend
          ijk=nint((local_pop-1)*ran1())+1
          do k=1,gene_size
              m=m+1
              gene(k,ijk)=recvgene(m)
          enddo
      enddo
      deallocate(sendgene,recvgene,recvcounts2,sendcounts2)
  endif
!  write(*,*)'end of loop',gen
!    write(out1,*)'gen-best_gen=',gen-best_gen
    if(g_best .ge. quit_value .or. gen-best_gen > stagnate)exit
    rtime2=MPI_Wtime()-rtime1
    call MPI_BCAST(rtime2,1,MPI_DOUBLE_PRECISION,mpi_master,TIMS_COMM_WORLD,mpi_err)
    if(rtime2 .ge. maxtime)exit
    if(myid .eq. mpi_master .and. g_best .gt. -huge(g_best))then
      write(out1,"(f21.12,1x,f10.2,1x,i5)")g_best,rtime2,gen
    endif
  enddo
! did all of the generations now just finish up and quit
! find the final fitness of each member of the population
  do i=1,local_pop
      fit(i)%val=fitness(gene(:,i))
      fit(i)%index=i
  enddo
! sort the population
  call sort(fit,local_pop)
  write(out1,*)"current best",fit(1)%val,fitness(gene(:,fit(1)%index)),fit(1)%index
  write(out1,*)gene(:,fit(1)%index)
  write(out1,*)"saved best",best_fit,fitness(best)
  write(out1,*)best
! save the best
  if(fit(1)%val > best_fit)then
      best=gene(:,fit(1)%index)
      best_fit=fit(1)%val
  endif
! find the global best and print results
  thetop%value=best_fit
  thetop%proc_id=myid
  call MPI_ALLREDUCE(thetop,thetop2,1,MPI_2DOUBLE_PRECISION,&
                     MPI_MAXLOC,TIMS_COMM_WORLD,mpi_err)
  if(nint(thetop2%proc_id) .ne. mpi_master)then
      if(nint(thetop2%proc_id)  .eq. myid)&
          call MPI_SEND(best,gene_size,MPI_INTEGER,mpi_master,63131,&
              TIMS_COMM_WORLD,mpi_err)
      if(myid .eq. mpi_master)&
          call MPI_RECV(best,gene_size,MPI_INTEGER,nint(thetop2%proc_id) ,&
              63131,TIMS_COMM_WORLD,status,mpi_err)
  endif
  if(myid .eq. mpi_master)then
      allocate(contrib(0:numnodes-1),fit_time_array(0:numnodes-1))
      allocate(tot_time_array(0:numnodes-1),sort_time_array(0:numnodes-1))
  else
      allocate(contrib(1),fit_time_array(1))
      allocate(tot_time_array(1),sort_time_array(1))
  endif
  call timer(dt4)
  tot_time=dt4-dt3
  call wipe(root)
  call MPI_GATHER(theid  ,  1   ,MPI_INTEGER,&
                  contrib,  1   ,MPI_INTEGER,&
                  mpi_master,TIMS_COMM_WORLD,mpi_err)
  call MPI_GATHER(fit_time      ,  1   ,MPI_DOUBLE_PRECISION,&
                  fit_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                  mpi_master,TIMS_COMM_WORLD,mpi_err)
  call MPI_GATHER(sort_time  ,  1   ,MPI_DOUBLE_PRECISION,&
                  sort_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                  mpi_master,TIMS_COMM_WORLD,mpi_err)
  call MPI_GATHER(tot_time      ,  1   ,MPI_DOUBLE_PRECISION,&
                  tot_time_array,  1   ,MPI_DOUBLE_PRECISION,&
                  mpi_master,TIMS_COMM_WORLD,mpi_err)
  if(myid .eq. mpi_master)then
      write(out1,*)'node  genes sent   fitness    sort     total'
      write(out1,*)'       in sort    cpu time  cpu time  cpu time'
      do i=0,numnodes-1
          write(out1,"(i4,i12,3f10.3)")&
              i,contrib(i),fit_time_array(i),sort_time_array(i),tot_time_array(i)
      enddo
      write(out1,*)'the global best fitness is',thetop2%value,' for generations= ',gen
!      write(out1,"(8i3)")best
!      call output(best)
      call date_and_time(values=fval)
      write(out1,*)'program start time ',sval(5),':',sval(6),':',sval(7)
      write(out1,*)'program stop time  ',fval(5),':',fval(6),':',fval(7)

!*******************************************************     
! cut4
!*******************************************************
  endif
  !call MPI_FINALIZE(mpi_err)
  result=best
  if(myid .eq. mpi_master)then
  	write(out1,*)"fitness for result=",fitness(result)
  	write(out1,*)result
  	write(out1,*)"*************"
  endif
if(allocated( best ))			deallocate(best)
if(allocated( best_fit_vect ))	deallocate(best_fit_vect)
if(allocated( contrib ))			deallocate(contrib)
if(allocated( fit ))				deallocate(fit)
if(allocated( fit2 ))			deallocate(fit2)
if(allocated( fit_time_array ))	deallocate(fit_time_array)
!if(allocated( gene ))			deallocate(gene)
if(allocated( glob_best ))		deallocate(glob_best)
if(allocated( kids ))			deallocate(kids)
if(allocated( rdispls ))			deallocate(rdispls)
if(allocated( recvcounts ))		deallocate(recvcounts)
if(allocated( sdispls ))			deallocate(sdispls)
if(allocated( sendcounts ))		deallocate(sendcounts)
if(allocated( sort_time_array ))	deallocate(sort_time_array)
if(allocated( tot_time_array ))	deallocate(tot_time_array)
  return
102 write(*,*)'routines quitting could not read data'
  !call MPI_FINALIZE(mpi_err)
  return
end subroutine chuck

subroutine reproduce()
    use galapagos
    if(the_top)then
        call top_half
    else
        call roulette
    endif
end subroutine reproduce


subroutine top_half()
  use numz
  use problem
  use ran_mod
  use galapagos
  implicit none
  integer i,j,k,m,nstart,t,nend,j1,j2
! we allow the top half of the population to reproduce
! to produce a new gene we select two at randome from the top half
  t=local_pop/2-1
  do j = 1 , local_pop
    k=nint(t*ran1()+1)
    i=nint(t*ran1()+1)
    nstart=nint((gene_size-1)*ran1()+1)
    nend=nint((gene_size-1)*ran1()+1)
    if(nend .eq. nstart)then
	    do m=1 , nstart-1
	    	kids(m,j)=gene(m,fit(k)%index)
	    enddo
	    do m=nstart , gene_size
	    	kids(m,j)=gene(m,fit(i)%index)
	    enddo
    else
        j1=min(nstart,nend)
        j2=max(nstart,nend)
	    do m=1 , j1
	    	kids(m,j)=gene(m,fit(i)%index)
	    enddo
	    do m=j1+1 , j2-1
	    	kids(m,j)=gene(m,fit(k)%index)
	    enddo
	    do m=j2 , gene_size
	    	kids(m,j)=gene(m,fit(i)%index)
	    enddo
    endif

  enddo
  gene=kids
  return
end subroutine top_half

subroutine roulette()
! reproduce using classic roulette wheel selection 
! see fogels evolutionary computation page 91
  use numz
  use problem
  use ran_mod
  use galapagos
  use locate_mod
  implicit none
  integer i,j,k,m,nstart,nend,t,j1,j2
  real(b8)tot,x1,x2
! sum the values
  tot=0.0
  do j=1,local_pop
      tot=tot+fit(j)%val
  enddo
  if(tot .eq. 0.0_b8)tot=1.0_b8
! scale the values
  do j=1,local_pop
      fit(j)%val=fit(j)%val/tot
  enddo
! assign area
  fit(local_pop)%val=1.0_b8-fit(local_pop)%val
  do j=local_pop-1,1,-1
      fit(j)%val=fit(j+1)%val-fit(j)%val
  enddo
  fit(1)%val=0.0_b8  
  do j = 1 , local_pop
    x1=ran1()
    x2=ran1()
    k=locate(fit,x1)
    i=locate(fit,x2)
    nstart=nint((gene_size-1)*ran1()+1)
    nend=nint((gene_size-1)*ran1()+1)
    if(nend .eq. nstart)then
	    do m=1 , nstart-1
	    	kids(m,j)=gene(m,fit(k)%index)
	    enddo
	    do m=nstart , gene_size
	    	kids(m,j)=gene(m,fit(i)%index)
	    enddo
    else
        j1=min(nstart,nend)
        j2=max(nstart,nend)
	    do m=1 , j1
	    	kids(m,j)=gene(m,fit(i)%index)
	    enddo
	    do m=j1+1 , j2-1
	    	kids(m,j)=gene(m,fit(k)%index)
	    enddo
	    do m=j2 , gene_size
	    	kids(m,j)=gene(m,fit(i)%index)
	    enddo
    endif
  enddo
  gene=kids
  return
end subroutine roulette


subroutine mutate()
  use numz
  use problem
  use ran_mod
  use galapagos
!  use laser2
  implicit none
  integer i,j,ndo,k
  real(b8) sigma,mu
  if(mut_rate .le. 0.0)return
  if(do_one)then
	  do j = 1 , local_pop
	      if(mut_rate > ran1())then
	          i=nint((gene_size-1)*ran1()+1)
	          gene(i,j)=max_gene*ran1()
	      endif
	  enddo
  else
	mu=gene_size*mut_rate
	sigma=sqrt(mu*(1.0_b8-mut_rate))
	do j = 1 , local_pop
!	      do i=1,gene_size
!		      if(mut_rate > ran1())then
!		          gene(i,j)=max_gene*ran1()
!		      endif
!	      enddo
		ndo=nint(gasdev()*sigma+mu)
		ndo=max(0,min(ndo,gene_size))
	    do i=1,ndo
	          k=nint((gene_size-1)*ran1()+1)
	          gene(k,j)=max_gene*ran1()
	    enddo				
	enddo
  endif
  return
end subroutine mutate

subroutine invert()
	use numz
	use problem
	use ran_mod
	use galapagos
	implicit none
	integer i,j,n,m,k
	real(b8) sigma,mu
	if(invert_rate .le. 0.0_b8)return
	do j = 1 , local_pop
		if(invert_rate > ran1())then
			i=nint((gene_size-1)*ran1()+1)
			k=nint((gene_size-1)*ran1()+1)
			m=min(i,k)
			n=max(i,k)
			do i=m,m+(n-m)/2
				k=gene(i,j)
				gene(i,j)=gene(n-(i-m),j)
				gene(n-(i-m),j)=k
			enddo
		endif
	enddo
	return
end subroutine invert


! returns true if a number is even or false if odd
function even(i)
  integer i
  logical even
  j=i/2
  if(j*2 .eq. i)then
      even = .true.
  else
      even = .false.
  endif
  return
end function even


function mymod(i,j)
  integer mymod,i,j
  if(j .eq. 0)then
      mymod=-1
  else
      mymod=mod(i,j)
  endif
end function mymod
