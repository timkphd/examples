      module numz
        integer,parameter :: bx=selected_real_kind(12)
!        integer,parameter :: bx=selected_real_kind(4)
      end module
!   linsolve.f
!   Use Scalapack and MPI to solve a system of linear equations
!   on a virtual rectangular grid of processes.
!
!   Input:
!       N: order of linear system
!       NPROC_ROWS: number of rows in process grid
!       NPROC_COLS: number of columns in process grid
!       ROW_BLOCK_SIZE:  blocking size for matrix rows
!       COL_BLOCK_SIZE:  blocking size for matrix columns
!
!   Output:
!       Input data, error in solution, and time to solve system.
!
!   Algorithm:
!     1.  Initialize MPI and BLACS.
!       2.  Get process rank (MY_RANK) and total number of 
!           processes (NP).   Use both BLACS and MPI.
!       3a. Process 0 read and broadcast matrix order (N),
!           number of process rows (NPROC_ROWS), number 
!           of process columns (NPROC_COLS), ROW_BLOCK_SIZE,
!         and COL_BLOCK_SIZE.
!       3b. Process != 0 receive same.
!       4.  Use BLACS_GRIDINIT to set up process grid.
!       5.  Compute amount of storage needed for local arrays.
!       6.  Use ScaLAPACK routine DESCINIT to initialize
!           descriptors for A, EXACT (= exact solution), and B.
!       7.  Use random number generator to generate contents 
!           of local block of matrix (A_LOCAL).
!       8.  Set entries of EXACT to 1.0.
!     9.  Generate B by computing B = A*EXACT.  Use
!           PBLAS routine PSGEMV.
!      10.  Solve linear system by call to ScaLAPACK routine
!           PSGESV (solution returned in B). 
!      11.  Use PBLAS routines PSAXPY and PSNRM2 to compute
!           the norm of the error ||B - EXACT||_2.
!      12.  Process 0 print results.
!      13.  Free up storage, shutdown BLACS and MPI.
!
!   Notes:
!       1.  The vectors EXACT, and B are significant only
!           in the first process column.
!       2.  A_LOCAL is allocated as a linear array.
!       3.  The solver only allows square blocks.  So we
!           read in a single value, BLOCK_SIZE, and assign
!           it to ROW_BLOCK_SIZE and COL_BLOCK_SIZE.  Thus,
!           since the matrix is square, NPROC_ROWS = NPROC_COLS.
!
      PROGRAM LINSOLVE
      use numz
      implicit none 
      INCLUDE 'mpif.h'
!
!   Constants
      INTEGER           MAX_VECTOR_SIZE
      INTEGER           MAX_MATRIX_SIZE
      INTEGER           DESCRIPTOR_SIZE
      PARAMETER (MAX_VECTOR_SIZE =1000) 
      PARAMETER   (MAX_MATRIX_SIZE = 250000)
      PARAMETER   (DESCRIPTOR_SIZE = 10)
      real(bx) pwork(100000)
!
!   Array Variables
      REAL(bx)        B_LOCAL(MAX_VECTOR_SIZE)
      INTEGER           B_DESCRIP(DESCRIPTOR_SIZE)
!
      REAL(bx)        EXACT_LOCAL(MAX_VECTOR_SIZE)
      INTEGER           EXACT_DESCRIP(DESCRIPTOR_SIZE)
!
      REAL(bx)        A_LOCAL(MAX_MATRIX_SIZE)
      INTEGER           A_DESCRIP(DESCRIPTOR_SIZE)
      INTEGER           PIVOT_LIST(MAX_VECTOR_SIZE)
!
!   Scalar Variables
      INTEGER     NP
      INTEGER           MY_RANK
      INTEGER           NPROC_ROWS
      INTEGER           NPROC_COLS
      INTEGER           IERROR
      INTEGER           M, N
      INTEGER           ROW_BLOCK_SIZE
      INTEGER           COL_BLOCK_SIZE
      INTEGER         INPUT_DATA_TYPE
      INTEGER         BLACS_CONTEXT
      INTEGER         TEMP_CONTEXT
      INTEGER         LOCAL_MAT_ROWS
      INTEGER         LOCAL_MAT_COLS
      INTEGER           EXACT_LOCAL_SIZE
      INTEGER           B_LOCAL_SIZE
      INTEGER           I, J
      INTEGER           MY_PROCESS_ROW
      INTEGER           MY_PROCESS_COL
      REAL(bx)            ERROR_2
      DOUBLE PRECISION START_TIME
      DOUBLE PRECISION ELAPSED_TIME
      real randout
      integer , allocatable ::  myseed(:)
      integer nseed
!
!   Local Functions
!       REAL(bx)            RAND_VAL
!
!   External subroutines
!     MPI:
!      EXTERNAL    MPI_INIT, MPI_COMM_SIZE, MPI_COMM_RANK
!      EXTERNAL    MPI_BCAST, MPI_ABORT
!      EXTERNAL    MPI_BARRIER, MPI_FINALIZE
!     BLACS:
!      EXTERNAL    BLACS_GET, BLACS_GRIDINIT, BLACS_PCOORD
!      EXTERNAL    BLACS_EXIT
!     PBLAS:
!      EXTERNAL    PSGEMV, PSAXPY, PSNRM2
!     ScaLAPACK
!      EXTERNAL    DESCINIT, PSGESV
!     System
!      EXTERNAL    SLARNV
!
!   External functions
!     ScaLAPACK:
      INTEGER           NUMROC
!      EXTERNAL    NUMROC
      INTEGER IAM,NPROCS
!
!   Junk Variables
      INTEGER           ISEED(4)
      logical pr,nat_rand
      integer outnum
!
!   Begin Executable Statements
!
!  print arrays
      pr=.true.
!  Fortran file output number 6 = stadout
!  Anything over 6 and a file will be created
      outnum=18
! use native random for matrix generation
      nat_rand=.false.
!   Initialize MPI and BLACS
      CALL MPI_INIT(IERROR)
!
      CALL MPI_COMM_SIZE(MPI_COMM_WORLD, NP, IERROR)
      CALL MPI_COMM_RANK(MPI_COMM_WORLD, MY_RANK, IERROR)
      if(my_rank .eq. 0 .and. outnum .gt. 6 .and. pr) then
        open(outnum,file="gesv.out",status="unknown")
      endif
!      CALL BLACS_PINFO(IAM, NPROCS)
!     
!
!   Get Input Data.  
      IF (MY_RANK.EQ.0) THEN
          READ(5,*) N, NPROC_ROWS, NPROC_COLS, ROW_BLOCK_SIZE,COL_BLOCK_SIZE
      END IF
      CALL MPI_BCAST(N,              1, MPI_INTEGER, 0, MPI_COMM_WORLD, IERROR)
      CALL MPI_BCAST(NPROC_ROWS,     1, MPI_INTEGER, 0, MPI_COMM_WORLD, IERROR)
      CALL MPI_BCAST(NPROC_COLS,     1, MPI_INTEGER, 0, MPI_COMM_WORLD, IERROR)
      CALL MPI_BCAST(ROW_BLOCK_SIZE, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, IERROR)
      CALL MPI_BCAST(COL_BLOCK_SIZE, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, IERROR)
      IF (NP.LT.(NPROC_ROWS*NPROC_COLS)) THEN
          WRITE(6,250) MY_RANK, NP, NPROC_ROWS, NPROC_COLS
  250     FORMAT(' ','Proc ',I2,' > NP = ',I2,', NPROC_ROWS = ',I2,', NPROC_COLS = ',I2)
          WRITE(6,260)
  260       FORMAT(' ','Need more processes!  Quitting.')
          CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
        END IF
        
!
!   The matrix is square
        M = N
!
!
!   Build BLACS grid.
!     First get BLACS System Context (in TEMP_CONTEXT(1))
      CALL BLACS_GET(0, 0, BLACS_CONTEXT)
!      BLACS_CONTEXT = TEMP_CONTEXT
!
!     BLACS_CONTEXT is in/out.
!     'R': process grid will use row major ordering.
      CALL BLACS_GRIDINIT(BLACS_CONTEXT,'Row',NPROC_ROWS,NPROC_COLS)
!
!
!   Figure out how many rows and cols we'll need in the local
!     matrix.
      CALL BLACS_PCOORD(BLACS_CONTEXT, MY_RANK, MY_PROCESS_ROW,MY_PROCESS_COL)
      LOCAL_MAT_ROWS = NUMROC(M, ROW_BLOCK_SIZE, MY_PROCESS_ROW,0, NPROC_ROWS)
      LOCAL_MAT_COLS = NUMROC(N, COL_BLOCK_SIZE, MY_PROCESS_COL,0, NPROC_COLS)
      IF (LOCAL_MAT_ROWS*LOCAL_MAT_COLS.GT.MAX_MATRIX_SIZE) THEN
          WRITE(6,290) MY_RANK, LOCAL_MAT_ROWS, LOCAL_MAT_COLS,MAX_MATRIX_SIZE
  290       FORMAT(' ','Proc ',I2, &
                     ' > LOCAL_MAT_ROWS = ',I5, &
                     ', LOCAL_MAT_COLS = ',I5, &
                     ', MAX_MATRIX_SIZE = ',I6)
          WRITE(6,292)
  292       FORMAT(' ','Insufficient storage!  Quitting.')
          CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
      END IF
!
! Now figure out storage for B_LOCAL and EXACT_LOCAL
      B_LOCAL_SIZE = NUMROC(M, ROW_BLOCK_SIZE, MY_PROCESS_ROW,0, NPROC_ROWS)
      IF (B_LOCAL_SIZE.GT.MAX_VECTOR_SIZE) THEN
          WRITE(6,294) MY_RANK, B_LOCAL_SIZE, MAX_VECTOR_SIZE
  294       FORMAT(' ','Proc ',I2,' > B_LOCAL_SIZE = ',I5,', MAX_VECTOR_SIZE = ',I5)
          WRITE(6,296)
  296       FORMAT(' ','Insufficient storage!  Quitting.')
          CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
      END IF
!
      EXACT_LOCAL_SIZE = NUMROC(N, COL_BLOCK_SIZE, MY_PROCESS_ROW,0, NPROC_ROWS)
      IF (EXACT_LOCAL_SIZE.GT.MAX_VECTOR_SIZE) THEN
          WRITE(6,298) MY_RANK, EXACT_LOCAL_SIZE, MAX_VECTOR_SIZE
  298       FORMAT(' ','Proc ',I2,' > EXACT_LOCAL_SIZE = ',I5,', MAX_VECTOR_SIZE = ',I5)
          WRITE(6,299)
  299       FORMAT(' ','Insufficient storage!  Quitting.')
        write(*,*)"calling abort"
          CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
      END IF
!
!
! Now build the matrix descriptors
      CALL DESCINIT(A_DESCRIP, M, N, ROW_BLOCK_SIZE, &
                    COL_BLOCK_SIZE, 0, 0, BLACS_CONTEXT, &
                    LOCAL_MAT_ROWS, IERROR)
      IF (IERROR.NE.0) THEN
            WRITE(6,300) MY_RANK, IERROR 
  300       FORMAT(' ','Proc ',I2,' > DESCINIT FOR A FAILED, IERROR = ',I3)
            CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
        END IF
!
        CALL DESCINIT(B_DESCRIP, M, 1, ROW_BLOCK_SIZE, 1, &
                      0, 0, BLACS_CONTEXT, B_LOCAL_SIZE, &
                      IERROR)
      IF (IERROR.NE.0) THEN
            WRITE(6,350) MY_RANK, IERROR 
  350       FORMAT(' ','Proc ',I2,' > DESCINIT FOR B FAILED, IERROR = ',I3)
            CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
        END IF
!       
        CALL DESCINIT(EXACT_DESCRIP, N, 1, COL_BLOCK_SIZE, 1, &
                      0, 0, BLACS_CONTEXT, EXACT_LOCAL_SIZE, &
                      IERROR)
      IF (IERROR.NE.0) THEN
            WRITE(6,400) MY_RANK, IERROR 
  400       FORMAT(' ','Proc > ',I2,' > DESCINIT FOR EXACT FAILED, IERROR = ',I3)
            CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
        END IF
!
!
!   Now initialize A_LOCAL and EXACT_LOCAL
    if (nat_rand) then
     call random_seed(size=nseed)
     allocate(myseed(nseed))
     myseed=my_rank+10
     CALL random_SEED(put=myseed)
     DO 600 J = 0, LOCAL_MAT_COLS - 1
         DO 500 I = 1, LOCAL_MAT_ROWS
         CALL RANDOM_NUMBER(randout)
           A_LOCAL(LOCAL_MAT_ROWS*J + I) = randout
  500          CONTINUE
  600  CONTINUE
  else
          if(my_rank .eq. 0)write(6,"('Reading A')")
! echo "800 800" > A
! grep aa gesv.dp | awk '{print $4}' >> A
          call pdlaread( "A" , A_local, a_DESCRIP, 0,0, PWORK )
  endif
      if(pr)call pdlaprnt( N, N, a_local, 1, 1, a_DESCRIP, 0, 0, "aaaaa", outnum, PWORK )
      DO 700 I = 1, EXACT_LOCAL_SIZE
          EXACT_LOCAL(I) = 1.0_bx
  700 CONTINUE
!
!
!   Use PBLAS function PSGEMV to compute right-hand side B = A*EXACT
!     'N': Multiply by A -- not A^T or A^H
      CALL PDGEMV('N', M, N, 1.0_bx, A_LOCAL, 1, 1, A_DESCRIP, &
                   EXACT_LOCAL, 1, 1, EXACT_DESCRIP, 1, 0.0_bx, &
                   B_LOCAL, 1, 1, B_DESCRIP, 1)
      if(pr)call pdlaprnt( N, 1, B_local, 1, 1, B_DESCRIP, 0, 0, "bbbbb", outnum, PWORK )
      if(pr)call pdlaprnt( N, 1, EXACT_LOCAL, 1, 1, B_DESCRIP, 0, 0, "XXXXX", outnum, PWORK )
! 
!
!   Done with setup!  Solve the system.
      CALL MPI_BARRIER(MPI_COMM_WORLD, IERROR)
      START_TIME = MPI_WTIME()
      CALL PDGESV(N, 1, A_LOCAL, 1, 1, A_DESCRIP, PIVOT_LIST, &
                        B_LOCAL, 1, 1, B_DESCRIP, IERROR)
      ELAPSED_TIME = MPI_WTIME() - START_TIME
      IF (IERROR.NE.0) THEN
            WRITE(6,800) MY_RANK, IERROR 
  800       FORMAT(' ','Proc ',I2,' > PSGESV FAILED, IERROR = ',I3)
            CALL MPI_ABORT(MPI_COMM_WORLD, -1, IERROR)
        END IF

!      WRITE(6,850) MY_RANK, (B_LOCAL(J), J = 1, B_LOCAL_SIZE)
!  850   FORMAT(' ','Proc ',I2,' > B = ',F6.3,' ',F6.3,' ',F6.3,' ', &
!              F6.3,' ',F6.3,' ',F6.3,' ',F6.3,' ',F6.3,' ',F6.3,' ', &
!              F6.3)
!      WRITE(6,860) MY_RANK, (EXACT_LOCAL(I), I = 1, EXACT_LOCAL_SIZE)
!  860   FORMAT(' ','Proc ',I2,' > EXACT = ',F6.3,' ',F6.3,' ',F6.3,' ', &
!              F6.3,' ',F6.3,' ',F6.3,' ',F6.3,' ',F6.3,' ',F6.3,' ', &
!              F6.3)

!   Now find the norm of the error.
!     First compute EXACT = -1*B + EXACT
        CALL PDAXPY(N, -1.0_bx, B_LOCAL, 1, 1, B_DESCRIP, 1, &
                    EXACT_LOCAL, 1, 1, EXACT_DESCRIP, 1)
!     Now compute 2-norm of EXACT
      CALL PDNRM2(N, ERROR_2, EXACT_LOCAL, 1, 1, EXACT_DESCRIP, 1)
!
!
      if(pr)call pdlaprnt( N, 1, B_local, 1, 1, B_DESCRIP, 0, 0, "BBBBB", outnum, PWORK )
      !write(MY_RANK+10,"(10f10.0)")b_local
      IF (MY_RANK.EQ.0) THEN
          WRITE(6,900) N, NP
  900       FORMAT(' ','N = ',I4,', Number of Processes = ',I2)
          WRITE(6,950) NPROC_ROWS, NPROC_COLS
  950     FORMAT(' ','Process rows = ',I2,', Process cols = ',I2)
          WRITE(6,1000) ROW_BLOCK_SIZE, COL_BLOCK_SIZE
 1000     FORMAT(' ','Row block size = ',I3,', Col block size = ',I3)
          WRITE(6,1100) ERROR_2
 1100     FORMAT(' ','2-Norm of error = ',E13.6)
          WRITE(6,1200) 1000.0*ELAPSED_TIME
 1200     FORMAT(' ','Elapsed time = ',D13.6,' milliseconds')
        END IF
!
!
!   Now free up allocated resources and shut down
!     Call BLACS_EXIT.  Argument != 0 says, "I'll shut down MPI."
      CALL BLACS_EXIT(1)
        CALL MPI_FINALIZE(IERROR)
!
      STOP
!
!     End of Main Program LINSOLVE
      END

