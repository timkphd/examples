@process free(f90) 
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
MODULE PARTBCYC
  PUBLIC PART_BCYC, SET_NB
  PRIVATE 
  INTEGER, SAVE :: BLOCK_SIZE
  
CONTAINS
  !
  ! User defined subroutine corresponding to an HPF  CYCLIC(NB)
  ! data distribution
  !
  SUBROUTINE PART_BCYC(GLOBAL_INDX,N,NP,PV,NV)
  
    IMPLICIT NONE
    
    INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, NP
    INTEGER, INTENT(OUT) :: NV
    INTEGER, INTENT(OUT) :: PV(*)
    
    NV = 1  
    PV(NV) = MOD((((GLOBAL_INDX+BLOCK_SIZE-1)/BLOCK_SIZE)-1),NP)
    RETURN
  END SUBROUTINE PART_BCYC
  
  SUBROUTINE SET_NB(NB, RROOT, CROOT, ICTXT)
    INTEGER    :: RROOT, CROOT, ICTXT
    INTEGER    :: N, MER, MEC, NPR, NPC
    
    CALL BLACS_GRIDINFO(ICTXT,NPR,NPC,MER,MEC)
    
    IF (.NOT.((RROOT>=0).AND.(RROOT<NPR).AND.&
	 & (CROOT>=0).AND.(CROOT<NPC))) THEN 
       WRITE(0,*) 'Fatal error in SET_NB: invalid ROOT  ',&
	    & 'coordinates '
       CALL BLACS_ABORT(ICTXT,-1)
       RETURN
    ENDIF

    IF ((MER==RROOT).AND.(MEC==CROOT)) THEN
       IF (NB < 1) THEN
          WRITE(0,*) 'Fatal error in SET_NB: invalid NB'
          CALL BLACS_ABORT(ICTXT,-1)
          RETURN
       ENDIF
       CALL IGEBS2D(ICTXT,'A',' ',1,1,NB,1)
    ELSE
       CALL IGEBR2D(ICTXT,'A',' ',1,1,NB,1,RROOT,CROOT)
    ENDIF
    BLOCK_SIZE = NB

    RETURN
  END SUBROUTINE SET_NB
END MODULE PARTBCYC

