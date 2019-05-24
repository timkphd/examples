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
*     SUBROUTINE DESYM(NROW,A,JA,IA,AS,JAS,IAS,IAW,NNZERO)                  *
*                                                                           *
*     Purpose                                                               *
*     =======                                                               *
*         Utility routine to convert from symmetric storage                 *       
*      to full format (CSR mode).                                           * 
*                                                                           *
*     Parameter                                                             *
*     =========                                                             *
*     INPUT=                                                                *
*                                                                           *
*     SYMBOLIC NAME: NROW                                                   *
*     POSITION:      Parameter No.1                                         *
*     ATTRIBUTES:    INTEGER                                                *
*     VALUES:        NROW>0                                                 *
*     DESCRIPTION:   On entry NROW specifies the number of rows of the      *
*                    input sparse matrix. The number of column of the input *
*                    sparse matrix must be the same.                        *
*                    Unchanged on exit.                                     *
*                                                                           *
*     SYMBOLIC NAME: A                                                      *
*     POSITION:      Parameter No.2                                         *
*     ATTRIBUTES:    DOUBLE PRECISION ARRAY of Dimension (NNZERO)           *
*     VALUES:                                                               *
*     DESCRIPTION:   A specifies the values of the input  sparse matrix.    *
*                    This matrix  is stored in CSR mode                     * 
*                    Unchanged on exit.                                     *
*                                                                           *
*     SYMBOLIC NAME: JA                                                     *
*     POSITION:      Parameter No. 3                                        *
*     ATTRIBUTES:    INTEGER  ARRAY(NNZERO)                                 *
*     VALUES:         >  0                                                  *
*     DESCRIPTION:   Column indices stored by rows refered to the input     *
*                    sparse matrix.                                         *
*                    Unchanged on exit.                                     *
*                                                                           *
*     SYMBOLIC NAME: IA                                                     *
*     POSITION:      Parameter No. 4                                        *
*     ATTRIBUTES:    INTEGER ARRAY(NROW+1)                                  *
*     VALUES:        >0; increasing.                                        *
*     DESCRIPTION:   Row pointer array: it contains the starting            *
*                    position of each row of A in array JA.                 *
*                    Unchanged on exit.                                     *
*                                                                           *
*     SYMBOLIC NAME: IAW                                                    *
*     POSITION:      Parameter No. 7                                        *
*     ATTRIBUTES:    INTEGER ARRAY of Dimension (NROW+1)                    *
*     VALUES:        >0;                                                    *
*     DESCRIPTION:   Work Area.                                             *
*                                                                           *
*     SYMBOLIC NAME: WORK                                                   *
*     POSITION:      Parameter No. 8                                        *
*     ATTRIBUTES:    REAL*8  ARRAY of Dimension (NROW+1)                    *
*     VALUES:        >0;                                                    *
*     DESCRIPTION:   Work Area.                                             *
*                                                                           *
*     SYMBOLIC NAME: NNZERO                                                 *
*     POSITION:      Parameter No. 9                                        *
*     ATTRIBUTES:    INTEGER                                                *
*     VALUES:        >0;                                                    *
*     DESCRIPTION:   On entry contains: the number of the non zero          *
*                    entry of the input matrix.                             *
*                    Unchanged on exit.                                     *
*      OUTPUT==                                                             *
*                                                                           *
*                                                                           *
*     SYMBOLIC NAME: AS                                                     *
*     POSITION:      Parameter No.5                                         *
*     ATTRIBUTES:    DOUBLE PRECISION ARRAY of Dimension (*)                *
*     VALUES:                                                               *
*     DESCRIPTION:   On exit A specifies the values of the output  sparse   *
*                    matrix.                                                *
*                    This matrix  correspondes to A rapresented in FULL-CSR *
*                    mode                                                   * 
*                                                                           *
*     SYMBOLIC NAME: JAS                                                    *
*     POSITION:      Parameter No. 6                                        *
*     ATTRIBUTES:    INTEGER  ARRAY(IAS(NROW+1)-1)                          *
*     VALUES:         >  0                                                  *
*     DESCRIPTION:   Column indices stored by rows refered to the output    *
*                    sparse matrix.                                         *
*                                                                           *
*     SYMBOLIC NAME: IAS                                                    *
*     POSITION:      Parameter No. S                                        *
*     ATTRIBUTES:    INTEGER ARRAY(NROW+1)                                  *
*     VALUES:        >0; increasing.                                        *
*     DESCRIPTION:   Row pointer array: it contains the starting            *
*                    position of each row of AS in array JAS.               *
*****************************************************************************
      SUBROUTINE DESYM(NROW,A,JA,IA,AS,JAS,IAS,IAW,WORK,NNZERO,
     +   VALUE)
      IMPLICIT NONE
C      .. Scalar Arguments ..                                              
      INTEGER NROW,NNZERO,VALUE,INDEX
C     .. Array Arguments ..                                                     
      DOUBLE PRECISION A(*),AS(*),WORK(*)                                 
      INTEGER IA(*),IAS(*),JAS(*),JA(*),IAW(*)                
C     .. Local Scalars ..                                                       
      INTEGER I,IAW1,IAW2,IAWT,J,JPT,K,KPT,LDIM,COUNT,JS,BUFI
C      REAL*8  BUF
C     ..                                                                        

      DO I=1,NROW
         IAW(I)=0
      END DO
C    ....Compute element belonging to each row in output matrix.....
      DO I=1,NROW
         DO J=IA(I),IA(I+1)-1
            IAW(I)=IAW(I)+1
            IF (JA(J).NE.I) IAW(JA(J))=IAW(JA(J))+1
         END DO
      END DO

      IAS(1)=1
      DO I=1,NROW
         IAS(I+1)=IAS(I)+IAW(I)
         IAW(I)=0
      END DO
      
      
C
C     .....Computing values array AS and column array indices JAS....
C     
      DO I=1,NROW
         DO J=IA(I),IA(I+1)-1
            IF (VALUE.NE.0) THEN
               AS(IAS(I)+IAW(I))=A(J)
            ENDIF
            JAS(IAS(I)+IAW(I))=JA(J)
            IAW(I)=IAW(I)+1
            IF (I.NE.JA(J)) THEN
               IF (VALUE.NE.0) THEN
                  AS(IAS(JA(J))+IAW(JA(J)))=A(J)
               ENDIF
               NNZERO=NNZERO+1
               JAS(IAS(JA(J))+IAW(JA(J)))=I
               IAW(JA(J))=IAW(JA(J))+1
            END IF
         END DO
      END DO

C     ......Sorting output arrays by column index......
C     .....the IAS index not must be modified.....
C
      DO I=1,NROW
         CALL ISORTX(JAS(IAS(I)),1,IAS(I+1)-IAS(I),IAW)
         INDEX=IAS(I)-1
         IF (VALUE.NE.0) THEN
            DO J=1,IAS(I+1)-IAS(I)
               WORK(J)=AS(IAW(J)+INDEX)
            END DO
            DO J=1,IAS(I+1)-IAS(I)
               AS(J+INDEX)=WORK(J)
            END DO
         ENDIF
C         ....column indices are already sorted by ISORTX...
      ENDDO
      RETURN                                                                    
                                                                                
      END                                                                       




