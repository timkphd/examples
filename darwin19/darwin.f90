program darwin
    use numz
    use mympi
    use more_mpi
    use ga_list_mod
    use problem
    use global
    use galapagos
    
    use counts
    use tree_data
    use tree_junk
    use splayvars
    use dtime

    integer,allocatable:: input(:)
    logical init_it
    real(b8)t0,t1,t2,t3
    interface unique
	function unique(name,i)
            use numz
            character (len=*) name
            character (len=20) unique
            integer , optional, intent(in) :: i
	end function unique
    end interface
    call init
    call timer(t0)
!    	call system("/usr/bin/uptime")
!    	call MPI_BARRIER(MPI_COMM_WORLD,ijk)
    in_file="darwin.in"
! c_starttime is in global
    open(out1,file=unique(c_starttime)) 
    call dtime_init()
    init_it=.true.
    allocate(input(1))
    call timer(t1)
    bs=799
    allocate(key%bytes(bs))
    do j=1,bs
        key%bytes(j)=-1
    enddo
    call insert(key, -1e20, root)
    !write(*,*)"did insert"
    call chuck(input,init_it)
    call timer(t2)
    deallocate(input)
    allocate(input(gene_size))
    input=0
    init_it=.false.
    !write(*,*)"calling chuck again"
    call chuck(input,init_it)
!    call wipe(root)
    !write(*,*)"back from chuck again"
    if(myid.eq.mpi_master)then
		write(out1,*)"result=",fitness(input)
		write(out1,'(4i2)')input
                call results(input)
    endif
    call timer(t3)
    write(out1,'("          problem size =",i14)')gene_size
    write(out1,'("time for problem setup =",f14.5)')t2-t1
    write(out1,'("        total run time =",f14.5)')t3-t0
    write(out1,'("splay stats reused=",i8,"  newone=",i8)')reused,newone
    call dtime_report(out1)
    write(out1,'("calling finalize")')
    close(out1)
    call MPI_FINALIZE(mpi_err)
    write(*,'("called finalize",i8)')myid

    stop
end program
