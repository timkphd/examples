      PROGRAM HELLO
      INCLUDE 'mpif.h'
*     -- BLACS example code --
*     Written by Clint Whaley 7/26/94
*     Performs a simple check-in type hello world
*     ..
*     .. External Functions ..
      INTEGER BLACS_PNUM
      EXTERNAL BLACS_PNUM
*     ..
*     .. Variable Declaration ..
      INTEGER CONTXT, IAM, NPROCS, NPROW, NPCOL, MYPROW, MYPCOL
      INTEGER ICALLER, I, J, HISROW, HISCOL
*
*     Determine my process number and the number of processes in
*     machine
*
      CALL BLACS_PINFO(IAM, NPROCS)
*
*     If in PVM, create virtual machine if it doesn't exist
*
      IF (NPROCS .LT. 1) THEN
	 IF (IAM .EQ. 0) THEN
	    WRITE(*, 1000)
	    READ(*, 2000) NPROCS
         END IF
         CALL BLACS_SETUP(IAM, NPROCS)
      END IF
*
*     Set up process grid that is as close to square as possible
*
      NPROW = INT( SQRT( REAL(NPROCS) ) )
      NPCOL = NPROCS / NPROW
*
*     Get default system context, and define grid
*
      CALL BLACS_GET(0, 0, CONTXT)
      CALL BLACS_GRIDINIT(CONTXT, 'Row', NPROW, NPCOL)
      CALL BLACS_GRIDINFO(CONTXT, NPROW, NPCOL, MYPROW, MYPCOL)
*
*     If I'm not in grid, go to end of program
*
      IF ( (MYPROW.GE.NPROW) .OR. (MYPCOL.GE.NPCOL) ) GOTO 30
*
*     Get my process ID from my grid coordinates
*
      ICALLER = BLACS_PNUM(CONTXT, MYPROW, MYPCOL)
*
*     If I am process {0,0}, receive check-in messages from
*     all nodes
*
      IF ( (MYPROW.EQ.0) .AND. (MYPCOL.EQ.0) ) THEN

         WRITE(*,*) ' '
         DO 20 I = 0, NPROW-1
	    DO 10 J = 0, NPCOL-1

	       IF ( (I.NE.0) .OR. (J.NE.0) ) THEN
		  CALL IGERV2D(CONTXT, 1, 1, ICALLER, 1, I, J) 
               ENDIF
*
*              Make sure ICALLER is where we think in process grid
*
               CALL BLACS_PCOORD(CONTXT, ICALLER, HISROW, HISCOL)
               IF ( (HISROW.NE.I) .OR. (HISCOL.NE.J) ) THEN
                  WRITE(*,*) 'Grid error!  Halting . . .'
                  STOP
               END IF
	       WRITE(*, 3000) I, J, ICALLER

10          CONTINUE
20       CONTINUE
         WRITE(*,*) ' '
         WRITE(*,*) 'All processes checked in.  Run finished.'
*
*     All processes but {0,0} send process ID as a check-in
*
      ELSE
	 CALL IGESD2D(CONTXT, 1, 1, ICALLER, 1, 0, 0)
      END IF

30    CONTINUE
   
      CALL BLACS_EXIT(0)

1000  FORMAT('How many processes in machine?')
2000  FORMAT(I)
3000  FORMAT('Process {',i2,',',i2,'} (node number =',I,
     $       ') has checked in.')

      STOP
      END