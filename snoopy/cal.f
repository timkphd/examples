      SUBROUTINE SNPIC
!     THIS SUBROUTINE WILL ANALYZE THE INPUT DATA AND PRINT A PICTURE
      character*1 ILINE(133),ICHR(50),IBLNK
      DIMENSION INUM(50)
      COMMON ISET
      DATA IBLNK/' '/
      DO 4 I=1,121
    4 ILINE(I)=IBLNK
      K=1
   10 READ (2,1000) (INUM(I),ICHR(I),I=1,ISET)
      i=1
!!      DO 40 I = 1, ISET
      do 
      IF (INUM(I)+1)100,11,100
!     HERE WE WRITE A LINE TO THE PRINTER AND GO BUILD ANOTHER
   11 DO 15 L = K, 121
   15 ILINE(L)=ICHR(I)
      WRITE (3,2000) (ILINE(K),K=1,121)
      ILINE(1)=IBLNK
      DO 20 K = 2, 121
   20 ILINE(K)=ICHR(I)
      K=1
      I=I+1
  100 ITST=INUM(I)
      IF (ITST + 2) 101,200,101
  101 IF (ITST) 102,40,102
  102 DO 30 J = 1, ITST
      ILINE(K)=ICHR(I)
      K=K+1
   30 CONTINUE
   40 CONTINUE
      i=i+1
      if(i .gt. iset)goto 10
      enddo
      GOTO 10
!     HERE WE EXIT THE PICTURE AND RETURN TO THE CALLING PROGRAM
  200 RETURN
!     FORMAT STATEMENTS
 1000 FORMAT (25(I2,A1))
 2000 FORMAT (121A1)
      END
!     ****************************************************************
!     * IBM 1130 EMULATOR VERSION (KYM FARNIK)                       *
!     *                                                              *
!     * COPYRIGHT - THIS IS CONSIDERED PUBLIC DOMAIN FOR THE         *
!     * FOLLOWING REASON                                             *
!     *    DURING THE 60'S AND 70'S THIS CODE (AND VARIATIONS)       *
!     *    WAS WIDELY SHARED BETWEEN GROUPS SUCH AS SHARE/GUIDE(IBM) *
!     *    AND DECUS(DIGITAL) AND THE ORGINAL AUTHOR IS UNKNOWN AND  *
!     *    HAS NEVER ASSERTED ANY RIGHTS OVER THIS CODE.             *
!     *                                                              *
!     * THIS VERSION WAS MODIFIED FROM CODE SOURCED FROM DECUS       *
!     * SEE: http://www.ibiblio.org/pub/academic/computer-science    *
!     *          /history/pdp-11/rsts/decus/sig87/087018/            *
!     * WHICH IN TURN WAS SOURCED FROM AN IBM FORTRAN+BAL VERSION    *
!     *                                                              *
!     * IBM 1130 MODS: (FORTRAN IV SUBSET)                           *
!     *   ADDED IBM 1130 JCL                                         *
!     *   REMOVE OPEN/CLOSE                                          *
!     *   CHANGED LOGIGAL IF TO ARITHMETIC IF                        *
!     *   CHANGED TO 5 CHARACTER VARIABLE NAMES                      *
!     *   CHANGED TO 120 COLUMNS IBM 1132 PRINTER                    *
!     *   EXTENED PRECISION REAL (3*16 BIT WORDS)                    *
!     *                                                              *
!     ****************************************************************
!     * PRINTS CALENDAR, ONE MONTH PER PAGE WITH PICTURES OPTIONAL.  *
!     *                                                              *
!     * BEGINNING MONTH AND YEAR, ENDING MONTH AND YEAR MUST BE PRO- *
!     * VIDED IN 4(I6)  FORMAT ON A CARD IMMEDIATELY FOLLOWING       *
!     * CARD 98 OF DECK.                                             *
!     *                                                              *
!     * IF GRID LINES ARE DESIRED, A 1 MUST APPEAR IN COLUMN 30 OF   *
!     * ABOVE CARD.  A BLANK OR ZERO WILL SUPPRESS GRID LINES.       *
!     *                                                              *
!     * ALL PICTURE DATA DECKS MUST BE TERMINATED WITH CODE -2.      *
!     * CONSECUTIVE -2*S WILL RESULT IN NO PICTURE BEING PRINTED     *
!     * FOR THAT MONTH.                                              *
!     *                                                              *
!     * PICTURE FORMAT CODES --                                      *
!     *    -1    END OF LINE                                         *
!     *    -2    END OF PICTURE                                      *
!     *    -3    LIST CARDS, ONE PER LINE, FORMAT 13A6               *
!     *    -4    LIST CARDS, TWO PER LINE, FORMAT 11A6/11A6          *
!     *    -5    LIST CARDS, TWO PER LINE, FORMAT 12A6/10A6          *
!     ****************************************************************
      character*6 AMNTH (12,7,13), ANAM(22), ANUM(2,10,5)
      character*6 BLANK,ONE,ALIN1,ALIN2,ALIN3,ALIN4
      integer NODS(12)
      character*6 CAL(60,22)
      COMMON ISET
      READ (2,1) (((AMNTH(I,J,K),K=1,13),J=1,7),I=1,12)
      READ (2,2) (ANAM(I),I=1,22)
      READ (2,3) (((ANUM(I,J,K),J=1,10),K=1,5),I=1,2)
      READ (2,4) (NODS(I),I=1,12)
      READ (2,1) BLANK,ONE,ALIN1,ALIN2,ALIN3,ALIN4
      READ (2,4) MF,IYR,MTLST,IYLST,LNSW
1     FORMAT (13A6)
2     FORMAT (11A6)
3     FORMAT (10A6)
4     FORMAT (12I6)
5     FORMAT (A1,20A6)

      ISET=25
      DO 10 I=1,60
      DO 10 J=1,22
10    CAL(I,J)= BLANK
      CAL(1,1)= ONE
      DO 20 J=1,22
20    CAL(11,J)=ANAM(J)
      IF (LNSW) 122,142,122
122   DO 125 I=20,60,8
      DO 125 J=1,22
125   CAL(I,J)=ALIN2
      DO 140 J=4,19,3
      I=13
127   DO 130 L=1,7
      CAL(I,J)=ALIN1
130   I=I+1
      IF (I-55) 135,135,140
135   CAL(I,J)=ALIN3
      I=I+1
      GO TO 127
140   CONTINUE
      DO 141 I=20,60,8
141   CAL(I,1)=ALIN4
142   IDOW=(IYR-1751)+(IYR-1753)/4-(IYR-1701)/100+(IYR-1601)/400
      IDOW=IDOW-7*((IDOW-1)/7)
55    IF (IYR-IYLST) 60,65,100
60    ML=12
      GO TO 70
65    ML=MTLST
70    IY1=IYR/1000
      NUMB=IYR-1000*IY1
      IY2=NUMB/100
      NUMB=NUMB-100*IY2
      IY3=NUMB/10
      NUMB=NUMB-10*IY3
      IY4=NUMB
      DO 72 J=1,5
      CAL(J+3,2)=ANUM(2,IY1+1,J)
      CAL(J+1,3)=ANUM(2,IY2+1,J)
      CAL(J+1,19)=ANUM(2,IY3+1,J)
72    CAL(J+3,20)=ANUM(2,IY4+1,J)
      LPYSW=0
      IF (IYR-4*(IYR/4)) 90,75,90
75    IF (IYR-100*(IYR/100)) 85,80,85
80    IF (IYR-400*(IYR/400)) 90,85,90
85    LPYSW=1
90    NODS(2)=NODS(2)+LPYSW
      IF (MF-1) 100,110,95
95    MF=MF-1
      DO 105 MONTH=1,MF
105   IDOW=IDOW+NODS(MONTH)
      IDOW=IDOW-7*((IDOW-1)/7)
      MF=MF+1
110   DO 51 MONTH=MF,ML
      LSTDY=NODS(MONTH)
      DO 115 I=1,7
      DO 115 JM=1,13
      J=JM+4
115   CAL(I,J)=AMNTH(MONTH,I,JM)
      IF (IDOW-1) 160,160,120
120   ID=IDOW-1
      J=2
      DO 155 K=1,ID
      DO 150 I=14,18
      CAL (I,J)= BLANK
150   CAL(I,J+1)= BLANK
      J=J+3
155   CONTINUE
160   IDAY=1
      II=14
25    J=3*IDOW-1
      N=IDAY/10+1
      I=II
      DO 30 K=1,5
      CAL(I,J)=ANUM(1,N,K)
30    I=I+1
      N=IDAY-10*N+11
      J=J+1
      I=II
      DO 35 K=1,5
      CAL(I,J)=ANUM(2,N,K)
35    I=I+1
      IDOW=IDOW+1
      IF (IDOW-7) 45,45,40
40    IDOW=1
      II=II+8
45    IDAY=IDAY+1
      IF (IDAY-LSTDY) 25,25,50
50    ID=IDOW
205   I=II
      J=3*ID-1
      DO 210 K=1,5
      CAL(I,J)= BLANK
      CAL(I,J+1)= BLANK
210   I=I+1
      IF (ID-7) 215,220,220
215   ID=ID+1
      GO TO 205
220   IF (II-54) 225,230,230
225   II=54
      ID=1
      GO TO 205
230   CALL SNPIC
      WRITE (3,5) ((CAL(I,J),J=1,21),I=1,60)
51    CONTINUE
      IF (IYR-IYLST) 235,100,100
235   NODS(2)=NODS(2)-LPYSW
      IYR=IYR+1
      MF=1
      GO TO 55
100   CALL EXIT
      END
