@PROCESS FREE(F90) INIT(F90PTR)
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
!
!  READ_MAT subroutine reads a matrix and its right hand sides,
!  all stored in a BCS format file. The B field is optional,.
!
!  Character                            :: filename*20
!     On Entry: name of file to be processed.
!     On Exit : unchanged.
!
!  Type(D_SPMAT)                        :: A
!     On Entry: fresh variable.
!     On Exit : will contain the global sparse matrix as follows:
!        A%AS for coefficient values
!        A%IA1  for column indices
!        A%IA2  for row pointers
!        A%M    for number of global matrix rows
!        A%K    for number of global matrix columns
!
!  Integer                              :: ICTXT
!     On Entry: BLACS context.
!     On Exit : unchanged.
!
!  Real(Kind(1.D0)), Pointer, Optional  :: B(:,:)
!     On Entry: fresh variable.
!     On Exit:  will contain right hand side(s).
!
!  Integer, Optional                    :: inroot
!     On Entry: Index of root processor (default: 0)
!     On Exit : unchanged.
!
!  Real(Kind(1.D0)), Pointer, Optional  :: indwork(:)
!     On Entry/Exit: Double Precision Work Area.
!
!  Integer, Pointer, Optional           :: iniwork()
!     On Entry/Exit: Integer Work Area.
!
MODULE READ_MAT
  PUBLIC READMAT
CONTAINS
  SUBROUTINE READMAT (FILENAME, A, ICTXT, B, INROOT,&
       & INDWORK, INIWORK)
  
    USE F90SPARSE
    
    ! Parameters
    IMPLICIT NONE
    REAL(KIND(1.D0)), POINTER, OPTIONAL   :: B(:,:)
    INTEGER                               :: ICTXT
    TYPE(D_SPMAT)                         :: A
    CHARACTER                             :: FILENAME*(*)
    INTEGER, OPTIONAL                     :: INROOT
    REAL(KIND(1.0D0)), POINTER, OPTIONAL  :: INDWORK(:)
    INTEGER, POINTER, OPTIONAL            :: INIWORK(:)
  
  ! Local Variables
    INTEGER, PARAMETER          :: INFILE = 2
    CHARACTER                   :: MXTYPE*3, KEY*8, TITLE*72,&
         & INDFMT*16, PTRFMT*16, RHSFMT*20, VALFMT*20, RHSTYP
    INTEGER                     :: INDCRD,  PTRCRD, TOTCRD,&
         & VALCRD, RHSCRD, NROW, NCOL, NNZERO, NELTVL, NRHS, NRHSIX
    REAL(KIND(1.0D0)), POINTER  :: AS_LOC(:), DWORK(:)
    INTEGER, POINTER            :: IA1_LOC(:), IA2_LOC(:), IWORK(:)
    INTEGER                     :: D_ALLOC, I_ALLOC, IRCODE, I,&
         & J, LIWORK, LDWORK, ROOT, NPROW, NPCOL, MYPROW, MYPCOL


    IF (PRESENT(INROOT)) THEN
       ROOT = INROOT
    ELSE
       ROOT = 0
    END IF
     
    CALL BLACS_GRIDINFO(ICTXT, NPROW, NPCOL, MYPROW, MYPCOL)

    IF (MYPROW == ROOT) THEN
       WRITE(*, *) 'Start read_matrix'

     ! Open Input File
       OPEN(INFILE,FILE=FILENAME, STATUS='OLD', ERR=901, ACTION="READ")
       READ(INFILE,FMT='(A72,A8,/,5I14,/,A3,11X,4I14,/,2A16,2A20)',&
            & END=902) TITLE, KEY, TOTCRD, PTRCRD,INDCRD, VALCRD,&
            & RHSCRD, MXTYPE, NROW, NCOL, NNZERO, NELTVL,&
            & PTRFMT, INDFMT, VALFMT, RHSFMT
     
       A%M    = NROW
       A%N    = NCOL
       A%FIDA = 'CSR'
       IF (RHSCRD>0) READ(INFILE, FMT='(A1,13X,2I14)',&
            & END=902)  RHSTYP, NRHS, NRHSIX 

       IF (MXTYPE == 'RUA') THEN
          ALLOCATE(A%AS(NNZERO), A%IA1(NNZERO), A%IA2(NROW + 1),&
               & STAT = IRCODE)  
          IF (IRCODE <> 0)   GOTO 993
          READ(INFILE,FMT=PTRFMT,END=902) (A%IA2(I), I=1,NROW+1)
          READ(INFILE,FMT=INDFMT,END=902) (A%IA1(I), I=1,NNZERO)
          READ(INFILE,FMT=VALFMT,END=902) (A%AS(I), I=1,NNZERO) 

       ELSE IF (MXTYPE == 'RSA') THEN
        ! We are generally working with non-symmetric matrices, so
        ! we de-symmetrize what we are about to read
          ALLOCATE(A%AS(2*NNZERO),A%IA1(2*NNZERO),&
               & A%IA2(NROW+1),AS_LOC(2*NNZERO),&
               & IA1_LOC(2*NNZERO),IA2_LOC(NROW+1),STAT=IRCODE) 
          IF (IRCODE <> 0)   GOTO 993           
          READ(INFILE,FMT=PTRFMT,END=902) (IA2_LOC(I), I=1,NROW+1)
          READ(INFILE,FMT=INDFMT,END=902) (IA1_LOC(I), I=1,NNZERO)
          READ(INFILE,FMT=VALFMT,END=902) (AS_LOC(I), I=1,NNZERO)     

          LDWORK = MAX(NROW + 1, 2 * NNZERO)    
          IF (PRESENT(INDWORK)) THEN
             IF (SIZE(INDWORK) >= LDWORK) THEN
                DWORK => INDWORK
                D_ALLOC = 0
             ELSE
                ALLOCATE(DWORK(LDWORK), STAT = IRCODE)
                D_ALLOC = 1
             END IF
          ELSE
             ALLOCATE(DWORK(LDWORK), STAT = IRCODE)
             D_ALLOC = 1
          END IF
          IF (IRCODE <> 0)   GOTO 993
        
          LIWORK = NROW + 1     
          IF (PRESENT(INIWORK)) THEN
             IF (SIZE(INIWORK) >= LIWORK) THEN
                IWORK => INIWORK
                I_ALLOC = 0 
             ELSE
                ALLOCATE(IWORK(LIWORK), STAT = IRCODE)
                I_ALLOC = 1
             END IF
          ELSE
             ALLOCATE(IWORK(LIWORK), STAT = IRCODE)
             I_ALLOC = 1
          END IF
          IF (IRCODE <> 0)   GOTO 993

        ! After this call NNZERO contains the actual value for
        ! desymetrized matrix
          CALL DESYM(NROW, AS_LOC, IA1_LOC, IA2_LOC, A%AS, A%IA1,&
               & A%IA2, IWORK, DWORK, NNZERO, 1) 

          DEALLOCATE(AS_LOC, IA1_LOC, IA2_LOC)
          IF (D_ALLOC == 1)   DEALLOCATE(DWORK)
          IF (I_ALLOC == 1)   DEALLOCATE(IWORK)
       ELSE
          WRITE(0,*) 'READ_MATRIX: matrix type not yet supported'
          CALL BLACS_ABORT(ICTXT, 1)     
       END IF
            
     ! Read Right Hand Sides
       IF (PRESENT(B) .AND. (NRHS > 0)) THEN
          WRITE(0,*) 'Reading RHS'
          IF (RHSTYP == 'F') THEN
             ALLOCATE(B(NROW, NRHS), STAT = IRCODE)
             IF (IRCODE <> 0)   GOTO 993              
             READ(INFILE,FMT=RHSFMT,END=902) ((B(I,J), I=1,NROW),J=1,NRHS)  
          ELSE !(RHSTYP <> 'F')
             WRITE(0,*) 'READ_MATRIX: unsupported RHS type'
          END IF
       END IF

       CLOSE(INFILE)
       WRITE(*,*) 'End READ_MATRIX'     
    END IF
  
    RETURN

  ! Open failed
901 WRITE(0,*) 'READ_MATRIX: Could not open file ',&
         & INFILE,' for input'  
    CALL BLACS_ABORT(ICTXT, 1)
     
  ! Unexpected End of File
902 WRITE(0,*) 'READ_MATRIX: Unexpected end of file ',INFILE,&
         & ' during input'  
    CALL BLACS_ABORT(ICTXT, 1)
  
  ! Allocation Failed
993 WRITE(0,*) 'READ_MATRIX: Memory allocation failure'
    CALL BLACS_ABORT(ICTXT, 1)
  
  END SUBROUTINE READMAT
END MODULE READ_MAT
