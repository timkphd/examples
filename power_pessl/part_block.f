C**********************************************************************
C    LICENSED MATERIALS - PROPERTY OF IBM                             *
C    "RESTRICTED MATERIALS OF IBM"                                    *
C                                                                     *
C    5765-C41                                                         *
C    (C) COPYRIGHT IBM CORP. 1997. ALL RIGHTS RESERVED.               *
C                                                                     *
C    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
C    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
C    IBM CORP.                                                        *
C**********************************************************************
C
C User defined function corresponding to an HPF  BLOCK partition 
C
      SUBROUTINE PART_BLOCK(GLOBAL_INDX,N,NP,PV,NV)
      
      IMPLICIT NONE
      
      INTEGER, INTENT(IN)  :: GLOBAL_INDX, N, NP
      INTEGER, INTENT(OUT) :: NV
      INTEGER, INTENT(OUT) :: PV(*)
      INTEGER              :: DIM_BLOCK
      REAL(8), PARAMETER   :: PC=0.0D0
      REAL(8)              :: DDIFF
      INTEGER              :: IB1, IB2, IPV
      
      DIM_BLOCK = (N + NP - 1)/NP
      NV = 1  
      PV(NV) = (GLOBAL_INDX - 1) / DIM_BLOCK
      
      IPV = PV(1)
      IB1 = IPV * DIM_BLOCK + 1
      IB2 = (IPV+1) * DIM_BLOCK
      
      DDIFF = DBLE(ABS(GLOBAL_INDX-IB1))/DBLE(DIM_BLOCK)
      IF (DDIFF < PC/2) THEN
C
C     Overlap at the beginning of a block, with the previous proc
C         
         IF (IPV>0) THEN 
            NV     = NV + 1
            PV(NV) = IPV - 1
         ENDIF
      ENDIF

      DDIFF = DBLE(ABS(GLOBAL_INDX-IB2))/DBLE(DIM_BLOCK)
      IF (DDIFF < PC/2) THEN
C
C     Overlap at the end of a block, with the next proc
C         
         IF (IPV<(NP-1)) THEN 
            NV     = NV + 1
            PV(NV) = IPV + 1
         ENDIF
      ENDIF
      
      RETURN
      END 
      
