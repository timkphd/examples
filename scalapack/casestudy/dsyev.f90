!     DSYEV Example Program Text
!     NAG Copyright 2006.
!     .. Parameters ..
      INTEGER          NIN, NOUT
      PARAMETER        (NIN=5,NOUT=6)
      INTEGER          NB, NMAX
      PARAMETER        (NB=64,NMAX=10)
      INTEGER          LDA, LWORK
      PARAMETER        (LDA=NMAX,LWORK=(NB+2)*NMAX)
!     .. Local Scalars ..
      DOUBLE PRECISION EERRBD, EPS
      INTEGER          I, IFAIL, INFO, J, LWKOPT, N
!     .. Local Arrays ..
      DOUBLE PRECISION A(LDA,NMAX), RCONDZ(NMAX), W(NMAX), WORK(LWORK), &
                      ZERRBD(NMAX)
!     .. External Functions ..
      DOUBLE PRECISION DLAMCH
      EXTERNAL         DLAMCH
!     .. External Subroutines ..
      EXTERNAL         DDISNA, DSYEV, X04CAF
!     .. Intrinsic Functions ..
      INTRINSIC        ABS, MAX
!     .. Executable Statements ..
      WRITE (NOUT,*) 'DSYEV Example Program Results'
      WRITE (NOUT,*)
!     Skip heading in data file
      READ (NIN,*)
      READ (NIN,*) N
      IF (N.LE.NMAX) THEN
!
!        Read the upper triangular part of the matrix A from data file
!
         READ (NIN,*) ((A(I,J),J=I,N),I=1,N)
!
!        Solve the symmetric eigenvalue problem
!
         CALL DSYEV('Vectors','Upper',N,A,LDA,W,WORK,LWORK,INFO)
         LWKOPT = WORK(1)
!
         IF (INFO.EQ.0) THEN
!
!           Print solution
!
            WRITE (NOUT,*) 'Eigenvalues'
            WRITE (NOUT,99999) (W(J),J=1,N)
!
            IFAIL = 0
!!!!!            CALL X04CAF('General',' ',N,N,A,LDA,'Eigenvectors',IFAIL)
!
!           Get the machine precision, EPS and compute the approximate
!           error bound for the computed eigenvalues.  Note that for
!           the 2-norm, max( abs(W(i)) ) = norm(A), and since the
!           eigenvalues are returned in ascending order
!           max( abs(W(i)) ) = max( abs(W(1)), abs(W(n)))
!
            EPS = DLAMCH('Eps')
            EERRBD = EPS*MAX(ABS(W(1)),ABS(W(N)))
!
!           Call  DDISNA  to estimate reciprocal condition
!           numbers for the eigenvectors
!
            CALL DDISNA('Eigenvectors',N,N,W,RCONDZ,INFO)
!
!           Compute the error estimates for the eigenvectors
!
            DO 20 I = 1, N
               ZERRBD(I) = EERRBD/RCONDZ(I)
   20       CONTINUE
!
!           Print the approximate error bounds for the eigenvalues
!           and vectors
!
            WRITE (NOUT,*)
            WRITE (NOUT,*) 'Error estimate for the eigenvalues'
            WRITE (NOUT,99998) EERRBD
            WRITE (NOUT,*)
            WRITE (NOUT,*) 'Error estimates for the eigenvectors'
            WRITE (NOUT,99998) (ZERRBD(I),I=1,N)
         ELSE
            WRITE (NOUT,99997) 'Failure in DSYEV. INFO =', INFO
         END IF
!
!        Print workspace information
!
         IF (LWORK.LT.LWKOPT) THEN
            WRITE (NOUT,*)
            WRITE (NOUT,99996) 'Optimum workspace required = ', LWKOPT, &
             'Workspace provided         = ', LWORK
         END IF
      ELSE
         WRITE (NOUT,*) 'NMAX too small'
      END IF
      STOP
!
99999 FORMAT (3X,(8F8.4))
99998 FORMAT (4X,1P,6E11.1)
99997 FORMAT (1X,A,I4)
99996 FORMAT (1X,A,I5,/1X,A,I5)
      END