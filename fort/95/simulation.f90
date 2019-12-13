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

