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
!
! Purpose: 
!  Provide a set of subroutines to define a data distribution based on 
!  a random number generator.
!  This partition does *not* generally give good performance; it may be
!  useful as a model to implement a graph partitioning based
!  distribution; to do this you need to alter the BUILD_RNDPART
!  subroutine to make it call your favorite graph partition subroutine
!  instead of the random number generator. 
! 
!  Subroutines:
!  
!  BUILD_RNDPART(A,NPARTS): This subroutine will be called by the root
!    process to build define the data distribution mapping. 
!      Input parameters:
!        TYPE(D_SPMAT) :: A   The input matrix. The coefficients are
!                             ignored; only the structure is used.
!        INTEGER       :: NPARTS  How many parts we are requiring to the 
!                                 partition utility
!
! 
!  DISTR_RNDPART(RROOT,CROOT,ICTXT): This subroutine will be called by
!      all processes to distribute the information computed by the root
!      process, to be used subsequently.
!
!
!  PART_RAND : The subroutine to be passed to PESSL sparse library;
!      uses information prepared by the previous two subroutines.
!
MODULE PARTRAND
  PUBLIC PART_RAND, BUILD_RNDPART, DISTR_RNDPART
  PRIVATE 
  INTEGER, POINTER, SAVE :: RAND_VECT(:)
  
CONTAINS
  
  SUBROUTINE PART_RAND(GLOBAL_INDX,N,NP,PV,NV)
    
    INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, NP
    INTEGER, INTENT(OUT) :: NV
    INTEGER, INTENT(OUT) :: PV(*)
    
    IF (.NOT.ASSOCIATED(RAND_VECT)) THEN
       WRITE(0,*) 'Fatal error in PART_RAND: vector RAND_VECT ',&
	    & 'not initialized'
       RETURN
    ENDIF
    IF ((GLOBAL_INDX<1).OR.(GLOBAL_INDX > SIZE(RAND_VECT))) THEN       
       WRITE(0,*) 'Fatal error in PART_RAND: index GLOBAL_INDX ',&
	    & 'outside RAND_VECT bounds'
       RETURN
    ENDIF
    NV = 1
    PV(NV) = RAND_VECT(GLOBAL_INDX)
    RETURN
  END SUBROUTINE PART_RAND


  SUBROUTINE DISTR_RNDPART(RROOT, CROOT, ICTXT)
    INTEGER    :: RROOT, CROOT, ICTXT
    INTEGER    :: N, MER, MEC, NPR, NPC
    
    CALL BLACS_GRIDINFO(ICTXT,NPR,NPC,MER,MEC)
    
    IF (.NOT.((RROOT>=0).AND.(RROOT<NPR).AND.&
	 & (CROOT>=0).AND.(CROOT<NPC))) THEN 
       WRITE(0,*) 'Fatal error in DISTR_RNDPART: invalid ROOT  ',&
	    & 'coordinates '
       CALL BLACS_ABORT(ICTXT,-1)
       RETURN
    ENDIF

    IF ((MER == RROOT) .AND.(MEC == CROOT)) THEN 
       IF (.NOT.ASSOCIATED(RAND_VECT)) THEN
	  WRITE(0,*) 'Fatal error in DISTR_RNDPART: vector RAND_VECT ',&
	       & 'not initialized'
	  CALL BLACS_ABORT(ICTXT,-1)
	  RETURN
       ENDIF
       N = SIZE(RAND_VECT)
       CALL IGEBS2D(ICTXT,'All',' ',1,1,N,1)
       CALL IGEBS2D(ICTXT,'All',' ',N,1,RAND_VECT,N)
    ELSE 
       CALL IGEBR2D(ICTXT,'All',' ',1,1,N,1,RROOT,CROOT)
       IF (ASSOCIATED(RAND_VECT)) THEN
	  DEALLOCATE(RAND_VECT)
       ENDIF
       ALLOCATE(RAND_VECT(N),STAT=INFO)
       IF (INFO /= 0) THEN
	  WRITE(0,*) 'Fatal error in DISTR_RNDPART: memory allocation ',&
	       & ' failure.'
	  RETURN
       ENDIF       
       CALL IGEBR2D(ICTXT,'All',' ',N,1,RAND_VECT,N,RROOT,CROOT)
    ENDIF

    RETURN
    
  END SUBROUTINE DISTR_RNDPART


  SUBROUTINE BUILD_RNDPART(A,NPARTS)
    USE F90SPARSE
    TYPE(D_SPMAT) :: A
    INTEGER       :: NPARTS
    INTEGER       :: N, I, IB, II
    INTEGER, PARAMETER :: NB=512
    REAL(KIND(1.D0)), PARAMETER :: SEED=12345.D0
    REAL(KIND(1.D0)) :: XV(NB)

    N      = A%M

    IF (ASSOCIATED(RAND_VECT)) THEN
       DEALLOCATE(RAND_VECT)
    ENDIF
    
    ALLOCATE(RAND_VECT(N),STAT=INFO)
    
    IF (INFO /= 0) THEN
       WRITE(0,*) 'Fatal error in BUILD_RNDPART: memory allocation ',&
	    & ' failure.'
       RETURN
    ENDIF

    IF (NPARTS.GT.1) THEN
       DO I=1, N, NB
          IB = MIN(N-I+1,NB)
          CALL DURAND(SEED,IB,XV)
          DO II=1, IB
             RAND_VECT(I+II-1) = MIN(NPARTS-1,INT(XV(II)*NPARTS))
          ENDDO
       ENDDO
    ELSE
       DO I=1, N
	  RAND_VECT(I) = 0
       ENDDO
    ENDIF
    
    RETURN

  END SUBROUTINE BUILD_RNDPART 

END MODULE PARTRAND

