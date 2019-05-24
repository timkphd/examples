!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    5765-C41                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1997. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
        program main
!
!   Purpose, to  find the cooling rate for a specified set of
!   points in an anisotropic rectangular beam, immersed in a constant
!   heat bath with a temperature of 0.  
!
!   Routines called:
!     expand_temp_profile
!     get_diffusion_matrix
!     igamx2d
!     init_diffusion
!     initialize_rarray
!     initialize_scale
!     pdgemv
!     pdsyevx
!     rlocal_to_rglobal
!
        use parameters
        use scale
        use diffusion
        use fourier
        implicit none
        
        integer :: n, ix, jx, iy, jy, k, i, j, stat, it, ib, ig
        integer :: num_errors, lwork, ilwork
        integer, allocatable :: iwork(:)
        real(long), allocatable :: work(:)
!
!       a contains the sine expansion coefficients of the initial
!                temperature profile.
!       b contains the eigenvectors of the diffusion operator in the
!                sine function basis.
!       ab contains the initial temperature profile expanded in the
!                eigenvectors of the diffusion operator.
!       f contains the matrix elements of the diffusion operation in
!                sine function basis.
!       lambda contains the eigenvalues of the diffusion operator.
!
!       df contains the Fourier transform of the diffusion coefficient function.
!
        real(long), allocatable ::  lambda(:), xg(:,:)
        real(long), allocatable ::  gap(:)
        real(long) :: dum

        real(long), pointer :: f(:,:), b(:,:), a(:,:)
        type (g_index), pointer :: f_i, b_i, a_i
        integer :: f_d(DESC_DIM), b_d(DESC_DIM), a_d(DESC_DIM)

        real(long), pointer :: x(:,:), ab(:,:), abt(:,:)
        type (g_index), pointer :: x_i, ab_i, abt_i
        integer :: x_d(DESC_DIM), ab_d(DESC_DIM), abt_d(DESC_DIM)

        real(long), allocatable :: xsines(:,:), ysines(:,:), temp(:,:)
        integer, allocatable :: ifail(:), iclustr(:)
        integer :: biga_index, num_eigvalues, num_vectors, info
        

!
!   Read in the problem size, initialize the problem dimensions,
!   choose functional form for the spatially dependent heat diffusion
!   coefficients, choose funtional form of initial temperature distribution
!   and choose the number of points, in both space and time, of the solution
!   to print out.
!
        call init_diffusion
        num_errors = 0
!
!       Read in how many sine functions to include in both the
!            x and y directions.
!
!       Because we need to get the Fourier coefficients of the sums
!       and differences of the indices, we need to include twice as
!       many Fourier coefficients as the number of sine expansion coefficients.
!       Also, because the top and bottom halves of the Fourier 
!       transform are identical,
!       an artifact of artificially extending the diffusion coefficient
!       function and the initial temperature distribution, we need to
!       double the number of Fourier coefficients again. Finally, the
!       extra sum of one comes from the fact that the sine function 
!       expansion starts a 1 and the Fourier expansion starts at 0.
!
 
!  n is the order of the diffusion operator equation.
        n = dif_nx * dif_ny
!
!  Initialize BLACS and calculate default block sizes.
!
        call initialize_scale(n, biga_index)


!
!
!   Allocate room for the eigenvalues of diffusion operator.
!
        allocate( lambda(n), stat=stat)
        if( stat .ne. 0) num_errors = num_errors + 1

!
!   Allocate room for sines of x and y coordinates.
!
        allocate( xsines(dif_npts, dif_nx) , stat=stat )
        if( stat .ne. 0) num_errors = num_errors + 1

        allocate( ysines(dif_npts, dif_ny) , stat=stat )
        if( stat .ne. 0) num_errors = num_errors + 1

!
!   Allocate room for temperature history at selected points.
!
        allocate( temp(dif_npts, dif_ntemps) , stat=stat )
        if( stat .ne. 0) num_errors = num_errors + 1

!
!   Allocate room for global temperature profile expansion vector at time t.
!
        allocate( xg(1, n) , stat=stat )
        if( stat .ne. 0) num_errors = num_errors + 1

        call igamx2d(sc_icontext,'A',' ',1,1,num_errors,1,-1,-1,-1,            &
     &               -1,-1)
        if( num_errors .gt. 0 ) then
           if( sc_iam .eq. 0 ) then
               write(*,*) 'Error in allocating arrays in main'
               call blacs_abort(sc_icontext, 1)
           endif
        endif


!
!      A call to expand_temp_profile returns the sine expansion
!      coefficients of the initial temperature profile.
!
!
!  Get matrices.
!
!  Diffusion operator matrix.
        call initialize_rarray(f, f_d, f_i, n, n, biga_index)

!  Eigenvectors of diffusion operator matrix.
        call initialize_rarray(b, b_d, b_i, n, n, biga_index)

!  Initial temperature profile, in row vector.
        call initialize_rarray(a, a_d, a_i, 1, n, biga_index)

!  Initial temperature profile, in eigenfunction basis, in row vector.
        call initialize_rarray(ab, ab_d, ab_i, 1, n, biga_index)

!  Temperature profile, at time t, in eigenfunction basis, in row vector.
        call initialize_rarray(abt, abt_d, abt_i, 1, n, biga_index)

!  Temperarure profile in at time t in sine expansion basis, in row vector.
        call initialize_rarray(x, x_d, x_i, 1, n, biga_index)

!
!  Represent initial temperature in sine function expansion.
!
        call expand_temp_profile(a,a_i,a_d)
!
!  Here, we are calculating the initial set of coefficients
!  in the sine function expansion as given in equations 3 and 4 of
!  the discussion paper
!

!
!       The call to get_diffusion_matrix returns the diffusion
!        operator in the sine function basis.
!
        call get_diffusion_matrix(f,f_i,f_d)
!
!   This last call determines the matrix elements defined by equation 10
!   in the discussion paper.
!


!    
!    Here we precalculate the sine functions, sin(kx) and sin(jy) used
!    in equation 13 of the discussion paper.
!    These sine functions are only evaluated at the points x and y for
!    which the solution is evaluated.
!

        do i = 1, dif_nx
          do j = 1, dif_npts
            xsines(j,i) = sqrt(2.d0/pi) * sin( i * dif_x(j))
          enddo
        enddo

        do i = 1, dif_ny
          do j = 1, dif_npts
            ysines(j,i) = sqrt(2.d0/pi) * sin( i * dif_y(j))
          enddo
        enddo


!
!  Allocate arrays for eigenvalue decomposition.
!
        allocate( ifail(n), stat=stat)
        if( stat .ne. 0) num_errors = num_errors + 1
        allocate( iclustr(n), stat=stat)
        if( stat .ne. 0) num_errors = num_errors + 1
        allocate( gap(sc_nnodes), stat=stat)
        if( stat .ne. 0) num_errors = num_errors + 1

!
!  Allocate scratch space for the symetric eigenvector solver.
!
        lwork = 20*n  + max( 5*n, n*(n+ sc_nnodes-1)/sc_nnodes )               &
     &         + n*( (n+ sc_nnodes-1)/sc_nnodes) + 2*f_d(MB_) * f_d(MB_)
 
        ilwork = 2*n + max((3*n+1+sc_nnodes),max(4*n,14))

        allocate( work(lwork) , stat=stat )
        if( stat .ne. 0) num_errors = num_errors + 1
        allocate( iwork(ilwork) , stat=stat )
        if( stat .ne. 0) num_errors = num_errors + 1

!
!   Test to see if we had any allocation errors.
!

        call igamx2d(sc_icontext,'A',' ',1,1,num_errors,1,-1,-1,-1,            &
     &               -1,-1)
        if( num_errors .gt. 0 ) then
           if( sc_iam .eq. 0 ) then
               write(*,*) 'Error in allocating arrays for pdsyevx in ',        &
     &                     'main'
               call blacs_abort(sc_icontext, 1)
           endif
        endif

        do i = 1, sc_nnodes
           gap(i) = 0.d0
        enddo
        do i = 1, n
           ifail(i) = 0
           iclustr(i) = 0
        enddo
!
! The call to pdsyevx will find both the eigenvalues and eigenvectors
! of the diffusion matrix operator f. The eigenvalues will be stored in
! the vector lambda and the corresponding eigenvectors will be stored in
! the matrix b.  The f and b matrices in the program correspond to the
! F and B matrices in equations 11 and 12 in the
! discussion paper.
!
!
        call pdsyevx('V','A','U',n,f,1,1,f_d,-1.d30,1.d30,0,n,                 &
     &        0.d0,num_eigvalues,num_vectors,lambda,1.d-5,b,1,1,b_d,           &
     &        work, lwork, iwork, ilwork, ifail, iclustr, gap, info)
        
        if( sc_iam .eq. 0) then
          if( info .ne. 0 ) then
             write(*,*) ' info is ', info
             call blacs_abort(sc_icontext, 1)
          endif
        endif
!
!       Multiply the transpose of the eigenvector matrix, b, with the sine
!       expansion of the initial temperature profile, a, to obtain the
!       initial temperature profile in terms of the eigenfunctions of the
!       diffusion operator.
!
        call pdgemv('T', n, n, 1.d0, b, 1, 1, b_d, a, 1, 1, a_d, 1,            &
     &              0.d0, ab, 1, 1, ab_d, 1)
!
!  This first matrix multiplication, yielding the matrix ab,
!  corresponds to the inner summation in equation 10 
!  of the discussion paper.
!

!
!    Calculate temperature profile for each time step.
!
        do it = 1, dif_ntemps     
          i = 0
          do ib = 1, ab_i%num_col_blks
            do ig = ab_i%scb(ib), ab_i%ecb(ib)
              i = i + 1
              abt(1,i) = exp( -lambda(ig) * it * dif_delta_t) * ab(1,i)
            enddo
          enddo
!
!   abt now has the expansion of the temperature profile in terms of the
!   eigenvectors of the diffusion operator.
!

!
!   Multiply the eigenvector matrix with abt to give the sine function
!   expansion of the temperature profile at time t, x.
!
          call pdgemv('N', n, n, 1.d0, b, 1, 1, b_d, abt, 1, 1, abt_d,         &
     &              1, 0.d0, x, 1, 1, x_d, 1)
!  This last sum corresponds to the outer sum of equation 12, where the
!  time dependent expansion coefficients a{sub l}(t) are stored in the
!  temporary array x in the program.
!

!
!   Gather all of the local pieces of the array x to the array xg.
!
          call rlocal_to_rglobal(x, x_d, xg )

          do k = 1, dif_npts
            temp(k, it) = 0.d0
          enddo

          do iy = 1, dif_ny
            do ix = 1, dif_nx
              i = (iy -1) * dif_nx + ix
              do k = 1, dif_npts
                temp(k,it) = temp(k,it) + xsines(k,ix) * ysines(k,iy)          &
     &                       * xg(1,i)
              enddo
            enddo
          enddo
!
!  This last do loop corresponds to the double summation in equation
!  13 of the discussion paper.
!

        enddo  ! end of time loop


!
!   Here, we are just writing out the temperatures at the selected times
!   and points.
!
        if( sc_iam .eq. 0 ) then    ! if I am node 0 
           write(*,*) '   point #      X         Y'
           do i = 1, dif_npts
             write(*,'(2x, i6, 2x, 2f11.4)') i, dif_x(i), dif_y(i)
           enddo
           write(*,*)
           do k = 1, dif_npts, 6
             write(*,*)
             write(*,'(30X,''Points'')')
             write(*,'(''   TIME   '',6(5x,''#'', i4))') (i, i=k, k+5)
             do i = 1, dif_ntemps
                write(*,'(7f10.5)') i*dif_delta_t,                             &
     &                          (temp(j,i),j=k,min(k+5,dif_npts))
             enddo
          enddo
        endif

        deallocate(xg)
        deallocate(xsines)
        deallocate(ysines)
        deallocate(lambda)
        deallocate(temp)
        deallocate( ifail)
        deallocate( iclustr)
        deallocate( gap)
        call blacs_exit(0)
        stop
        end

