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

