@process free(f90) init(f90ptr)
!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-C41                                                         *
!    (C) COPYRIGHT IBM CORP. 1997. ALL RIGHTS RESERVED.               *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
MODULE MAT_DIST
  PUBLIC MATDIST
CONTAINS
  SUBROUTINE MATDIST (A_GLOB, A, PARTS, ICONTXT, DESC_A,&
       & B_GLOB, B, INROOT)
  !
  ! An utility subroutine to distribute a matrix among processors
  ! according to a user defined data distribution, using PESSL
  ! sparse matrix subroutines.
  !
  !  Type(D_SPMAT)                            :: A_GLOB
  !     On Entry: this contains the global sparse matrix as follows:
  !        A%FIDA =='CSR'
  !        A%AS for coefficient values
  !        A%IA1  for column indices
  !        A%IA2  for row pointers
  !        A%M    for number of global matrix rows
  !        A%K    for number of global matrix columns
  !     On Exit : undefined, with unassociated pointers.
  !
  !  Type(D_SPMAT)                            :: A
  !     On Entry: fresh variable.
  !     On Exit : this will contain the local sparse matrix.
  ! 
  !       INTERFACE PARTS
  !         !   .....user passed subroutine.....
  !         SUBROUTINE PARTS(GLOBAL_INDX,N,NP,PV,NV)
  !           IMPLICIT NONE     
  !           INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, NP
  !           INTEGER, INTENT(OUT) :: NV
  !           INTEGER, INTENT(OUT) :: PV(*)
  !         
  !       END SUBROUTINE PARTS
  !       END INTERFACE
  !     On Entry:  subroutine providing user defined data distribution.
  !        For each GLOBAL_INDX the subroutine should return 
  !        the list  PV of all processes owning the row with 
  !        that index; the list will contain NV entries. 
  !        Usually NV=1; if NV >1 then we have an overlap in the data
  !        distribution.
  !
  !  Integer                                  :: ICONTXT
  !     On Entry: BLACS context.
  !     On Exit : unchanged.
  !
  !  Type (DESC_TYPE)                  :: DESC_A
  !     On Entry: fresh variable.
  !     On Exit : the updated array descriptor
  !
  !  Real(Kind(1.D0)), Pointer, Optional      :: B_GLOB(:)
  !     On Entry: this contains right hand side.
  !     On Exit : 
  !
  !  Real(Kind(1.D0)), Pointer, Optional      :: B(:)
  !     On Entry: fresh variable.
  !     On Exit : this will contain the local right hand side.
  !
  !  Integer, Optional    :: inroot
  !     On Entry: specifies processor holding A_GLOB. Default: 0
  !     On Exit : unchanged.
  !        
  !

    Use F90SPARSE

    Implicit None

  ! Parameters
    Type(D_SPMAT)              :: A_GLOB
    Real(Kind(1.D0)), Pointer  :: B_GLOB(:)
    Integer                    :: ICONTXT 
    Type(D_SPMAT)              :: A
    Real(Kind(1.D0)), Pointer  :: B(:)
    Type (DESC_TYPE)           :: DESC_A
    INTEGER, OPTIONAL          :: INROOT
    INTERFACE PARTS
     !   .....user passed subroutine.....
       SUBROUTINE PARTS(GLOBAL_INDX,N,NP,PV,NV)
         IMPLICIT NONE     
         INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, NP
         INTEGER, INTENT(OUT) :: NV
         INTEGER, INTENT(OUT) :: PV(*)
       
       END SUBROUTINE PARTS
    END INTERFACE
  
  
  ! Local variables
    Integer                     :: NPROW, NPCOL, MYPROW, MYPCOL
    Integer                     :: IRCODE, LENGTH_ROW, I_COUNT, J_COUNT,& 
         & K_COUNT, BLOCKDIM, ROOT, LIWORK, NROW, NCOL, NNZERO, NRHS,&
         & I,J,K, LL, INFO
    Integer, Pointer            :: IWORK(:)
    CHARACTER                   :: AFMT*5, atyp*5
    Type(D_SPMAT)               :: BLCK


  
  ! Executable statements

    IF (PRESENT(INROOT)) THEN
       ROOT = INROOT
    ELSE
       ROOT = 0
    END IF

  
    CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)

    IF (MYPROW == ROOT) THEN
     ! Extract information from A_GLOB
       IF (A_GLOB%FIDA /= 'CSR') THEN 
          WRITE(0,*) 'Unsupported input matrix format'
          CALL BLACS_ABORT(ICONTXT,-1)
       ENDIF
       NROW = A_GLOB%M     
       NCOL = A_GLOB%N
       IF (NROW /= NCOL) THEN
          WRITE(0,*) 'A rectangular matrix ? ',NROW,NCOL
          CALL BLACS_ABORT(ICONTXT,-1)
       ENDIF
       NNZERO = Size(A_GLOB%AS)
       NRHS   = 1
     ! Broadcast informations to other processors
       CALL IGEBS2D(ICONTXT, 'A', ' ', 1, 1, NROW, 1)
       CALL IGEBS2D(ICONTXT, 'A', ' ', 1, 1, NCOL, 1)
       CALL IGEBS2D(ICONTXT, 'A', ' ', 1, 1, NNZERO, 1)
       CALL IGEBS2D(ICONTXT, 'A', ' ', 1, 1, NRHS, 1)
    ELSE !(MYPROW <> root)
     ! Receive informations
       CALL IGEBR2D(ICONTXT, 'A', ' ', 1, 1, NROW, 1, ROOT, 0)
       CALL IGEBR2D(ICONTXT, 'A', ' ', 1, 1, NCOL, 1, ROOT, 0)
       CALL IGEBR2D(ICONTXT, 'A', ' ', 1, 1, NNZERO, 1, ROOT, 0)
       CALL IGEBR2D(ICONTXT, 'A', ' ', 1, 1, NRHS, 1, ROOT, 0)
    END IF
  
  ! Allocate integer work area
    LIWORK = MAX(NPROW, NROW + NCOL)
    ALLOCATE(IWORK(LIWORK), STAT = IRCODE)
    IF (IRCODE <> 0) THEN 
       WRITE(0,*) 'MATDIST Allocation failed'
       RETURN
    ENDIF
     
  
    IF (MYPROW == ROOT) THEN
       WRITE (*, FMT = *) 'Start matdist'
    ENDIF

    CALL PADALL(NROW,PARTS,DESC_A,ICONTXT)
    CALL PSPALL(A,DESC_A,NNZ=NNZERO/NPROW)
    CALL PGEALL(B,DESC_A)

  ! Prepare the local 
    ALLOCATE(BLCK%AS(NCOL),BLCK%IA1(NCOL),BLCK%IA2(2),STAT=IRCODE)
    IF (IRCODE /= 0) THEN
       WRITE(0,*) 'Error on allocating BLCK'
       CALL BLACS_ABORT(ICONTXT,-1)
       STOP
    ENDIF
  
    BLCK%M    = 1
    BLCK%N    = NCOL
    BLCK%FIDA = 'CSR'
    Do I_COUNT = 1, NROW
       CALL PARTS(I_COUNT,NROW,NPROW,IWORK, LENGTH_ROW)
     ! Here processors are counted 1..NPROW
       DO J_COUNT = 1, LENGTH_ROW
          K_COUNT = IWORK(J_COUNT)
          IF (MYPROW == ROOT) THEN
             BLCK%IA2(1) = 1
             BLCK%IA2(2) = 1
             DO J = A_GLOB%IA2(I_COUNT), A_GLOB%IA2(I_COUNT+1)-1
                BLCK%AS(BLCK%IA2(2)) = A_GLOB%AS(J)
                BLCK%IA1(BLCK%IA2(2)) = A_GLOB%IA1(J)
                BLCK%IA2(2) =BLCK%IA2(2) + 1
             ENDDO
             LL = BLCK%IA2(2) - 1
             IF (K_COUNT == MYPROW) THEN
                BLCK%INFOA(1) = LL
                BLCK%INFOA(2) = LL
                BLCK%INFOA(3) = 2
                BLCK%INFOA(4) = 1
                BLCK%INFOA(5) = 1
                BLCK%INFOA(6) = 1            
                CALL PSPINS(A,I_COUNT,1,BLCK,DESC_A)
                CALL PGEINS(B,B_GLOB(I_COUNT:I_COUNT),DESC_A,I_COUNT)
             ELSE                
                CALL IGESD2D(ICONTXT,1,1,LL,1,K_COUNT,0)
                CALL IGESD2D(ICONTXT,LL,1,BLCK%IA1,LL,K_COUNT,0)
                CALL DGESD2D(ICONTXT,LL,1,BLCK%AS,LL,K_COUNT,0)
                CALL DGESD2D(ICONTXT,1,1,B_GLOB(I_COUNT),1,K_COUNT,0)        
                CALL IGERV2D(ICONTXT,1,1,LL,1,K_COUNT,0)                
             ENDIF
          ELSE IF (MYPROW /= ROOT) THEN
             IF (K_COUNT == MYPROW) THEN 
                CALL IGERV2D(ICONTXT,1,1,LL,1,ROOT,0)
                BLCK%IA2(1) = 1
                BLCK%IA2(2) = LL+1           
                CALL IGERV2D(ICONTXT,LL,1,BLCK%IA1,LL,ROOT,0)
                CALL DGERV2D(ICONTXT,LL,1,BLCK%AS,LL,ROOT,0)
                CALL DGERV2D(ICONTXT,1,1,B_GLOB(I_COUNT),1,ROOT,0)
                CALL IGESD2D(ICONTXT,1,1,LL,1,ROOT,0)         
                CALL PSPINS(A,I_COUNT,1,BLCK,DESC_A)
                CALL PGEINS(B,B_GLOB(I_COUNT:I_COUNT),DESC_A,I_COUNT)
             ENDIF
          ENDIF
       END DO
    END DO


  ! Default storage format for sparse matrix; we do not
  ! expect duplicated entries. 
    AFMT = 'DEF'
    ATYP = 'GEN'
    CALL PSPASB(A,DESC_A,INFO=INFO,MTYPE=ATYP,STOR=AFMT,DUPFLAG=2) 

    CALL PGEASB(B,DESC_A)
  
    DEALLOCATE(BLCK%AS,BLCK%IA1,BLCK%IA2,IWORK)
  
    IF (MYPROW == root) Write (*, FMT = *) 'End matdist'    
  
    RETURN

  END SUBROUTINE MATDIST
END MODULE MAT_DIST
