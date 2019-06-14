module dtime
use numz
real(b8) :: insert_t,test_t,invert_t
real(b8) :: dtime_1,dtime_2
integer :: scache

contains
    subroutine dtime_init()
        use mympi
        use more_mpi
        logical :: file_exists
        insert_t=0
        test_t=0
        invert_t=0
        scache=101
        if(myid.eq.mpi_master)then
            scache=1000000
            INQUIRE(FILE="cache", EXIST=file_exists)
            if(file_exists)then
                open(32,file="cache")
                read(32,*)scache
                close(32)
            endif
        endif
        call MPI_BCAST(scache,1,MPI_INTEGER,mpi_master,MPI_COMM_WORLD,mpi_err)
    end subroutine

    subroutine dtime_report(ifile)
        write(ifile,1234)scache,test_t,insert_t,invert_t
    1234 format("cache start=",i10," test=",f10.2,"  insert=",f10.2,"  invert=",f10.2)
    end subroutine
end module
    
