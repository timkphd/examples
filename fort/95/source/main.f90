program backforth
    USE ISO_C_BINDING, ONLY: C_INT, C_FLOAT, C_LOC 
    USE FTN_C
    REAL (C_FLOAT), TARGET :: SEND(10)
    INTEGER (C_INT) :: SENDCOUNT
    Real (C_FLOAT) :: mysum
    REAL (C_FLOAT), ALLOCATABLE, TARGET :: RECV(:)

    SENDCOUNT=size(SEND)
    do i=1,SENDCOUNT
        SEND(i)=i
    enddo
    ALLOCATE( RECV(SENDCOUNT) )
    mysum=-1.0
    write(*,'("Fortran mysum before C call  = ",f7.1)'),mysum
    i=C_LIBRARY_FUNCTION(C_LOC(SEND), SENDCOUNT, C_LOC(RECV),mysum)
    write(*,'("Back from C in Fortran mysum = ",f7.1)'),mysum

    do i=1,SENDCOUNT
        write(*,*)send(i),recv(i)
    enddo
    write(*,'("Fortran calling C again")')
    call c_dosim()
end program
