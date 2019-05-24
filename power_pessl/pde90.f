@process free(f90) init(f90ptr) nosave
!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-C41                                                         *
!    5765-G18                                                         *
!    (C) COPYRIGHT IBM CORP. 1997, 2003. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
!
! This sample program shows how to build and solve a sparse linear
! system using the subroutines in the  sparse section of Parallel
! ESSL. The matrix and RHS are generated
! in  parallel, so that there is no serial bottleneck. 
!
! The program  solves a linear system based on the partial differential
! equation 
!
! 
!   b1 dd(u)  b2 dd(u)    b3 dd(u)    a1 d(u)   a2 d(u)  a3 d(u)  
! -   ------ -  ------ -  ------ -  -----  -  ------  -  ------ + a4 u 
!      dxdx     dydy       dzdz        dx       dy         dz   
!
!  = 0 
! 
! with  Dirichlet boundary conditions on the unit cube 
!
!    0<=x,y,z<=1
! 
! The equation is discretized with finite differences and uniform stepsize;
! the resulting  discrete  equation is
!
! ( u(x,y,z)(2b1+2b2+2b3+a1+a2+a3)+u(x-1,y,z)(-b1-a1)+u(x,y-1,z)(-b2-a2)+
!  + u(x,y,z-1)(-b3-a3)-u(x+1,y,z)b1-u(x,y+1,z)b2-u(x,y,z+1)b3)*(1/h**2)
!
!
! In this sample program the index space of the discretized
! computational domain is first numbered sequentially in a standard way, 
! then the corresponding vector is distributed according to an HPF BLOCK
! distribution directive.
!
! Boundary conditions are set in a very simple way, by adding 
! equations of the form
!
!   u(x,y,z) = rhs(x,y,z)
!
Program PDE90
  USE F90SPARSE
  Implicit none

  INTERFACE PART_BLOCK
     !   .....user defined subroutine.....
     SUBROUTINE PART_BLOCK(GLOBAL_INDX,N,NP,PV,NV)
       IMPLICIT NONE     
       INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, NP
       INTEGER, INTENT(OUT) :: NV
       INTEGER, INTENT(OUT) :: PV(*)       
     END SUBROUTINE PART_BLOCK
  END INTERFACE

  ! Input parameters
  Character*10 :: CMETHD, PREC
  Integer      :: IDIM, IRET

  ! Miscellaneous 
  Integer, Parameter   :: IZERO=0, IONE=1
  Character, PARAMETER :: ORDER='R'
  INTEGER              :: IARGC
  REAL(KIND(1.D0)), PARAMETER :: DZERO = 0.D0, ONE = 1.D0
  REAL(KIND(1.D0)) :: TIMEF, T1, T2, TPREC, TSOLVE, T3, T4 
  EXTERNAL  TIMEF

  ! Sparse Matrix and preconditioner
  TYPE(D_SPMAT) :: A
  TYPE(D_PRECN) :: APRC
  ! Descriptor
  TYPE(DESC_TYPE)    :: DESC_A
  ! Dense Matrices
  REAL(KIND(1.d0)), POINTER :: B(:), X(:)

  ! BLACS parameters
  INTEGER            :: nprow, npcol, icontxt, iam, np, myprow, mypcol
  
  ! Solver parameters
  INTEGER            :: ITER, ITMAX,IERR,ITRACE, METHD,IPREC, ISTOPC,&
       & IPARM(20) 
  REAL(KIND(1.D0))   :: ERR, EPS, RPARM(20)
   
  ! Other variables
  INTEGER            :: I,INFO
  INTEGER            :: INTERNAL, M,II
 
  ! Initialize BLACS  
  CALL BLACS_PINFO(IAM, NP)
  CALL BLACS_GET(IZERO, IZERO, ICONTXT)

  ! Rectangular Grid,  P x 1

  CALL BLACS_GRIDINIT(ICONTXT, ORDER, NP, IONE)
  CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)

  !
  !  Get parameters
  !
  CALL GET_PARMS(ICONTXT,CMETHD,PREC,IDIM,ISTOPC,ITMAX,ITRACE)
  
  !
  !  Allocate and fill in the coefficient matrix, RHS and initial guess 
  !

  CALL BLACS_BARRIER(ICONTXT,'All')
  T1 = TIMEF()
  CALL CREATE_MATRIX(PART_BLOCK,IDIM,A,B,X,DESC_A,ICONTXT)  
  T2 = TIMEF() - T1
   
  CALL DGAMX2D(ICONTXT,'A',' ',IONE, IONE,T2,IONE,T1,T1,-1,-1,-1)
  IF (IAM.EQ.0) Write(6,*) 'Matrix creation Time : ',T2/1.D3

  !
  !  Prepare the preconditioner.
  !  
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
  CALL PSPGPR(IPREC,A,APRC,DESC_A,INFO=IRET)
  TPREC = TIMEF()-T1
  
  CALL DGAMX2D(icontxt,'A',' ',IONE, IONE,TPREC,IONE,t1,t1,-1,-1,-1)
  
  IF (IAM.EQ.0) WRITE(6,*) 'Preconditioner Time : ',TPREC/1.D3

  IF (IRET.NE.0) THEN
     WRITE(0,*) 'Error on preconditioner',IRET
     CALL BLACS_ABORT(ICONTXT,-1)
     STOP
  END IF
 
  !
  ! Iterative method parameters 
  !
  IF (CMETHD(1:6).EQ.'CGSTAB') Then
     METHD = 1    
  ELSE IF (CMETHD(1:3).EQ.'CGS') Then
     METHD = 2
  ELSE IF (CMETHD(1:5).EQ.'TFQMR') THEN
     METHD = 3
  ELSE
     WRITE(0,*) 'Unknown method '
     CALL BLACS_ABORT(ICONTXT,-1)
     METHD = 0
  END IF
  EPS   = 1.D-9
  IPARM = 0
  RPARM = 0.D0
  IPARM(1) = METHD
  IPARM(2) = ISTOPC
  IPARM(3) = ITMAX
  IPARM(4) = ITRACE
  RPARM(1) = EPS
  CALL BLACS_BARRIER(ICONTXT,'All')
  T1 = TIMEF()  
  CALL PSPGIS(A,B,X,APRC,DESC_A,&
       & IPARM=IPARM,RPARM=RPARM,INFO=IERR) 
  CALL BLACS_BARRIER(ICONTXT,'All')
  T2 = TIMEF() - T1
  ITER = IPARM(5)
  ERR  = RPARM(2)
  CALL DGAMX2D(ICONTXT,'A',' ',IONE, IONE,T2,IONE,T1,T1,-1,-1,-1)

  IF (IAM.EQ.0) THEN
     WRITE(6,*) 'Time to Solve Matrix : ',T2/1.D3 
     WRITE(6,*) 'Time per iteration : ',T2/(ITER*1.D3)
     WRITE(6,*) 'Number of iterations : ',ITER
     WRITE(6,*) 'Error on exit : ',ERR
     WRITE(6,*) 'INFO  on exit : ',IERR
  END IF

  !  
  !  Cleanup storage and exit
  !
  CALL PGEFREE(B,DESC_A)
  CALL PGEFREE(X,DESC_A)

  CALL PSPFREE(APRC,DESC_A)  
  CALL PSPFREE(A,DESC_A)
  
  CALL PADFREE(DESC_A)
  
  CALL BLACS_GRIDEXIT(ICONTXT)
  CALL BLACS_EXIT(0)
  
  STOP
  
CONTAINS
  !
  !  Subroutine to allocate and fill in the coefficient matrix and
  !  the RHS. 
  !
  SUBROUTINE CREATE_MATRIX(PARTS,IDIM,A,B,T,DESC_A,ICONTXT)
!
!   Discretize the partial diferential equation
! 
!   b1 dd(u)  b2 dd(u)    b3 dd(u)    a1 d(u)   a2 d(u)  a3 d(u)  
! -   ------ -  ------ -  ------ -  -----  -  ------  -  ------ + a4 u 
!      dxdx     dydy       dzdz        dx       dy         dz   
!
!  = 0 
! 
! boundary condition: Dirichlet
!    0< x,y,z<1
!  
!  u(x,y,z)(2b1+2b2+2b3+a1+a2+a3)+u(x-1,y,z)(-b1-a1)+u(x,y-1,z)(-b2-a2)+
!  + u(x,y,z-1)(-b3-a3)-u(x+1,y,z)b1-u(x,y+1,z)b2-u(x,y,z+1)b3
    USE F90SPARSE
    Implicit None
    INTEGER                  :: IDIM
    INTERFACE PARTS
       SUBROUTINE PARTS(GLOBAL_INDX,N,P,PV,NV)
         IMPLICIT NONE
         INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, P
         INTEGER, INTENT(OUT) :: NV
         INTEGER, INTENT(OUT) :: PV(*)
         
       END SUBROUTINE PARTS
    END INTERFACE
    Real(Kind(1.D0)),Pointer :: B(:),T(:)
    Type (DESC_TYPE)         :: DESC_A
    Integer                  :: ICONTXT
    Type(D_SPMAT)            :: A
    Real(Kind(1.d0))         :: ZT(10),GLOB_X,GLOB_Y,GLOB_Z
    Integer                  :: M,N,NNZ,GLOB_ROW,J
    Type (D_SPMAT)           :: ROW_MAT
    Integer                  :: X,Y,Z,COUNTER,IA,I,INDX_OWNER
    INTEGER                  :: NPROW,NPCOL,MYPROW,MYPCOL
    Integer                  :: ELEMENT
    INTEGER                  :: INFO, NV, INV
    INTEGER, ALLOCATABLE     :: PRV(:)
    ! deltah dimension of each grid cell
    ! deltat discretization time
    Real(Kind(1.D0))         :: DELTAH
    Real(Kind(1.d0)),Parameter   :: RHS=0.d0,ONE=1.d0,ZERO=0.d0
    Real(Kind(1.d0))   :: TIMEF, T1, T2, TINS
    external            timef
    ! common area


    CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)

    DELTAH = 1.D0/(IDIM-1)

    ! Initialize array descriptor and sparse matrix storage. Provide an
    ! estimate of the number of non zeroes 

    M   = IDIM*IDIM*IDIM
    N   = M
    NNZ = (N*7)/(NPROW*NPCOL)
    Call PADALL(N,PARTS,DESC_A,ICONTXT)
    Call PSPALL(A,DESC_A,NNZ=NNZ)
    ! Define  RHS from boundary conditions; also build initial guess 
    Call PGEALL(B,DESC_A)
    Call PGEALL(T,DESC_A)
    
    ! We build an auxiliary matrix consisting of one row at a
    ! time
    ROW_MAT%DESCRA(1:1) = 'G'
    ROW_MAT%FIDA        = 'CSR'
    ALLOCATE(ROW_MAT%AS(20))
    ALLOCATE(ROW_MAT%IA1(20))
    ALLOCATE(ROW_MAT%IA2(20))
    ALLOCATE(PRV(NPROW))
    ROW_MAT%IA2(1)=1    

    TINS = 0.D0
    CALL BLACS_BARRIER(ICONTXT,'ALL')
    T1 = TIMEF()

    ! Loop over rows belonging to current process in a BLOCK
    ! distribution.

    DO GLOB_ROW = 1, N
       CALL PARTS(GLOB_ROW,N,NPROW,PRV,NV)
       DO INV = 1, NV
          INDX_OWNER = PRV(INV)
          IF (INDX_OWNER == MYPROW) THEN
             ! Local matrix pointer 
             ELEMENT=1
             ! Compute gridpoint Coordinates
             IF (MOD(GLOB_ROW,(IDIM*IDIM)).EQ.0) THEN
                X = GLOB_ROW/(IDIM*IDIM)
             ELSE
                X = GLOB_ROW/(IDIM*IDIM)+1
             ENDIF
             IF (MOD((GLOB_ROW-(X-1)*IDIM*IDIM),IDIM).EQ.0) THEN
                Y = (GLOB_ROW-(X-1)*IDIM*IDIM)/IDIM
             ELSE
                Y = (GLOB_ROW-(X-1)*IDIM*IDIM)/IDIM+1
             ENDIF
             Z = GLOB_ROW-(X-1)*IDIM*IDIM-(Y-1)*IDIM
	     ! GLOB_X, GLOB_Y, GLOB_X coordinates
	     GLOB_X=X*DELTAH
	     GLOB_Y=Y*DELTAH
	     GLOB_Z=Z*DELTAH
             
             ! Check on boundary points 
             IF (X.EQ.1) THEN
                ROW_MAT%AS(ELEMENT)=ONE
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ELSE IF (Y.EQ.1) THEN
                ROW_MAT%AS(ELEMENT)=ONE
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ELSE IF (Z.EQ.1) THEN
                ROW_MAT%AS(ELEMENT)=ONE
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ELSE IF (X.EQ.IDIM) THEN
                ROW_MAT%AS(ELEMENT)=ONE
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ELSE IF (Y.EQ.IDIM) THEN
                ROW_MAT%AS(ELEMENT)=ONE
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ELSE IF (Z.EQ.IDIM) THEN
                ROW_MAT%AS(ELEMENT)=ONE
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ELSE
                ! Internal point: build discretization
                !   
                !  Term depending on   (x-1,y,z)
                !
                ROW_MAT%AS(ELEMENT)=-B1(GLOB_X,GLOB_Y,GLOB_Z)&
                     & -A1(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X-2)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
                !  Term depending on     (x,y-1,z)
                ROW_MAT%AS(ELEMENT)=-B2(GLOB_X,GLOB_Y,GLOB_Z)&
                     & -A2(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-2)*IDIM+(Z)
                ELEMENT=ELEMENT+1
                !  Term depending on     (x,y,z-1)
                ROW_MAT%AS(ELEMENT)=-B3(GLOB_X,GLOB_Y,GLOB_Z)&
                     & -A3(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z-1)
                ELEMENT=ELEMENT+1
                !  Term depending on     (x,y,z)
                ROW_MAT%AS(ELEMENT)=2*B1(GLOB_X,GLOB_Y,GLOB_Z)&
                     & +2*B2(GLOB_X,GLOB_Y,GLOB_Z)&
                     & +2*B3(GLOB_X,GLOB_Y,GLOB_Z)&
                     & +A1(GLOB_X,GLOB_Y,GLOB_Z)&
                     & +A2(GLOB_X,GLOB_Y,GLOB_Z)&
                     & +A3(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1                  
                !  Term depending on     (x,y,z+1)
                ROW_MAT%AS(ELEMENT)=-B1(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z+1)
                ELEMENT=ELEMENT+1
                !  Term depending on     (x,y+1,z)
                ROW_MAT%AS(ELEMENT)=-B2(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X-1)*IDIM*IDIM+(Y)*IDIM+(Z)
                ELEMENT=ELEMENT+1
                !  Term depending on     (x+1,y,z)
                ROW_MAT%AS(ELEMENT)=-B3(GLOB_X,GLOB_Y,GLOB_Z)
                ROW_MAT%AS(ELEMENT) = ROW_MAT%AS(ELEMENT)/(DELTAH*&
                     & DELTAH)
                ROW_MAT%IA1(ELEMENT)=(X)*IDIM*IDIM+(Y-1)*IDIM+(Z)
                ELEMENT=ELEMENT+1
             ENDIF
             ROW_MAT%M=1
             ROW_MAT%N=N
             ROW_MAT%IA2(2)=ELEMENT       
             ! IA== GLOBAL ROW INDEX
             IA=(X-1)*IDIM*IDIM+(Y-1)*IDIM+(Z)
             T3 = TIMEF()
             CALL PSPINS(A,IA,1,ROW_MAT,DESC_A)       
             TINS = TINS + (TIMEF()-T3)
	     ! Build RHS  
             IF (X==1) THEN     
                GLOB_Y=(Y-IDIM/2)*DELTAH
                GLOB_Z=(Z-IDIM/2)*DELTAH        
                ZT(1) = EXP(-GLOB_Y**2-GLOB_Z**2)
             ELSE IF ((Y==1).OR.(Y==IDIM).OR.(Z==1).OR.(Z==IDIM)) THEN 
                GLOB_X=3*(X-1)*DELTAH
                GLOB_Y=(Y-IDIM/2)*DELTAH
                GLOB_Z=(Z-IDIM/2)*DELTAH        
                ZT(1) = EXP(-GLOB_Y**2-GLOB_Z**2)*EXP(-GLOB_X)
             ELSE
                ZT(1) = 0.D0
             ENDIF
             CALL PGEINS(B,ZT(1:1),DESC_A,IA)
             ZT(1)=0.D0
             CALL PGEINS(T,ZT(1:1),DESC_A,IA)       	    
          END IF
       END DO 
    END DO
    
    CALL BLACS_BARRIER(ICONTXT,'ALL')    
    T2 = TIMEF()
    
    IF (MYPROW.EQ.0) THEN
       WRITE(0,*) '     pspins  time',TINS/1.D3
       WRITE(0,*) '   Insert time',(T2-T1)/1.D3
    ENDIF

    DEALLOCATE(ROW_MAT%AS,ROW_MAT%IA1,ROW_MAT%IA2)
    

    CALL BLACS_BARRIER(ICONTXT,'ALL')    
    T1 = TIMEF()
    
    CALL PSPASB(A,DESC_A,INFO=INFO,DUPFLAG=0,MTYPE='GEN  ') 
    
    CALL BLACS_BARRIER(ICONTXT,'ALL')
    T2 = TIMEF()
    
    IF (MYPROW.EQ.0) THEN
       WRITE(0,*) '   Assembly  time',(T2-T1)/1.D3
    ENDIF
    
    CALL PGEASB(B,DESC_A)    
    CALL PGEASB(T,DESC_A)
    RETURN
  END SUBROUTINE CREATE_MATRIX
  !
  ! Functions parameterizing the differential equation 
  !  
  FUNCTION A1(X,Y,Z)
    REAL(KIND(1.D0)) :: A1
    REAL(KIND(1.D0)) :: X,Y,Z
    A1=1.D0
  END FUNCTION A1
  FUNCTION A2(X,Y,Z)
    REAL(KIND(1.D0)) ::  A2
    REAL(KIND(1.D0)) :: X,Y,Z
    A2=2.D1*Y
  END FUNCTION A2
  FUNCTION A3(X,Y,Z)
    REAL(KIND(1.D0)) ::  A3
    REAL(KIND(1.D0)) :: X,Y,Z      
    A3=1.D0
  END FUNCTION A3
  FUNCTION A4(X,Y,Z)
    REAL(KIND(1.D0)) ::  A4
    REAL(KIND(1.D0)) :: X,Y,Z      
    A4=1.D0
  END FUNCTION A4
  FUNCTION B1(X,Y,Z)
    REAL(KIND(1.D0)) ::  B1   
    REAL(KIND(1.D0)) :: X,Y,Z
    B1=1.D0
  END FUNCTION B1
  FUNCTION B2(X,Y,Z)
    REAL(KIND(1.D0)) ::  B2
    REAL(KIND(1.D0)) :: X,Y,Z
    B2=1.D0
  END FUNCTION B2
  FUNCTION B3(X,Y,Z)
    REAL(KIND(1.D0)) ::  B3
    REAL(KIND(1.D0)) :: X,Y,Z
    B3=1.D0
  END FUNCTION B3    
  !
  ! Get iteration parameters from the command line
  !
  SUBROUTINE  GET_PARMS(ICONTXT,CMETHD,PREC,IDIM,ISTOPC,ITMAX,ITRACE)
    IMPLICIT NONE     
    integer      :: icontxt
    Character*10 :: CMETHD, PREC
    Integer      :: IDIM, IRET, ISTOPC,ITMAX,ITRACE
    Character*40 :: CHARBUF
    INTEGER      :: IARGC, NPROW, NPCOL, MYPROW, MYPCOL
    EXTERNAL     IARGC
    INTEGER      :: INTBUF(10), IP
    
    CALL BLACS_GRIDINFO(ICONTXT, NPROW, NPCOL, MYPROW, MYPCOL)

    IF (MYPROW==0) THEN
       ! Read command line parameters 
       IP=IARGC()
       IF (IARGC().GE.3) THEN
          CALL GETARG(1,CHARBUF)
          READ(CHARBUF,*) CMETHD
          CALL GETARG(2,CHARBUF)
          READ(CHARBUF,*) PREC
         
        ! Convert strings in array
          DO I = 1, LEN(CMETHD)
             INTBUF(I) = IACHAR(CMETHD(I:I))
          END DO
        ! Broadcast parameters to all processors
          CALL IGEBS2D(ICONTXT,'ALL',' ',10,1,INTBUF,10)
        
          DO I = 1, LEN(PREC)
             INTBUF(I) = IACHAR(PREC(I:I))
          END DO
        ! Broadcast parameters to all processors
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
        ! Broadcast parameters to all processors      
          CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,IDIM,1)
          CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,ISTOPC,1)
          CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,ITMAX,1)
          CALL IGEBS2D(ICONTXT,'ALL',' ',1,1,ITRACE,1)
          WRITE(6,*)'Solving matrix: ELL1'      
          WRITE(6,*)'on  grid',IDIM,'x',IDIM,'x',IDIM
          WRITE(6,*)' with BLOCK data distribution, NP=',Np,&
               & ' Preconditioner=',PREC,&
               & ' Iterative methd=',CMETHD      
       ELSE
        ! Wrong number of parameter, print an error message and exit
          CALL PR_USAGE(0)      
          CALL BLACS_ABORT(ICONTXT,-1)
          STOP 1
       ENDIF
    ELSE
   ! Receive Parameters
       CALL IGEBR2D(ICONTXT,'ALL',' ',10,1,INTBUF,10,0,0)
       DO I = 1, 10
          CMETHD(I:I) = ACHAR(INTBUF(I))
       END DO
       CALL IGEBR2D(ICONTXT,'ALL',' ',10,1,INTBUF,10,0,0)
       DO I = 1, 10
          PREC(I:I) = ACHAR(INTBUF(I))
       END DO
       CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,IDIM,1,0,0)
       CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,ISTOPC,1,0,0)
       CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,ITMAX,1,0,0)
       CALL IGEBR2D(ICONTXT,'ALL',' ',1,1,ITRACE,1,0,0)
    END IF
    RETURN
    
  END SUBROUTINE GET_PARMS
  !
  !  Print an error message 
  !  
  SUBROUTINE PR_USAGE(IOUT)
    IMPLICIT NONE     
    INTEGER :: IOUT
    WRITE(IOUT,*)'Incorrect parameter(s) found'
    WRITE(IOUT,*)' Usage:  pde90 methd prec dim &
         &[istop itmax itrace]'  
    WRITE(IOUT,*)' Where:'
    WRITE(IOUT,*)'     methd:    CGSTAB TFQMR CGS' 
    WRITE(IOUT,*)'     prec :    ILU DIAGSC NONE'
    WRITE(IOUT,*)'     dim       number of points along each axis'
    WRITE(IOUT,*)'               the size of the resulting linear '
    WRITE(IOUT,*)'               system is dim**3'
    WRITE(IOUT,*)'     istop     Stopping criterion  1, 2 or 3 [1]  '
    WRITE(IOUT,*)'     itmax     Maximum number of iterations [500] '
    WRITE(IOUT,*)'     itrace    0  (no tracing, default) or '  
    WRITE(IOUT,*)'               >= 0 do tracing every ITRACE'
    WRITE(IOUT,*)'               iterations ' 
  END SUBROUTINE PR_USAGE

END PROGRAM PDE90

