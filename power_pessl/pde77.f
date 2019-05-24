!*******************************************************************************
!*    LICENSED MATERIALS - PROPERTY OF IBM                                     *
!*    "RESTRICTED MATERIALS OF IBM"                                            *
!*                                                                             *
!*    5765-C41                                                                 *
!*    (C) COPYRIGHT IBM CORP. 1997. ALL RIGHTS RESERVED.                       *
!*                                                                             *
!*    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION               *
!*    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH               *
!*    IBM CORP.                                                                *
!*******************************************************************************
!*******************************************************************************
!* THIS SAMPLE PROGRAM SHOWS HOW TO BUILD AND SOLVE A SPARSE LINEAR            *
!* SYSTEM USING THE SUBROUTINES IN THE SPARSE SECTION OF PARALLEL              *
!* ESSL.  THE MATRIX AND RHS ARE GENERATED                                     *
!* IN PARALLEL, SO THAT THERE IS NO SERIAL BOTTLENECK.                         *
!*                                                                             *
!* THE PROGRAM SOLVES A LINEAR SYSTEM BASED ON THE PARTIAL DIFFERENTIAL        *
!* EQUATION                                                                    *
!*                                                                             *
!*   b1 dd(u)  b2 dd(u)    b3 dd(u)    a1 d(u)   a2 d(u)  a3 d(u)              *
!* -   ------ -  ------ -  ------ -  -----  -  ------  -  ------ + a4 u        *
!*      dxdx     dydy       dzdz        dx       dy         dz                 *
!*                                                                             *
!*  = 0                                                                        *
!*                                                                             *
!* WITH  DIRICHLET BOUNDARY CONDITIONS ON THE UNIT CUBE                        *
!*                                                                             *
!*    0<=x,y,z<=1                                                              *
!*                                                                             *
!* THE EQUATION IS DISCRETIZED WITH FINITE DIFFERENCES AND UNIFORM STEPSIZE;   *
!* THE RESULTING  DISCRETE  EQUATION IS                                        *
!*                                                                             *
!* ( u(x,y,z)(2b1+2b2+2b3+a1+a2+a3)+u(x-1,y,z)(-b1-a1)+u(x,y-1,z)(-b2-a2)+     *
!*  + u(x,y,z-1)(-b3-a3)-u(x+1,y,z)b1-u(x,y+1,z)b2-u(x,y,z+1)b3)*(1/h**2)      *
!*                                                                             *
!*                                                                             *
!* IN THIS SAMPLE PROGRAM THE INDEX SPACE OF THE DISCRETIZED                   *
!* COMPUTATIONAL DOMAIN IS FIRST NUMBERED SEQUENTIALLY IN A STANDARD WAY,      *
!* THEN THE CORRESPONDING VECTOR IS DISTRIBUTED ACCORDING TO AN HPF BLOCK      *
!* DISTRIBUTION DIRECTIVE.                                                     *
!*                                                                             *
!* BOUNDARY CONDITIONS ARE SET IN A VERY SIMPLE WAY, BY ADDING                 *
!* EQUATIONS OF THE FORM                                                       *
!*                                                                             *
!*   u(x,y,z) = rhs(x,y,z)                                                     *
!*******************************************************************************

      PROGRAM PDE77

          USE F90SPARSE
          IMPLICIT NONE
    
          EXTERNAL PART_BLOCK
    
          ! .... INPUT PARAMETERS .... !
    
          CHARACTER*10 :: CMETHD, PREC
          INTEGER      :: IDIM      
    
          ! .... MISCELLANEOUS .... !
    
          INTEGER,   PARAMETER        :: IZERO=0, IONE=1
          CHARACTER, PARAMETER        :: ORDER='R'
          LOGICAL,   PARAMETER        :: UPDATE=.TRUE., NOUPDATE=.FALSE.

          REAL(KIND(1.D0)), POINTER   :: B_COL(:), X_COL(:)
          REAL(KIND(1.D0)), POINTER   :: DWORK(:)
          REAL(KIND(1.D0)), PARAMETER :: DZERO = 0.D0, ONE = 1.D0
          REAL(KIND(1.D0))            :: TIMEF, T1, T2, TPREC, TSOLVE
          REAL(KIND(1.D0))            :: T3, T4

          INTEGER                     :: NR, NNZ,IRCODE, NNZ1,  NRHS
          EXTERNAL                       TIMEF
    
          ! .... SPARSE MATRICES .... !
    
          REAL(8), POINTER  :: AS(:), PRCS(:)
          INTEGER, POINTER  :: DESC_A(:), IA1(:), IA2(:)
          INTEGER           :: INFOA(30)
          
          
          ! .... DENSE MATRICES .... !
    
          REAL(KIND(1.D0)), POINTER :: B(:), X(:)
          INTEGER                   :: LB, LX, LDV, LDV1, IRET
    
          INTERFACE
              SUBROUTINE CREATE_MTRX_ELL1_BLOCK(PARTS,IDIM,
     &                 AS,IA1,IA2,INFOA,B,T,DESC_A,ICONTXT)
                  IMPLICIT NONE
                  EXTERNAL PARTS
                  INTEGER                  :: IDIM
                  REAL(KIND(1.D0)),POINTER :: B(:), T(:), AS(:)
                  INTEGER                  :: INFOA(30)
                  INTEGER, POINTER         :: DESC_A(:), IA1(:),IA2(:)
                  INTEGER                  :: ICONTXT
              END SUBROUTINE CREATE_MTRX_ELL1_BLOCK
          END INTERFACE
          
          ! .... COMMUNICATIONS DATA STRUCTURE .... !

          ! .... BLACS PARAMETERS .... !
    
          INTEGER            :: NPROW, NPCOL, ICONTXT, IAM, NP, MYPROW,
     &                          MYPCOL
          
          ! .... SOLVER PARAMETERS .... !
    
          INTEGER            :: ITER, ITMAX, IERR, ITRACE, METHD, IPREC,
     &                          ISTOPC, IPARM(20)
          REAL(KIND(1.D0))   :: ERR, EPS, RPARM(20)
          
          ! .... OTHER VARIABLES .... !
    
          INTEGER            :: I, INFO
          INTEGER            :: INTERNAL, M, II, NNZERO
          
          ! .... INITIALIZE BLACS .... !
    
          CALL BLACS_PINFO(IAM, NP)
          CALL BLACS_GET(IZERO, IZERO, ICONTXT)
          
          ! .... RECTANGULAR GRID,  NP X 1 .... !
          
          CALL BLACS_GRIDINIT(ICONTXT, ORDER, NP, IONE)
          CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)
    
          ! .... GET PARAMETERS .... !
    
          CALL GET_PARMS(ICONTXT,CMETHD,PREC,IDIM,ISTOPC,ITMAX,ITRACE)
     
          ! .... ALLOCATE AND FILL IN THE COEFFICIENT MATRIX AND THE RHS .... !
    
          CALL BLACS_BARRIER(ICONTXT,'All')
    
          T1 = TIMEF()
    
          CALL CREATE_MTRX_ELL1_BLOCK(PART_BLOCK,IDIM,AS,IA1,IA2,INFOA,
     &                                B,X,DESC_A,ICONTXT)
    
          T2 = TIMEF() - T1
          
          CALL DGAMX2D(ICONTXT,'A',' ',IONE, IONE,T2,IONE,T1,T1,
     &                 -1,-1,-1)

          IF (IAM.EQ.0) WRITE(6,*) 'Matrix creation Time : ',T2/1.D3
          
          LB   = SIZE(B)
          LX   = SIZE(X)
          LDV  = DESC_A(5) 
          LDV1 = DESC_A(6)
          NNZ  = SIZE(AS)
          NNZ1 = SIZE(IA1)
    
          ALLOCATE(PRCS(10+2*NNZ+LDV+LDV1+40),STAT=IRCODE)
    
          IF (IRCODE /= 0) THEN 
             WRITE(0,*) 'Allocation error'
             CALL BLACS_ABORT(ICONTXT,-1)
             STOP
          ENDIF
          
          ! .... PREPARE THE PRECONDITIONING DATA STRUCTURE .... !
    
          SELECT CASE (PREC)
          CASE ('ILU')
              IPREC = 2
          CASE ('DIAGSC')
              IPREC = 1
          CASE ('NONE')
              IPREC = 0
          CASE DEFAULT
              WRITE(0,*) 'Unknown preconditioner'
              CALL BLACS_ABORT(ICONTXT,-1)
          END SELECT
          
          CALL BLACS_BARRIER(ICONTXT,'All')
    
          T1 = TIMEF()
    
          CALL PDSPGPR(IPREC,AS,IA1,IA2,INFOA,PRCS,SIZE(PRCS),
     &                 DESC_A,IRET)
    
          TPREC = TIMEF()-T1
          
          CALL DGAMX2D(ICONTXT,'A',' ',IONE, IONE,TPREC,IONE,T1,T1,
     &                 -1,-1,-1)
          
          IF (IAM.EQ.0) WRITE(6,*) 'Preconditioner Time : ',TPREC/1.D3
    
          IF (IRET.NE.0) THEN
              WRITE(0,*) 'Error on preconditioner',IRET
              CALL BLACS_ABORT(ICONTXT,-1)
              STOP
          ENDIF
          
          ! .... ITERATION PARAMETERS .... !
    
          IF (CMETHD(1:6).EQ.'CGSTAB') THEN
              METHD = 1     
          ELSEIF (CMETHD(1:3).EQ.'CGS') THEN
              METHD = 2
          ELSEIF (CMETHD(1:5).EQ.'TFQMR') THEN
              METHD = 3
          ELSE
              WRITE(0,*) 'Unknown method '
              CALL BLACS_ABORT(ICONTXT,-1)
              METHD = 0
          ENDIF
    
          EPS      = 1.D-9
          IPARM    = 0
          RPARM    = 0.D0

          IPARM(1) = METHD
          IPARM(2) = ISTOPC
          IPARM(3) = ITMAX
          IPARM(4) = ITRACE
          RPARM(1) = EPS
    
          NRHS = 1
          
          CALL BLACS_BARRIER(ICONTXT,'All')
          T1 = TIMEF()  
    
          CALL PDSPGIS(AS,IA1,IA2,INFOA,NRHS,B,LB,X,LX,PRCS,
     &                 DESC_A,IPARM,RPARM,INFO)
    
          CALL BLACS_BARRIER(ICONTXT,'All')
    
          TSOLVE = TIMEF() - T1
          ERR    = RPARM(2)
          ITER   = IPARM(5)
          
          IF (IAM.EQ.0) THEN

              WRITE(6,*) 'Time to Solve Matrix : ',TSOLVE/1.D3 
              WRITE(6,*) 'Time per iteration : ',TSOLVE/(1.D3*ITER)
              WRITE(6,*) 'Number of iterations : ',ITER
              WRITE(6,*) 'Error on exit : ',ERR
              WRITE(6,*) 'INFO on exit:',INFO

          ENDIF
          
          CALL BLACS_GRIDEXIT(ICONTXT)
          CALL BLACS_EXIT(0)

          STOP

      END

!*******************************************************************************
!*    PRINT AN ERROR MESSAGE                                                   *
!*******************************************************************************

      SUBROUTINE PR_USAGE(IOUT)
          IMPLICIT NONE
          INTEGER :: IOUT
          WRITE(IOUT,*)'Incorrect parameter(s) found'
          WRITE(IOUT,*)
     &       ' Usage: pde77 methd prec dim [istopc itmax itrace]'
          WRITE(IOUT,*)' Where:'
          WRITE(IOUT,*)'     methd:  CGSTAB TFQMR CGS'
          WRITE(IOUT,*)'     prec :  ILU DIAGSC NONE'
          WRITE(IOUT,*)'     dim     number of points along each axis'
          WRITE(IOUT,*)'             the size of the resulting linear '
          WRITE(IOUT,*)'             system is dim**3'
          WRITE(IOUT,*)'     istopc  Stopping criterion 1 2 or 3  [1]  '
          WRITE(IOUT,*)'     itmax   Maximum number of iterations [500]'
          WRITE(IOUT,*)'     itrace       0  (no tracing, default) or '
          WRITE(IOUT,*)'                  >= 0 do tracing every ITRACE'
          WRITE(IOUT,*)'                  iterations ' 
          RETURN
      END

!*******************************************************************************
!*     FUNCTIONS PARAMETERIZING THE DIFFERENTIAL EQUATION                      *
!*******************************************************************************

      FUNCTION A1(X,Y,Z)
          REAL(KIND(1.D0)) :: A1
          REAL(KIND(1.D0)) :: X,Y,Z
          A1 = 1.D0
      END 

      FUNCTION A2(X,Y,Z)
          REAL(KIND(1.D0)) :: A2
          REAL(KIND(1.D0)) :: X,Y,Z
          A2 = 2.D1*Y
      END 

      FUNCTION A3(X,Y,Z)
          REAL(KIND(1.D0)) :: A3
          REAL(KIND(1.D0)) :: X,Y,Z      
          A3 = 1.D0
      END 

      FUNCTION A4(X,Y,Z)
          REAL(KIND(1.D0)) :: A4
          REAL(KIND(1.D0)) :: X,Y,Z      
          A4 = 1.D0
      END 

      FUNCTION B1(X,Y,Z)
          REAL(KIND(1.D0)) :: B1   
          REAL(KIND(1.D0)) :: X,Y,Z
          B1 = 1.D0
      END 

      FUNCTION B2(X,Y,Z)
          REAL(KIND(1.D0)) :: B2
          REAL(KIND(1.D0)) :: X,Y,Z
          B2 = 1.D0
      END 

      FUNCTION B3(X,Y,Z)
          REAL(KIND(1.D0)) :: B3
          REAL(KIND(1.D0)) :: X,Y,Z
          B3 = 1.D0
      END 

!*******************************************************************************
!* SUBROUTINE TO ALLOCATE AND FILL IN THE COEFFICIENT                          *
!* MATRIX AND THE RHS.                                                         *
!* THE EQUATION GENERATED IS:                                                  *
!*  b1  d d (u)  b2 d d (u)   b3 d d (u)  a1 d (u)) a2 d (u)))  a3d (u)) a4 u  *
!* -   -----   -    ------  -    ------ -    ----- -  ------  - ------ +       *
!*     dx dx        dy dy        dz dz        dx        dy        dz           *
!*                                                                             *
!* =g(x,y,z)                                                                   *
!*                                                                             *
!* WHERE G IS THE RHS EXTRACTED FROM EXACT SOLUTION:                           *
!*                                                                             *
!*  f(x,y,z)=10.d0*X*Y*Z*(1-X)*(1-Y)*(1-Z)*EXP(X**4.5)                         *
!*                                                                             *
!* BOUNDARY CONDITION: DIRICHLET                                               *
!*                                                                             *
!*    0< x,y,z<1                                                               *
!*                                                                             *
!* DISCRETIZED WITH FINITE DIFFERENCES; THE DISCRETE EQUATION IS               *
!*                                                                             *
!*  u(x,y,z)(2b1+2b2+2b3+a1+a2+a3)+u(x-1,y,z)(-b1-a1)+u(x,y-1,z)(-b2-a2)+      *
!*  + u(x,y,z-1)(-b3-a3)-u(x+1,y,z)b1-u(x,y+1,z)b2-u(x,y,z+1)b3                *
!*                                                                             *
!* THIS MATRIX IS NON SYMMETRIC                                                *
!*******************************************************************************

      SUBROUTINE CREATE_MTRX_ELL1_BLOCK(PARTS,IDIM,AS,IA1,IA2,INFOA,
     &                                  B,T,DESC_A,ICONTXT)

    
          USE F90SPARSE
          EXTERNAL PARTS

          IMPLICIT NONE

          REAL(KIND(1.D0)),POINTER   :: B(:), T(:), AS(:)
          REAL(KIND(1.D0)),POINTER   :: SOL(:)
          REAL(KIND(1.D0)),EXTERNAL  :: A1, A2, A3, B1, B2, B3
          REAL(KIND(1.D0))           :: ZT(10), RAS(20)
          REAL(KIND(1.D0))           :: GLOB_X, GLOB_Y, GLOB_Z, DELTAH

          INTEGER,         POINTER   :: DESC_A(:), IA1(:),IA2(:)
          INTEGER                    :: INFOA(20), PRV(64)
          INTEGER                    :: RIA1(20), RIA2(20), RINFOA(30)
          INTEGER                    :: INDX_OWNER, NV, INV
          INTEGER                    :: IDIM, ICONTXT
          INTEGER                    :: M, N, NNZ, GLOB_ROW, NR, J 
          INTEGER                    :: X, Y, Z, COUNTER, IA, I, NPROW
          INTEGER                    :: NPCOL, GAP, INFO
          INTEGER                    :: MYPROW, MYPCOL, DOMAIN_INDEX
          INTEGER                    :: BOUND_COND_0YZ, BOUND_COND_1YZ
          INTEGER                    :: BOUND_COND_X0Z, BOUND_COND_X1Z
          INTEGER                    :: BOUND_COND_XY0, BOUND_COND_XY1
          INTEGER                    :: MP, ELEMENT, LDSCA, IRCODE, NNZ1
    
          ! .... DELTAH DIMENSION OF EACH GRID CELL .... !
          ! .... DELTAT DISCRETIZATION TIME         .... !
    
          REAL(KIND(1.D0)),PARAMETER :: RHS=0.D0, ONE=1.D0, ZERO=0.D0
          REAL(KIND(1.D0))           :: TIMEF, T1, T2,T3, TINS
          EXTERNAL                      TIMEF

          ! .... COMMON AREA .... !

          INTEGER                       DIM_BLOCK, NPROC,NNZ2
          
          CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)
          
          NPROC  = NPROW*NPCOL
          DELTAH = 1.D0/MAX((IDIM-1),1)
          
          M   = IDIM*IDIM*IDIM
          N   = M
    
          LDSCA = 3*N+31+3*NPROC
    
          ALLOCATE(DESC_A(LDSCA),STAT=IRCODE)
          IF (IRCODE /= 0) THEN 
             WRITE(0,*) 'Allocation error in CREATE'
             CALL BLACS_ABORT(ICONTXT,-1)
             STOP
          ENDIF
    
          DESC_A(11) = LDSCA
    
          CALL PADINIT(N,PARTS,DESC_A,ICONTXT)
    
    
          DIM_BLOCK = (N+NPROC-1)/NPROC
          NNZ       = MAX(2,DIM_BLOCK*7)
          NNZ1      = MAX(3,NNZ+DIM_BLOCK)
          NNZ2      = MAX(3,NNZ+min(N,NNZ))
    
          ALLOCATE(AS(NNZ),IA1(NNZ1),IA2(NNZ2),STAT=IRCODE)
          IF (IRCODE /= 0) THEN 
             WRITE(0,*) 'Allocation error in CREATE'
             CALL BLACS_ABORT(ICONTXT,-1)
             STOP
          ENDIF
    
          INFOA(1) = NNZ
          INFOA(2) = NNZ1
          INFOA(3) = NNZ2
    
          NR = MAX(DESC_A(5),1)

          ALLOCATE(B(NR),T(NR),STAT=IRCODE)
          IF (IRCODE /= 0) THEN 
             WRITE(0,*) 'Allocation error in CREATE'
             CALL BLACS_ABORT(ICONTXT,-1)
             STOP
          ENDIF
          
          CALL PDSPINIT(AS,IA1,IA2,INFOA,DESC_A)
    
          ! .... WE BUILD AN AUXILIARY MATRIX CONSISTING OF ONE ROW AT A .... !
          ! .... TIME IN CSR MODE                                        .... !
    
          RINFOA(4) = 1
          RINFOA(5) = 1
          RINFOA(6) = 1
          RINFOA(7) = N
          
          GAP       = 1
          RIA2(1)   = 1
          TINS      = 0.D0
          
          CALL BLACS_BARRIER(ICONTXT,'ALL')
          T1 = TIMEF()
    
          ! .... LOOP OVER ALL ROWS WHICH BELONGS TO ME; .... !
          ! .... WE HAVE A BLOCK DISTRIBUTION            .... !
    
          DO GLOB_ROW = 1, N

              CALL PARTS(GLOB_ROW,N,NPROW,PRV,NV)

              DO INV = 1, NV

                  INDX_OWNER = PRV(INV)

                  IF (INDX_OWNER == MYPROW) THEN

                      ELEMENT=1
       
                      ! .... GLOB_X, GLOB_Y, GLOB_X COORDINATES IN .... !
                      ! .... CURRENT MEASURE UNIT COMPUTE          .... !
                      ! .... POINT COORDINATES                     .... !

                      IF(MOD(GLOB_ROW,(IDIM*IDIM)).EQ.0) THEN
                          X = GLOB_ROW/(IDIM*IDIM)
                      ELSE
                          X = GLOB_ROW/(IDIM*IDIM)+1
                      ENDIF

                      IF(MOD((GLOB_ROW-(X-1)*IDIM*IDIM),IDIM).EQ.0) THEN
                          Y = (GLOB_ROW-(X-1)*IDIM*IDIM)/IDIM
                      ELSE
                          Y = (GLOB_ROW-(X-1)*IDIM*IDIM)/IDIM+1
                      ENDIF
       
                      Z = GLOB_ROW-(X-1)*IDIM*IDIM-(Y-1)*IDIM
       
                      GLOB_X=X*DELTAH
                      GLOB_Y=Y*DELTAH
                      GLOB_Z=Z*DELTAH
       
                      IF(X.EQ.1) THEN
                          RAS(ELEMENT)=ONE
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
                      ELSEIF (Y.EQ.1) THEN
                          RAS(ELEMENT)=ONE
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
                      ELSEIF (Z.EQ.1) THEN
                          RAS(ELEMENT)=ONE
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
                      ELSEIF (X.EQ.IDIM) THEN
                          RAS(ELEMENT)=ONE
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
                      ELSEIF (Y.EQ.IDIM) THEN
                          RAS(ELEMENT)=ONE
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
                      ELSEIF (Z.EQ.IDIM) THEN
                          RAS(ELEMENT)=ONE
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
                      ELSE
                          ! .... INTERNAL POINT .... !

                          ! .... (x-1,y,z) .... !
       
                          RAS(ELEMENT)=-B1(GLOB_X,GLOB_Y,GLOB_Z)
     &                      -A1(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X-2)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
       
                          ! .... (x,y-1,z) .... !
       
                          RAS(ELEMENT)=-B2(GLOB_X,GLOB_Y,GLOB_Z)
     &                      -A2(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-2)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
       
                          ! .... (x,y,z-1) .... !
       
                          RAS(ELEMENT)=-B3(GLOB_X,GLOB_Y,GLOB_Z)
     &                       -A3(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z-1)
                          ELEMENT=ELEMENT+1
       
                          ! .... (x,y,z) .... !
       
                          RAS(ELEMENT)=2*B1(GLOB_X,GLOB_Y,GLOB_Z)
     &                      +2*B2(GLOB_X,GLOB_Y,GLOB_Z)
     &                      +2*B3(GLOB_X,GLOB_Y,GLOB_Z)
     &                      +A1(GLOB_X,GLOB_Y,GLOB_Z)
     &                      +A2(GLOB_X,GLOB_Y,GLOB_Z)
     &                      +A3(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1                  
       
                          ! .... (x,y,z+1) .... !
       
                          RAS(ELEMENT)=-B1(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z+1)
                          ELEMENT=ELEMENT+1
       
                          ! .... (x,y+1,z) .... !
       
                          RAS(ELEMENT)=-B2(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y)*IDIM+(Z)
                          ELEMENT=ELEMENT+1
       
                          ! .... (x+1,y,z) .... !
       
                          RAS(ELEMENT)=-B3(GLOB_X,GLOB_Y,GLOB_Z)
                          RAS(ELEMENT) = RAS(ELEMENT)/(DELTAH*DELTAH)
                          RIA1(ELEMENT)=(X)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                          ELEMENT=ELEMENT+1

                      ENDIF
    
                      RIA2(2)   = ELEMENT
                      RINFOA(1) = 20
                      RINFOA(2) = 20
                      RINFOA(3) = 20
                      RINFOA(4) = 1
                      RINFOA(5) = 1
                      RINFOA(6) = 1
    
                      ! .... IA== GLOBAL ROW INDEX .... !
    
                      IA=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                      T3 = TIMEF()
    
                      CALL PDSPINS(AS,IA1,IA2,INFOA,DESC_A,IA,1,RAS,
     &                                             RIA1,RIA2,RINFOA)
    
                      TINS = TINS + (TIMEF()-T3)
    
                      ! .... BUILD RHS .... !
    
                      IF (X==1) THEN  
                          GLOB_Y=(Y-IDIM/2)*DELTAH
                          GLOB_Z=(Z-IDIM/2)*DELTAH  
                          ZT(1) = EXP(-GLOB_Y**2-GLOB_Z**2)
                      ELSEIF ((Y==1).OR.(Y==IDIM).OR.(Z==1)
     &                                           .OR.(Z==IDIM)) THEN
                          GLOB_X=3*(X-1)*DELTAH
                          GLOB_Y=(Y-IDIM/2)*DELTAH
                          GLOB_Z=(Z-IDIM/2)*DELTAH  
                          ZT(1) = EXP(-GLOB_Y**2-GLOB_Z**2)*EXP(-GLOB_X)
                      ELSE
                          ZT(1) = 0.D0
                      ENDIF
    
                      CALL PDGEINS(1,B,NR,IA,1,1,1,ZT,1,DESC_A)
    
                      ZT(1) = 0.D0
    
                      CALL PDGEINS(1,T,NR,IA,1,1,1,ZT,1,DESC_A)
    
                  ENDIF
              ENDDO
          ENDDO
          
          CALL BLACS_BARRIER(ICONTXT,'ALL')    

          T2 = TIMEF()
          
          IF (MYPROW.EQ.0) THEN
              WRITE(0,*) '     pspins  time',TINS/1.D3
              WRITE(0,*) '   Insert time',(T2-T1)/1.D3
          ENDIF
          
          CALL BLACS_BARRIER(ICONTXT,'ALL')    

          T1 = TIMEF()
          
          CALL PDSPASB(AS,IA1,IA2,INFOA,DESC_A,'GEN  ','DEF  ',0,INFO)
          
          CALL BLACS_BARRIER(ICONTXT,'ALL')

          T2 = TIMEF()
          
          IF (MYPROW.EQ.0) THEN
              WRITE(0,*) '   Assembly  time',(T2-T1)/1.D3
          ENDIF
          
          CALL PDGEASB(1,B,NR,DESC_A)
          CALL PDGEASB(1,T,NR,DESC_A)

          RETURN
      END       

!*******************************************************************************
!*    GET ITERATION PARAMETERS FROM THE COMMAND LINE                           *
!*******************************************************************************

      SUBROUTINE GET_PARMS(ICONTXT,CMETHD,PREC,IDIM,ISTOPC,ITMAX,ITRACE)
          IMPLICIT NONE
          INTEGER      :: ICONTXT, IDIM, ISTOPC, ITMAX, ITRACE
          CHARACTER*10 :: CMETHD, PREC

          INTEGER      :: INTBUF(10)
          INTEGER      :: IRET, NPROW, NPCOL, MYPROW, MYPCOL, IP, I, NP
          INTEGER      :: IARGC
          EXTERNAL        IARGC

          CHARACTER*40 :: CHARBUF
          
          CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)
          NP = NPROW * NPCOL
          
          IF (MYPROW==0) THEN
    
              ! .... READ COMMAND LINE PARAMETERS .... !
     
              IP = IARGC()
     
              IF (IARGC().GE.3) THEN
     
                  CALL GETARG(1,CHARBUF)
                  READ(CHARBUF,*) CMETHD
     
                  CALL GETARG(2,CHARBUF)
                  READ(CHARBUF,*) PREC
                 
                  ! .... CONVERT STRINGS IN ARRAY .... !
     
                  DO I = 1, LEN(CMETHD)
                      INTBUF(I) = IACHAR(CMETHD(I:I))
                  ENDDO
     
                  ! .... BROADCAST PARAMETERS TO ALL PROCESSORS .... !
     
                  CALL IGEBS2D(ICONTXT,'ALL',' ',10,1,INTBUF,10)
                 
                  DO I = 1, LEN(PREC)
                      INTBUF(I) = IACHAR(PREC(I:I))
                  ENDDO
     
                  ! .... BROADCAST PARAMETERS TO ALL PROCESSORS .... !
     
                  CALL IGEBS2D(ICONTXT,'ALL',' ',10,1,INTBUF,10)
                 
                  CALL GETARG(3,CHARBUF)
                  READ(CHARBUF,*) IDIM
     
                  IF (IARGC().GE.4) THEN
                      CALL GETARG(4,CHARBUF)
                      READ(CHARBUF,*) ISTOPC
                  ELSE
                      ISTOPC=1        
                  ENDIF
     
                  IF (IARGC().GE.5) THEN
                      CALL GETARG(5,CHARBUF)
                      READ(CHARBUF,*) ITMAX
                  ELSE
                      ITMAX=500
                  ENDIF
     
                  IF (IARGC().GE.6) THEN
                      CALL GETARG(6,CHARBUF)
                      READ(CHARBUF,*) ITRACE
                  ELSE
                      ITRACE=0
                  ENDIF
     
                  ! .... BROADCAST PARAMETERS TO ALL PROCESSORS .... !
     
                  CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,IDIM,  1)
                  CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,ISTOPC,1)
                  CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,ITMAX, 1)
                  CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,ITRACE,1)

                  WRITE(6,*)'Solving matrix: ELL1'      
                  WRITE(6,*)'on  grid',IDIM,'x',IDIM,'x',IDIM 
                  WRITE(6,*)' with BLOCK data distribution, NP=',NP,
     &                     ' Preconditioner=',PREC,
     &                     ' Iterative methd=',CMETHD
              ELSE
     
                  ! .... WRONG NUMBER OF PARAMETER, PRINT AN .... !
                  ! .... ERROR MESSAGE AND EXIT              .... !
     
                  CALL PR_USAGE(0)      
                  CALL BLACS_ABORT(ICONTXT,-1)
 
                  STOP 1
 
              ENDIF

          ELSE
     
              ! .... RECEIVE PARAMETERS .... !
     
              CALL IGEBR2D(ICONTXT,'ALL',' ',10,1,INTBUF,10,0,0)

              DO I = 1, 10
                  CMETHD(I:I) = ACHAR(INTBUF(I))
              ENDDO

              CALL IGEBR2D(ICONTXT,'ALL',' ',10,1,INTBUF,10,0,0)

              DO I = 1, 10
                  PREC(I:I) = ACHAR(INTBUF(I))
              ENDDO

              CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,IDIM,  1,0,0)
              CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,ISTOPC,1,0,0)
              CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,ITMAX, 1,0,0)
              CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,ITRACE,1,0,0)

          ENDIF

          RETURN
       
      END
