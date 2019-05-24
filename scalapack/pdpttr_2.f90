PROGRAM PDPTTR_2
!
!=======================================================================
!
! This program illustrates the use of the ScaLAPACK routines
! PDPTTRF and PDPTTRS to factor and solve a symmetric positive
! definite tridiagonal system of linear equations T*x = b in
! two distinct contexts.
!
! Using Matlab notation, we define T = diag(D)+diag(E,-1)+diag(E,1)
! and set 
!
! D = [ 1.8180 1.6602 1.3420 1.2897 1.3412 1.5341 1.7271 1.3093 ]
! E = [ 0.8385 0.5681 0.3704 0.7027 0.5466 0.4449 0.6946 ]
!
! therefore, if
!
! b = [ 1 2 3 4 5 6 7 8 ], then
! x = [ 0.3002 0.5417 1.4942 1.8546 1.5008 3.0806 1.0197 5.5692 ]
!
! and if
!
! b = [ 8 7 6 5 4 3 2 1 ], then
! x = [ 3.9036 1.0772 3.4122 2.1837 1.3090 1.2988 0.6563 0.4156 ]
!
! Note that PDPTTRS overwrites b with x. Also, D, E and b have been 
! hardcoded, which means that the code is not malleable - it works
! only with four processors.
!
! The following has been tested on an IBM SP (and should be changed
! depending on the target platform):
!
! % module load scalapack
! % mpxlf90 -o pdpttr_2.x pdpttr_2.f $SCALAPACK $PBLAS $BLACS -lessl
! % poe pdpttr_2.x -procs 4  
!
!=======================================================================
!
INTEGER :: CONTEXT, CONTEXT1, CONTEXT2, DESCA(9), DESCB(9), IB, INFO, &
           JA, LAF, LDA, LDB, LWORK, MAP(2), MB, MPIERR, MYCOL, &
           MYPE, MYROW, N, NB, NPCOL, NPE, NPROW, NRHS
DOUBLE PRECISION :: B(4), D(4), E(4)
DOUBLE PRECISION, ALLOCATABLE :: AF(:), WORK(:)
!
INCLUDE 'mpif.h'
!
! Executable statements 
!
! Set array dimensions and blocking
!
N = 8
LDA = 4
LDB = 4
NRHS = 1
NPCOL = 2
JA = 1
IB = JA
MB = 4
NB = 4
!
!
LAF = 12*NPCOL + 3*NB
LWORK = MAX( 8*NPCOL, (10+2*MIN(100,NRHS))*NPCOL+4*NRHS )
!
ALLOCATE ( AF(LAF), WORK(LWORK) )
!
! Start BLACS
!
CALL BLACS_PINFO ( MYPE, NPE )
CALL BLACS_GET ( 0, 0, CONTEXT )
CALL BLACS_GRIDINIT ( CONTEXT, 'R', 1, NPE )
!
IF ( MYPE == 0 .OR. MYPE == 1 ) THEN
!
   IF      ( MYPE == 0 ) THEN
           D(1) = 1.8180; D(2) = 1.6602; D(3) = 1.3420; D(4) = 1.2897
           E(1) = 0.8385; E(2) = 0.5681; E(3) = 0.3704; E(4) = 0.7027
           b(1) = 1; b(2) = 2; b(3) = 3; b(4) = 4
   ELSE IF ( MYPE == 1 ) THEN
           D(1) = 1.3412; D(2) = 1.5341; D(3) = 1.7271; D(4) = 1.3093
           E(1) = 0.5466; E(2) = 0.4449; E(3) = 0.6946; E(4) = 0.0000
           B(1) = 5; B(2) = 6; B(3) = 7; B(4) = 8
   END IF
!
   MAP(1) = 0
   MAP(2) = 1  
!
   CALL BLACS_GET ( CONTEXT, 10, CONTEXT1 )
   CALL BLACS_GRIDMAP ( CONTEXT1, MAP, 1, 1, 2 )
!
!  Array descriptor for A (D and E)
!
   DESCA( 1 ) = 501; DESCA( 2 ) = CONTEXT1; DESCA( 3 ) = N
   DESCA( 4 ) = NB; DESCA( 5 ) = 0; DESCA( 6 ) = LDA
   DESCA( 7 ) = 0
!
!  Array descriptor for B
!
   DESCB( 1 ) = 502; DESCB( 2 ) = CONTEXT1; DESCB( 3 ) = N
   DESCB( 4 ) = NB; DESCB( 5 ) = 0; DESCB( 6 ) = LDB
   DESCB( 7 ) = 0
!
!  Factorization
!
   CALL PDPTTRF ( N, D, E, JA, DESCA, AF, LAF, WORK, LWORK, INFO )
!
!  Solution
!
   CALL PDPTTRS ( N, NRHS, D, E, JA, DESCA, B, IB, DESCB, &
                  AF, LAF, WORK, LWORK, INFO )
!
   WRITE (*,'(A,I3,A,4F8.4)') 'PE =',MYPE,', X(:) =',B(:)
!
ELSE
!
   IF      ( MYPE == 2 ) THEN
           D(1) = 1.8180; D(2) = 1.6602; D(3) = 1.3420; D(4) = 1.2897
           E(1) = 0.8385; E(2) = 0.5681; E(3) = 0.3704; E(4) = 0.7027
           b(1) = 8; b(2) = 7; b(3) = 6; b(4) = 5
   ELSE IF ( MYPE == 3 ) THEN
           D(1) = 1.3412; D(2) = 1.5341; D(3) = 1.7271; D(4) = 1.3093
           E(1) = 0.5466; E(2) = 0.4449; E(3) = 0.6946; E(4) = 0.0000
           B(1) = 4; B(2) = 3; B(3) = 2; B(4) = 1
   END IF
!
   MAP(1) = 2
   MAP(2) = 3 
!
   CALL BLACS_GET ( CONTEXT, 10, CONTEXT2 )
   CALL BLACS_GRIDMAP ( CONTEXT2, MAP, 1, 1, 2 )
!
!  Array descriptor for A (D and E)
!
   DESCA( 1 ) = 501; DESCA( 2 ) = CONTEXT2; DESCA( 3 ) = N
   DESCA( 4 ) = NB; DESCA( 5 ) = 0; DESCA( 6 ) = LDA
   DESCA( 7 ) = 0
!
!  Array descriptor for B
!
   DESCB( 1 ) = 502; DESCB( 2 ) = CONTEXT2; DESCB( 3 ) = N
   DESCB( 4 ) = NB; DESCB( 5 ) = 0; DESCB( 6 ) = LDB
   DESCB( 7 ) = 0
!
!  Factorization
!
   CALL PDPTTRF ( N, D, E, JA, DESCA, AF, LAF, WORK, LWORK, INFO )
!
!  Solution
!
   CALL PDPTTRS ( N, NRHS, D, E, JA, DESCA, B, IB, DESCB, &
                  AF, LAF, WORK, LWORK, INFO )
!
   WRITE (*,'(A,I3,A,4F8.4)') 'PE =',MYPE,', X(:) =',B(:)
!
END IF
!
CALL BLACS_GRIDEXIT (CONTEXT)
CALL BLACS_EXIT (0)
!
STOP
!
END PROGRAM PDPTTR_2
