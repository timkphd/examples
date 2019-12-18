MODULE FTN_C 
INTERFACE
! int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum)
INTEGER (C_INT) FUNCTION C_LIBRARY_FUNCTION (SENDBUF, SENDCOUNT, RECV, mysum) &
                BIND(C, NAME='C_Library_Function')
    USE ISO_C_BINDING
    IMPLICIT NONE
    TYPE (C_PTR), VALUE :: SENDBUF 
    INTEGER (C_INT), VALUE :: SENDCOUNT 
     Real (C_FLOAT) :: mysum
    TYPE (C_PTR), VALUE :: RECV
    END FUNCTION C_LIBRARY_FUNCTION 
END INTERFACE
INTERFACE
subroutine c_dosim ( ) BIND(C, NAME='do_sim')
    USE ISO_C_BINDING
    IMPLICIT NONE
    END subroutine c_dosim 
END INTERFACE
END MODULE FTN_C

SUBROUTINE SIMULATION(ALPHA, BETA, GAMMA, DELTA, ARRAYS) BIND(C ,NAME='f_routine')
    USE ISO_C_BINDING
    IMPLICIT NONE
    INTEGER (C_LONG), VALUE :: alpha
    REAL (C_DOUBLE), INTENT(INOUT) :: beta
    REAL (C_DOUBLE), INTENT(OUT) :: gamma
    REAL (C_DOUBLE),DIMENSION(*),INTENT(IN) :: DELTA 
    TYPE, BIND(C) :: PASS
        INTEGER (C_INT) :: LENC, LENF
        TYPE (C_PTR) :: C, F 
    END TYPE PASS
    TYPE (PASS), INTENT(INOUT) :: ARRAYS
    REAL (C_FLOAT), ALLOCATABLE, TARGET, SAVE :: ETA(:) 
    REAL (C_FLOAT), POINTER :: C_ARRAY(:)
    integer i,j
    write(*,'("In Fortran called from C alpha=",i4,&
              " beta=",f10.2," gamma=",f10.2)')&
            alpha,beta,gamma
    gamma=0.0
    do i=1,alpha
        gamma=gamma+beta*delta(i)
    enddo
    beta=1234.0
    
    !...
    write(*,*)"! Associate C_ARRAY with an array allocated in C"
    CALL C_F_POINTER (ARRAYS%C, C_ARRAY, (/ARRAYS%LENC/) ) 
    if(c_associated(ARRAYS%C, c_loc(C_ARRAY)))then
        write(*,*)'ARRAYS%C, C_ARRAY point to same target'
    else
        write(*,*)'ARRAYS%C, C_ARRAY do not point to same target'
        stop
    endif
    !...
    write(*,*)"! Allocate an array and make it available in C" 
    ARRAYS%LENF = 100
    ALLOCATE (ETA(ARRAYS%LENF))
    ARRAYS%F = C_LOC(ETA)
    j=min(ARRAYS%lenc,ARRAYS%lenf)
    write(*,*)"Fortan fills the array for C"
    do i=1,j
        ETA(i)=C_ARRAY(i)*2
    enddo
END SUBROUTINE SIMULATION

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
