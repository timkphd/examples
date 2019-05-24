@PROCESS FREE(F90) INIT(F90PTR)
!
! This sample program shows how to build and solve a sparse linear
! system using the subroutines in the sparse section of Parallel
! ESSL; the matrices are read from file using the Harwell-Boeing
! exchange format. Details on the format and sample matrices are
! available from
! 
! http://math.nist.gov/MatrixMarket/
!
! The user can choose between different data distribution strategies.
! These are equivalents to the HPF BLOCK and  CYCLIC(N) distributions;
! they do not take into account the sparsity pattern of the input
! matrix. 
! 
PROGRAM HB_SAMPLE
  USE F90SPARSE
  USE MAT_DIST
  USE READ_MAT
  USE PARTRAND
  USE PARTBCYC
  IMPLICIT NONE
  
  ! Input parameters
  CHARACTER*40 :: CMETHD, PREC, MTRX_FILE
  CHARACTER*80 :: CHARBUF

  DOUBLE PRECISION DDOT
  EXTERNAL DDOT
  EXTERNAL PART_BLOCK

  INTEGER, PARAMETER    :: IZERO=0, IONE=1
  CHARACTER, PARAMETER  :: ORDER='R'
  REAL(KIND(1.D0)), POINTER,SAVE :: B_COL(:), X_COL(:), R_COL(:), &
       & B_COL_GLOB(:), X_COL_GLOB(:), R_COL_GLOB(:), B_GLOB(:,:)
  INTEGER              :: IARGC
  Real(Kind(1.d0)), Parameter :: Dzero = 0.d0, One = 1.d0
  Real(Kind(1.d0)) :: TIMEF, T1, T2, TPREC, R_AMAX, B_AMAX,bb(1,1)
  integer :: nrhs, nrow, nx1, nx2
  External IARGC, TIMEF
  integer bsze,overlap
  common/part/bsze,overlap
  
  ! Sparse Matrices
  TYPE(D_SPMAT) :: A, AUX_A
  TYPE(D_PRECN) :: APRC
  ! Dense Matrices
  REAL(KIND(1.D0)), POINTER ::  AUX_B(:,:) , AUX1(:), AUX2(:)
  
  ! Communications data structure
  TYPE(DESC_TYPE)    :: DESC_A

  ! BLACS parameters
  INTEGER            :: NPROW, NPCOL, ICTXT, IAM, NP, MYPROW, MYPCOL
  
  ! Solver paramters
  INTEGER            :: ITER, ITMAX, IERR, ITRACE, IRCODE, IPART,&
       & IPREC, METHD, ISTOPC
  REAL(KIND(1.D0))   :: ERR, EPS
  integer   iparm(20)
  real(kind(1.d0)) rparm(20)
   
  ! Other variables
  INTEGER            :: I,INFO,J
  INTEGER            :: INTERNAL, M,II,NNZERO
  
  ! common area
  INTEGER M_PROBLEM, NPROC
 
  ! Initialize BLACS
  CALL BLACS_PINFO(IAM, NP)
  CALL BLACS_GET(IZERO, IZERO, ICTXT)

  ! Rectangular Grid,  Np x 1

  CALL BLACS_GRIDINIT(ICTXT, ORDER, NP, IONE)
  CALL BLACS_GRIDINFO(ICTXT, NPROW, NPCOL, MYPROW, MYPCOL)

  !
  !  Get parameters
  !
  CALL GET_PARMS(ICTXT,MTRX_FILE,CMETHD,PREC,&
       & IPART,ISTOPC,ITMAX,ITRACE)

  CALL BLACS_BARRIER(ICTXT,'A')
  T1 = TIMEF()  
  ! Read the input matrix to be processed and (possibly) the RHS 
  IF (IAM == 0) THEN
     CALL READMAT(MTRX_FILE, AUX_A, ICTXT,B=AUX_B)
     M_PROBLEM = AUX_A%M
     CALL IGEBS2D(ICTXT,'A',' ',1,1,M_PROBLEM,1)
     IF (SIZE(AUX_B,1).EQ.M_PROBLEM) THEN
        ! If any RHS were present, broadcast the first one
        NRHS = 1
        CALL IGEBS2D(ICTXT,'A',' ',1,1,NRHS,1)
        CALL DGEBS2D(ICTXT,'A',' ',M_PROBLEM,1,AUX_B(:,1),M_PROBLEM) 
     ELSE
        NRHS = 0
        CALL IGEBS2D(ICTXT,'A',' ',1,1,NRHS,1)
     ENDIF
  ELSE
     CALL IGEBR2D(ICTXT,'A',' ',1,1,M_PROBLEM,1,0,0)
     CALL IGEBR2D(ICTXT,'A',' ',1,1,NRHS,1,0,0)
     IF (NRHS.EQ.1) THEN
        ALLOCATE(AUX_B(M_PROBLEM,1), STAT=IRCODE)
        IF (IRCODE /= 0) THEN
           WRITE(0,*) 'Memory allocation failure in HB_SAMPLE'
           CALL BLACS_ABORT(ICTXT,-1)
           STOP
        ENDIF
        CALL DGEBR2D(ICTXT,'A',' ',M_PROBLEM,1,AUX_B,M_PROBLEM,0,0) 
     ENDIF
  END IF
  IF (NRHS.EQ.1 ) THEN
     B_COL_GLOB =>AUX_B(:,1)
  ELSE
     ALLOCATE(AUX_B(M_PROBLEM,1), STAT=IRCODE)
     B_COL_GLOB =>AUX_B(:,1)
     IF (IAM==0) THEN 
        DO I=1, M_PROBLEM
           B_COL_GLOB(I) = REAL(I)*2.0/REAL(M_PROBLEM)
        ENDDO
     ENDIF
  ENDIF
  NPROC = NPROW 

  ! Switch over different partition types
  IF (IPART > 0 ) THEN
     WRITE(6,*) 'Partition type: CYCLIC(NB)'
     CALL SET_NB(IPART,0,0,ICTXT)
     CALL MATDIST(AUX_A, A, PART_BCYC, ICTXT, &
          & DESC_A,B_COL_GLOB,B_COL)    
  ELSE
     SELECT CASE (IPART)
        
     CASE (0)
        WRITE(6,*) 'Partition type: BLOCK'
        CALL MATDIST(AUX_A, A, PART_BLOCK, ICTXT, &
             & DESC_A,B_COL_GLOB,B_COL)
     CASE (-1)
        WRITE(6,*) 'Partition type: RANDOM'
        IF (IAM==0) THEN 
           CALL BUILD_RNDPART(AUX_A,NP)
        ENDIF
        CALL DISTR_RNDPART(0,0,ICTXT)
        CALL MATDIST(AUX_A, A, PART_RAND, ICTXT, &
             & DESC_A,B_COL_GLOB,B_COL)
     CASE DEFAULT
        WRITE(6,*) 'Partition type: BLOCK'
        CALL MATDIST(AUX_A, A, PART_BLOCK, ICTXT, &
             & DESC_A,B_COL_GLOB,B_COL)
     END SELECT
  ENDIF

  
  CALL PGEALL(X_COL,DESC_A)
  CALL PGEASB(X_COL,DESC_A)
  T2 = TIMEF() - T1
  
  
  CALL DGAMX2D(ICTXT, 'A', ' ', IONE, IONE, T2, IONE,&
       & T1, T1, -1, -1, -1)
  
  IF (IAM.EQ.0) THEN
     WRITE(6,*) 'Time to Read and Partition Matrix : ',T2/1.D3
  END IF
  
  !
  !  Prepare the preconditioning matrix. Note the availability
  !  of optional parameters
  !
  IF (PREC(1:3) == 'ILU') THEN
     IPREC = 2
  ELSE IF (PREC(1:6) == 'DIAGSC') THEN
     IPREC = 1
  ELSE IF (PREC(1:4) == 'NONE') THEN 
     IPREC = 0
  ELSE
     WRITE(0,*) 'Unknown preconditioner'
     CALL BLACS_ABORT(ICTXT,-1)
  END IF
  CALL BLACS_BARRIER(ICTXT,'A')
  T1 = TIMEF()
  CALL PSPGPR(IPREC,A,APRC,DESC_A,INFO=INFO)
  TPREC = TIMEF()-T1

 
  CALL DGAMX2D(ICTXT,'A',' ',IONE, IONE,TPREC,IONE,T1,T1,-1,-1,-1)
  
  IF (IAM.EQ.0) WRITE(6,*) 'Preconditioner Time : ',TPREC/1.D3
  IF (INFO /= 0) THEN
     WRITE(0,*) 'Error in preconditioner :',INFO
     CALL BLACS_ABORT(ICTXT,-1)
     STOP
  END IF

  IPARM = 0
  RPARM = 0.D0 
  
  EPS   = 1.D-8
  RPARM(1) = EPS
  IPARM(2) = ISTOPC
  IPARM(3) = ITMAX
  IPARM(4) = ITRACE
  IF (CMETHD(1:6).EQ.'CGSTAB') Then
     IPARM(1)=1
  ELSE IF (CMETHD(1:3).EQ.'CGS') THEN
     IPARM(1)=2
  ELSE IF (CMETHD(1:5).EQ.'TFQMR') THEN
     IPARM(1)=3
  ELSE
     WRITE(0,*) 'Unknown method '
     CALL BLACS_ABORT(ICTXT,-1)
     IPARM(1)=0
  END IF
  METHD = IPARM(1)
   
  CALL BLACS_BARRIER(ICTXT,'All')
  T1 = TIMEF()
  CALL PSPGIS(A,B_COL,X_COL,APRC,DESC_A,&
       & IPARM=IPARM,RPARM=RPARM,INFO=IERR)
  CALL BLACS_BARRIER(ICTXT,'All')
  T2 = TIMEF() - T1
  CALL DGAMX2D(ICTXT,'A',' ',IONE, IONE,T2,IONE,T1,T1,-1,-1,-1)
  ITER=IPARM(5)
  ERR = RPARM(2)
  IF (IAM.EQ.0) THEN
     WRITE(6,*) 'methd iprec istopc   : ',METHD, IPREC, ISTOPC
     WRITE(6,*) 'Number of iterations : ',ITER
     WRITE(6,*) 'Time to Solve Matrix : ',T2/1.D3
     WRITE(6,*) 'Time per iteration   : ',T2/(1.D3*ITER)
     WRITE(6,*) 'Error on exit        : ',ERR
  END IF
  
  CALL PGEFREE(B_COL, DESC_A)
  CALL PGEFREE(X_COL, DESC_A)
  CALL PSPFREE(A, DESC_A)
  CALL PSPFREE(APRC, DESC_A)
  CALL PADFREE(DESC_A)
  CALL BLACS_GRIDEXIT(ICTXT)
  CALL BLACS_EXIT(0)
  
CONTAINS
  !
  ! Get iteration parameters from the command line
  !
  SUBROUTINE  GET_PARMS(ICONTXT,MTRX_FILE,CMETHD,PREC,IPART,&
       & ISTOPC,ITMAX,ITRACE)
    integer      :: icontxt
    Character*40 :: CMETHD, PREC, MTRX_FILE
    Integer      :: IRET, ISTOPC,ITMAX,ITRACE,IPART
    Character*40 :: CHARBUF
    INTEGER      :: IARGC, NPROW, NPCOL, MYPROW, MYPCOL
    EXTERNAL     IARGC
    INTEGER      :: INPARMS(20), IP
    
    CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)
    IF (MYPROW==0) THEN
       ! Read Input Parameters
       IF (IARGC().GE.3) THEN
          CALL GETARG(1,CHARBUF)
          READ(CHARBUF,*) MTRX_FILE
          CALL GETARG(2,CHARBUF)
          READ(CHARBUF,*) CMETHD
          CALL GETARG(3,CHARBUF)
          READ(CHARBUF,*) PREC
          IF (IARGC().GE.4) THEN
             CALL GETARG(4,CHARBUF)
             READ(CHARBUF,*) IPART
          ELSE
             IPART = 0
          ENDIF
          IF (IARGC().GE.5) THEN
             CALL GETARG(5,CHARBUF)
             READ(CHARBUF,*) ITMAX 
          ELSE
             ITMAX  = 500
          ENDIF
          IF (IARGC().GE.6) THEN
             CALL GETARG(6,CHARBUF)
             READ(CHARBUF,*) ISTOPC
          ELSE
             ISTOPC = 1
          ENDIF
          IF (IARGC().GE.7) THEN
             CALL GETARG(7,CHARBUF)
             READ(CHARBUF,*) ITRACE
          ELSE
             ITRACE = 0
          ENDIF
           
        ! Convert strings to integers
          DO I = 1, 20
             INPARMS(I) = IACHAR(MTRX_FILE(I:I))
          END DO
        ! Broadcast parameters to all processors
          CALL IGEBS2D(ICTXT,'A',' ',20,1,INPARMS,20)
        
        ! Convert strings in array
          DO I = 1, 20
             INPARMS(I) = IACHAR(CMETHD(I:I))
          END DO
        ! Broadcast parameters to all processors
          CALL IGEBS2D(ICTXT,'A',' ',20,1,INPARMS,20)
        
          DO I = 1, 20
             INPARMS(I) = IACHAR(PREC(I:I))
          END DO
        ! Broadcast parameters to all processors
          CALL IGEBS2D(ICTXT,'A',' ',20,1,INPARMS,20)

        ! Broadcast parameters to all processors
          CALL IGEBS2D(ICTXT,'A',' ',1,1,IPART,1)
          CALL IGEBS2D(ICTXT,'A',' ',1,1,ITMAX,1)
          CALL IGEBS2D(ICTXT,'A',' ',1,1,ISTOPC,1)
          CALL IGEBS2D(ICTXT,'A',' ',1,1,ITRACE,1)

       ELSE  
          CALL PR_USAGE(0)
          CALL BLACS_ABORT(ICTXT,-1)
          STOP 1
       END IF
    ELSE
     ! Receive Parameters
       CALL IGEBR2D(ICTXT,'A',' ',20,1,INPARMS,20,0,0)
       DO I = 1, 20
          MTRX_FILE(I:I) = ACHAR(INPARMS(I))
       END DO
       
       CALL IGEBR2D(ICTXT,'A',' ',20,1,INPARMS,20,0,0)
       DO I = 1, 20
          CMETHD(I:I) = ACHAR(INPARMS(I))
       END DO
        
       CALL IGEBR2D(ICTXT,'A',' ',20,1,INPARMS,20,0,0)
       DO I = 1, 20
          PREC(I:I) = ACHAR(INPARMS(I))
       END DO
     
       CALL IGEBR2D(ICTXT,'A',' ',1,1,IPART,1,0,0)
       CALL IGEBR2D(ICTXT,'A',' ',1,1,ITMAX,1,0,0)
       CALL IGEBR2D(ICTXT,'A',' ',1,1,ISTOPC,1,0,0)
       CALL IGEBR2D(ICTXT,'A',' ',1,1,ITRACE,1,0,0)
     
    END IF
    
  END SUBROUTINE GET_PARMS
  SUBROUTINE PR_USAGE(IOUT)
    INTEGER IOUT
    WRITE(IOUT, *) ' Number of parameters is incorrect!'
    WRITE(IOUT, *) ' Use: hb_sample mtrx_file methd prec [ptype &
         &itmax istopc itrace]' 
    WRITE(IOUT, *) ' Where:'
    WRITE(IOUT, *) '     mtrx_file      is stored in HB format'
    WRITE(IOUT, *) '     methd          may be: CGSTAB CGS TFQMR'
    WRITE(IOUT, *) '     prec           may be: ILU DIAGSC NONE'
    WRITE(IOUT, *) '     ptype          Partition strategy default 0'
    WRITE(IOUT, *) '                   >0: CYCLIC(ptype)   '
    WRITE(IOUT, *) '                    0: BLOCK partition '
    WRITE(IOUT, *) '                   -1: Random partition  '
    WRITE(IOUT, *) '     itmax          Max iterations [500]        '
    WRITE(IOUT, *) '     istopc         Stopping criterion [1]      '
    WRITE(IOUT, *) '     itrace         0  (no tracing, default) or '
    WRITE(IOUT, *) '                    >= 0 do tracing every ITRACE'
    WRITE(IOUT, *) '                    iterations ' 
  END SUBROUTINE PR_USAGE
END PROGRAM HB_SAMPLE
  




