    ! http://www.netlib.org/scalapack/examples/
    program example1
    use, intrinsic :: iso_fortran_env, only : stderr=>error_unit,stdout=>output_unit
    !
    !     example program solving ax=b via scalapack routine pdgesv
    !
    !     .. parameters ..
    integer            dlen_, ia, ja, ib, jb, m, n, mb, nb, rsrc,csrc, mxllda, mxlldb, nrhs, nbrhs,mxlocr, mxlocc, &
     mxrhsc
    parameter          ( dlen_ = 9, ia = 1, ja = 1, ib = 1, jb = 1,m = 9, n = 9, mb = 2, nb = 2, rsrc = 0,csrc = 0, &
     mxllda = 5, mxlldb = 5, nrhs = 1,nbrhs = 1, mxlocr = 5, mxlocc = 4,mxrhsc = 1 )
    double precision   one
    parameter          ( one = 1.0d+0 )
    double precision pwork(100)
    character(len=7)astr,bstr,xstr
    !     ..
    !     .. local scalars ..
    integer            ictxt, info, mycol, myrow, npcol, nprow
    double precision   anorm, bnorm, eps, resid, xnorm
    !     ..
    !     .. local arrays ..
    integer            desca( dlen_ ), descb( dlen_ ),ipiv( mxlocr+nb )
    double precision   a( mxllda, mxlocc ), a0( mxllda, mxlocc ),b( mxlldb, mxrhsc ), b0( mxlldb, mxrhsc ), &
    work( mxlocr )
    !     ..
    !     .. external functions ..
    double precision, external ::   pdlamch, pdlange
    !     ..
    !     .. external subroutines ..
    external           blacs_exit, blacs_gridexit, blacs_gridinfo,descinit, matinit,sl_init,pdgemm, pdgesv, pdlacpy
    !     ..
    !     .. intrinsic functions ..
    intrinsic          dble
    !     ..
    !     .. data statements ..
    data               nprow / 2 / , npcol / 3 /
    !     ..
    !     .. executable statements ..
    !
    !     initialize the process grid
    !
    astr="++ a ++"
    bstr="++ b ++"
    xstr="++ x ++"
    call sl_init( ictxt, nprow, npcol )
    call blacs_gridinfo( ictxt, nprow, npcol, myrow, mycol )
    !
    !     if i'm not in the process grid, go to the end of the program
    !
    if( myrow == -1 ) call blacs_exit( 0 )
    !
    !     distribute the matrix on the process grid
    !     initialize the array descriptors for the matrices a and b
    !
    call descinit( desca, m, n, mb, nb, rsrc, csrc, ictxt, mxllda,info )
    call descinit( descb, n, nrhs, nb, nbrhs, rsrc, csrc, ictxt,mxlldb, info )
    !
    !     generate matrices a and b and distribute to the process grid
    !
    a=0
    b=0
    call matinit( a, desca, b, descb )
    call pdlaprnt( M, N, A, 1, 1, DESCA, 0, 0, astr, stdout, PWORK )
    call pdlaprnt( N, 1, B, 1, 1, DESCB, 0, 0, bstr, stdout, PWORK )

    !
    !     make a copy of a and b for checking purposes
    call pdlacpy( 'all', n, n, a, 1, 1, desca, a0, 1, 1, desca )
    call pdlacpy( 'all', n, nrhs, b, 1, 1, descb, b0, 1, 1, descb )
    !
    !     call the scalapack routine
    !     solve the linear system a * x = b
    !
    call pdgesv( n, nrhs, a, ia, ja, desca, ipiv, b, ib, jb, descb,info )
    call pdlaprnt( N, 1, B, 1, 1, DESCB, 0, 0, xstr, stdout, PWORK )
    !
    if( myrow == 0 .and. mycol == 0 ) then
        write( stdout, fmt = 9999 )
        write( stdout, fmt = 9998 )m, n, nb
        write( stdout, fmt = 9997 )nprow*npcol, nprow, npcol
        write( stdout, fmt = 9996 )info
    end if
    !
    !     compute residual ||a * x  - b|| / ( ||x|| * ||a|| * eps * n )
    !
    eps = pdlamch( ictxt, 'epsilon' )
    anorm = pdlange( 'i', n, n, a, 1, 1, desca, work )
    bnorm = pdlange( 'i', n, nrhs, b, 1, 1, descb, work )
    call pdgemm( 'n', 'n', n, nrhs, n, one, a0, 1, 1, desca, b, 1, 1,descb, -one, b0, 1, 1, descb )
    xnorm = pdlange( 'i', n, nrhs, b0, 1, 1, descb, work )
    resid = xnorm / ( anorm*bnorm*eps*dble( n ) )
    !
    if( myrow == 0 .and. mycol == 0 ) then
        write( stdout, fmt = 9993 )resid
        if( resid > 10 ) then
            error stop 'per normalized residual: solution is incorrect.'
        endif
        write( stdout, fmt = 9995 )
    end if
    !
    !     release the process grid
    !     free the blacs context
    !
    call blacs_gridexit( ictxt )
    !
    !     exit the blacs
    !
    call blacs_exit( 0 )
    !
 9999 FORMAT( / 'ScaLAPACK Example Program #1 -- May 1, 1997' )
 9998 format( / 'solving ax=b where a is a ', i3, ' by ', i3,' matrix with a block size of ', i3 )
 9997 format( 'running on ', i3, ' processes, where the process grid',' is ', i3, ' by ', i3 )
 9996 FORMAT( / 'INFO code returned by PDGESV = ', I3 )
 9993 FORMAT( / '||A*x - b|| / ( ||x||*||A||*eps*N ) = ', 1P, E16.8 )
 9995 format( /'according to the normalized residual the solution is correct.')
end program


subroutine matinit( aa, desca, b, descb )
    !
    !     matinit generates and distributes matrices a and b (depicted in
    !     figures 2.5 and 2.6) to a 2 x 3 process grid
    !
    !     .. array arguments ..
    integer            desca( * ), descb( * )
    double precision   aa( * ), b( * )
    !     ..
    !     .. parameters ..
    integer            ctxt_, lld_
    parameter          ( ctxt_ = 2, lld_ = 9 )
    !     ..
    !     .. local scalars ..
    integer            ictxt, mxllda, mycol, myrow, npcol, nprow
    double precision   a, c, k, l, p, s
    !     ..
    !     .. external subroutines ..
    external           blacs_gridinfo
    !     ..
    !     .. executable statements ..
    !
    ictxt = desca( ctxt_ )
    call blacs_gridinfo( ictxt, nprow, npcol, myrow, mycol )
    !
    s = 19.0d0
    c = 3.0d0
    a = 1.0d0
    l = 12.0d0
    p = 16.0d0
    k = 11.0d0
    !
    mxllda = desca( lld_ )
    !
    if( myrow == 0 .and. mycol == 0 ) then
        aa( 1 ) = s
        aa( 2 ) = -s
        aa( 3 ) = -s
        aa( 4 ) = -s
        aa( 5 ) = -s
        aa( 1+mxllda ) = c
        aa( 2+mxllda ) = c
        aa( 3+mxllda ) = -c
        aa( 4+mxllda ) = -c
        aa( 5+mxllda ) = -c
        aa( 1+2*mxllda ) = a
        aa( 2+2*mxllda ) = a
        aa( 3+2*mxllda ) = a
        aa( 4+2*mxllda ) = a
        aa( 5+2*mxllda ) = -a
        aa( 1+3*mxllda ) = c
        aa( 2+3*mxllda ) = c
        aa( 3+3*mxllda ) = c
        aa( 4+3*mxllda ) = c
        aa( 5+3*mxllda ) = -c
        b( 1 ) = 0
        b( 2 ) = 0
        b( 3 ) = 0
        b( 4 ) = 0
        b( 5 ) = 0
    else if( myrow == 0 .and. mycol == 1 ) then
        aa( 1 ) = a
        aa( 2 ) = a
        aa( 3 ) = -a
        aa( 4 ) = -a
        aa( 5 ) = -a
        aa( 1+mxllda ) = l
        aa( 2+mxllda ) = l
        aa( 3+mxllda ) = -l
        aa( 4+mxllda ) = -l
        aa( 5+mxllda ) = -l
        aa( 1+2*mxllda ) = k
        aa( 2+2*mxllda ) = k
        aa( 3+2*mxllda ) = k
        aa( 4+2*mxllda ) = k
        aa( 5+2*mxllda ) = k
    else if( myrow == 0 .and. mycol == 2 ) then
        aa( 1 ) = a
        aa( 2 ) = a
        aa( 3 ) = a
        aa( 4 ) = -a
        aa( 5 ) = -a
        aa( 1+mxllda ) = p
        aa( 2+mxllda ) = p
        aa( 3+mxllda ) = p
        aa( 4+mxllda ) = p
        aa( 5+mxllda ) = -p
    else if( myrow == 1 .and. mycol == 0 ) then
        aa( 1 ) = -s
        aa( 2 ) = -s
        aa( 3 ) = -s
        aa( 4 ) = -s
        aa( 1+mxllda ) = -c
        aa( 2+mxllda ) = -c
        aa( 3+mxllda ) = -c
        aa( 4+mxllda ) = c
        aa( 1+2*mxllda ) = a
        aa( 2+2*mxllda ) = a
        aa( 3+2*mxllda ) = a
        aa( 4+2*mxllda ) = -a
        aa( 1+3*mxllda ) = c
        aa( 2+3*mxllda ) = c
        aa( 3+3*mxllda ) = c
        aa( 4+3*mxllda ) = c
        b( 1 ) = 1
        b( 2 ) = 0
        b( 3 ) = 0
        b( 4 ) = 0
    else if( myrow == 1 .and. mycol == 1 ) then
        aa( 1 ) = a
        aa( 2 ) = -a
        aa( 3 ) = -a
        aa( 4 ) = -a
        aa( 1+mxllda ) = l
        aa( 2+mxllda ) = l
        aa( 3+mxllda ) = -l
        aa( 4+mxllda ) = -l
        aa( 1+2*mxllda ) = k
        aa( 2+2*mxllda ) = k
        aa( 3+2*mxllda ) = k
        aa( 4+2*mxllda ) = k
    else if( myrow == 1 .and. mycol == 2 ) then
        aa( 1 ) = a
        aa( 2 ) = a
        aa( 3 ) = -a
        aa( 4 ) = -a
        aa( 1+mxllda ) = p
        aa( 2+mxllda ) = p
        aa( 3+mxllda ) = -p
        aa( 4+mxllda ) = -p
    end if
end


subroutine sl_init( ictxt, nprow, npcol )
    !
    !     .. scalar arguments ..
    integer            ictxt, npcol, nprow
    !     ..
    !
    !  purpose
    !  =======
    !
    !  sl_init initializes an nprow x npcol process grid using a row-major
    !  ordering  of  the  processes. this routine retrieves a default system
    !  context  which  will  include all available processes. in addition it
    !  spawns the processes if needed.
    !
    !  arguments
    !  =========
    !
    !  ictxt   (global output) integer
    !          ictxt specifies the blacs context handle identifying the
    !          created process grid.  the context itself is global.
    !
    !  nprow   (global input) integer
    !          nprow specifies the number of process rows in the grid
    !          to be created.
    !
    !  npcol   (global input) integer
    !          npcol specifies the number of process columns in the grid
    !          to be created.
    !
    !  =====================================================================
    !
    !     .. local scalars ..
    integer            iam, nprocs
    !     ..
    !     .. external subroutines ..
    external           blacs_get, blacs_gridinit, blacs_pinfo,blacs_setup
    !     ..
    !     .. executable statements ..
    !
    !     get starting information
    !
    call blacs_pinfo( iam, nprocs )
    !
    !     if machine needs additional set up, do it now
    !
    if( nprocs<1 ) then
        if( iam == 0 )nprocs = nprow*npcol
        call blacs_setup( iam, nprocs )
    end if
    !
    !     define process grid
    !
    call blacs_get( -1, 0, ictxt )
    call blacs_gridinit( ictxt, 'row-major', nprow, npcol )
    !
    return
    !
    !     end of sl_init
    !
end
