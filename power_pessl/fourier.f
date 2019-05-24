!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    (C) COPYRIGHT IBM CORP. 1995. ALL RIGHTS RESERVED.               *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
      module fourier
!
!   Purpose: To represent both the diffusion operator and
!            the temperature profile in a sine function basis.
!
!   Routines called:
!     blacs_abort
!     clocal_to_rglobal
!     dcft2
!     igamx2d
!     initialize_carray
!     initialize_scale
!     pdcft2
!
      use parameters
      use scale
      use diffusion
      implicit none
      private
!
!     all entities private by default
!
      external pdcft2
!
!   publically available routines
!
      public expand_temp_profile, get_diffusion_matrix
      public g_index
!
!   publically available variables
!

!
!   private variables
!
      integer :: pn_fac(5) = 5*0  ! prime factors of number of nodes
!     nnodes = 2**pn_fac(1) * 3**pn_fac(2) * 5**pn_fac(3) *
!              7**pn_fac(4) * 11**pn_fac(5)

!
!   private routines
!
      private minpower2, factor_nodes
      contains

!****************************************************************************!
!*                                                                          *!
!*   Module routine get_diffusion_matrix                                    *!
!*                                                                          *!
!*   Purpose: To obtain the matrix representation of the diffusion          *!
!*            operator in a sine function basis                             *!
!*                                                                          *!
!****************************************************************************!
        subroutine get_diffusion_matrix(f,f_i, f_d)
!
!   Arguments:
!     f: real*8,dimension(:,:),(out), local part of the global matrix
!               containing the diffusion operator in sine function basis.
!     f_d: integer*4, dimension(:),(in), array descriptor for f.
!     f_i: g_type, (in), g_type structure for f, see parameter.f.
!
        real(long), intent(out) :: f(:,:)
        integer, intent(in) :: f_d(DESC_DIM)
        type (g_index), intent(in) :: f_i

! Local variables
!
!  df contains the diffusion coefficient before the call to pdcft2.
!  df contains the Fourier transpose of diffusion coefficients after the call.
!  dfg contains the entire Fourier transpose of df on each node.
!
        complex(long), pointer :: df(:,:)
        type (g_index), pointer :: df_i
        integer :: df_d(DESC_DIM)

        real(long), allocatable :: dfg(:,:)
!
!  ixi and iyi are arrays which, given a global index,
!  return the x and y offsets.  Recall that the large arrays
!  are 4 dimensional arrays collapsed into 2 dimensions,
!  where i = (ix-1)*dif_ny + iy.
!
        integer, allocatable :: ixi(:), iyi(:)
        real(long) :: scale_f
        integer :: nx, ny, ix, iy, ixp, iyp, istat, nerrs
        integer :: ixdiff, iydiff, num_errors
        integer :: naux1, naux2, i, j, factor1, factor2, idum
        integer :: ib, jb, il, jl
!
!  ip is a support array for pdcft2.
!
        integer :: ip(40)
        integer :: blk_index
!
!   Fourier transform of diffusion coefficient function
        nerrs=0

        call factor_nodes()
        factor1 = 3**pn_fac(2) * 5**pn_fac(3) * 7**pn_fac(4) *                 &
     &                           11**pn_fac(5)
!
!  Here we are trying to find the smallest number which is evenly
!  divisible by the number of processes and is larger than 4*(n+1).
!
        factor2 = (4*(dif_nx+1) + factor1 -1)/factor1
        nx = minpower2( factor2,idum) * factor1

        factor2 = (4*(dif_ny+1) + factor1 -1)/factor1
        ny = minpower2( factor2,idum) * factor1

        scale_f = 1.d0/ real(nx*ny, long)

!
!  Get storage for diffusion array.
!
        call  initialize_scale(ny, blk_index)
        call  initialize_carray(df, df_d, df_i, nx, ny,                        &
     &                          blk_index)
!
!    Here, we initialize the local part of the global array df, which
!    contains the value of the diffusion coefficient function, evenly
!    evaluated between (0, 2*pi).  We do a two dimensional Fourier
!    transform on the data.  Because the size of this array is so small,
!    nx by ny, and ultimately we have to transfer the whole array to 
!    each node, it would probably be more efficient to do the calculation
!    locally on each node.
!

!    Get the value of the diffusion coefficient function at
!    the necessary points.
!

!
!   This loop can be simplified considerably. Because blocks of the
!   array are column-distributed with the block size equal to the number
!   of columns divided by the number of processes, there is only a single
!   column block.  Also, because the processes are distributed in a 1 x np
!   arrangement, the local row index will equal the global row index.
!   However, the loop is perfectly general for other process arrangements
!   and is correct for this particular case.
!
        jl = 0
        do jb = 1, df_i%num_col_blks   ! loop over the number of column blocks
          do j = df_i%scb(jb), df_i%ecb(jb)
                           ! loop over columns in block
                           ! j is a global index
            jl = jl + 1    ! jl is local array column index
            il = 0
            do ib = 1, df_i%num_row_blks   ! loop over the number of row blocks
              do i = df_i%srb(ib),  df_i%erb(ib)
                           ! loop over rows in block
                           ! i is a global index
                il = il + 1    ! il is local array row index
                df(il,jl) = diff_coef((twopi*(i-1))/nx,                        &
     &                                   (twopi*(j-1))/ny)
              enddo
            enddo
          enddo
        enddo
!
!  This last loop just determined the diffusion coefficient at evenly
!  spaced points along the x and y coordinates.
!

!
!
!  Do the Fourier transform.
!
        do i= 1, 40
          ip(i) = 0
        enddo
!  Store the array in normal mode overwriting the original array.
        ip(1) = 1
        ip(2) = 1

!
! Because the size of the 2d Fourier transform is nx by ny, which is much
! smaller than the size of the eigenvalue problem, this could probably 
! be done serially on each node more quickly.
!
        call pdcft2(df, df, nx, ny, 1,scale_f, sc_icontext, ip)
!
!
!   df now has the Fourier coefficients for the diffusion coefficient 
!      function, which correspond to the D(tilde)(sub ij) given in the
!      discussion paper.
!   
!   Because each processor will need most of the Fourier transformed diffusion
!   coefficients, it is useful to broadcast all parts of this matrix
!   to each processor.
!
!  First allocate the index arrays.
!
        num_errors=0
        allocate(ixi(dif_nx*dif_ny), stat=istat)
        if( istat .ne. 0 ) num_errors = num_errors + 1
        allocate(iyi(dif_nx*dif_ny), stat=istat)
        if( istat .ne. 0 ) num_errors = num_errors + 1
!  Allocate array for holding global Fourier transform.
        allocate(dfg(nx,ny), stat = istat) 
        if( istat .ne. 0 ) num_errors = num_errors + 1

        call igamx2d(sc_icontext,'A',' ',1,1,num_errors,1,-1,-1,-1,            &
     &               -1,-1)
        if( num_errors .gt. 0 ) then
           if( sc_iam .eq. 0 ) then
               write(*,*) 'Error in allocating scratch arrays in ',            &
     &                     'get_diffusion_matrix'
               call blacs_abort(sc_icontext, 1)
           endif
        endif


        call clocal_to_rglobal( df, df_d, dfg )

!   Here df contains only local portions of the global array, while
!   dfg contains the entire global array.
!

!
!  Now load up the diffusion operator
!    f(ix,iy;ix',iy').
!    
!    Here we transform the 4d matrix into the 2d matrix where
!       i = (iy-1)* dif_nx + ix + 1  
!    and
!       j = (iy'-1)* dif_nx + ix' + 1.
!
!  First calculate the index arrays.
!
        do ix = 1, dif_nx
          do iy = 1, dif_ny
            i = (iy-1)* dif_nx + ix
            ixi(i) = ix
            iyi(i) = iy
          enddo
        enddo

!
! This final loop loads the matrix elements up for F as given in
! equation 10.
!
        jl = 0
        do jb = 1, f_i%num_col_blks   ! loop over the number of column blocks
          do j = f_i%scb(jb), f_i%ecb(jb)
                           ! loop over columns in block
                           ! j is a global index
            jl = jl + 1    ! jl is local array column index
            iyp = iyi(j)
            ixp = ixi(j)
            il = 0
            do ib = 1, f_i%num_row_blks   ! loop over the number of row blocks
              do i = f_i%srb(ib), f_i%erb(ib)
                           ! loop over rows in block
                           ! i is a global index
                il = il + 1    ! il is local array row index
                iy = iyi(i)
                ix = ixi(i)
                ixdiff = iabs(ix-ixp) + 1
                iydiff = iabs(iy-iyp) + 1
                f(il,jl) = ( ( ix*ixp + iy*iyp*dif_ly_ratio ) *                &
     &              (dfg(ixdiff, iydiff)    - dfg(ix+ixp+1,iy+iyp+1))          &
     &              +     ( ix*ixp - iy*iyp*dif_ly_ratio ) *                   &
     &              (dfg(ix+ixp+1,iydiff )  - dfg(ixdiff,iy+iyp+1)))           
              enddo
            enddo
          enddo
        enddo
        deallocate(dfg)
        deallocate(ixi)
        deallocate(iyi)
!
!   We should add routines to free df.
!
        return
        end subroutine get_diffusion_matrix

        

!****************************************************************************!
!*                                                                          *!
!*   Module routine expand_temp_profile                                     *!
!*                                                                          *!
!*   Purpose: To obtain the expansion coefficients of the initial           *!
!*            temperature profile in a sine function expansion              *!
!*                                                                          *!
!****************************************************************************!
        subroutine expand_temp_profile(a,a_i,a_d)
!
!   Arguments:
!     a: real*8,dimension(:,:),(out), local part of the global matrix,
!                  containing the sine coefficients for initial 
!                  temperature distribution.
!     a_d: integer*4, dimension(:),(in), array descriptor for a.
!     a_i: g_type, (in), g_type structure for a, see parameter.f.
!
        real(long), intent(out) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM)
        type (g_index), intent(in) :: a_i

! Local variables
        complex(long), allocatable :: atmp(:,:)
        real(long), allocatable :: aux1(:), aux2(:)
        integer :: i,j, nx, ny, istat, naux1, naux2, nerrs, jl
        integer :: idum, jb, jx, jy
        real(long) :: x, y, scale_f
        
!
!      Calculate the minimum power of 2 to hold twice the number of
!      Fourier coefficients as sine coefficients. The top half of the
!      Fourier coefficients will equal minus the bottom half because
!      we are forcing the temperature profile to be odd.
!
        nx = minpower2( 2*(dif_nx+1), idum)
        ny = minpower2( 2*(dif_ny+1), idum)
        scale_f = -twopi / real( nx*ny,long)

        nerrs = 0
!
!       Temperature profile allocation.
        allocate(atmp(nx,ny), stat=istat )
        if( istat .ne. 0 ) nerrs = nerrs + 1
!
!
        naux1 = 40000 + 2.28*( nx + ny)
        naux2 = 20000 + 66*( 256 + 2*max(nx , ny))
!
!  Allocate work storage.
        allocate(aux1(naux1), stat=istat)
        if( istat .ne. 0 ) nerrs = nerrs + 1
        allocate(aux2(naux2), stat=istat)
        if( istat .ne. 0 ) nerrs = nerrs + 1

!
!   Check for allocation errors.
!
        call igamx2d(sc_icontext,'A',' ',1,1,nerrs,1,-1,-1,-1,-1,-1)           
        if( nerrs .gt. 0 ) then
           if( sc_iam .eq. 0 ) then
               write(*,*) 'Error in allocating scratch arrays in ',            &
     &                     'expand_temp_profile'
               call blacs_abort(sc_icontext, 1)
           endif
        endif

!
!
!       Fill atmp with the initial temperatures.
!
!  atmp contains the initial temperature profile T(sub 0)(x,y) as used
!  in equation 5 in the discussion paper.
!
        do i = 1, nx
           do j = 1, ny
             atmp(i,j) = init_temp((twopi*(i-1))/nx, (twopi*(j-1))/ny)
           enddo
        enddo

!
!  Do the 2d Fourier transform of atmp.
!
!  First initialize.
!
!  The 2d Fourier transform can be done in parallel, however it
!  is such a small part of the problem, it is probably faster to do
!  it serially on each node.
!
!  Note that we could have used DSINF to obtain these expansion coefficients
!  as well.
!
        call dcft2(1,atmp,1,nx,atmp,1,nx,nx,ny,1,scale_f ,aux1,naux1,          &
     &               aux2,naux2 )
        call dcft2(0,atmp,1,nx,atmp,1,nx,nx,ny,1,scale_f ,aux1,naux1,          &
     &               aux2,naux2 )
!
! The calls to dcft2 calculated the dual Fourier transform as
! defined by equation 5 in the discussion paper.
!

!
!  This final loop is to load only those portions of the global array
!  corresponding to the local portion of that array for this processor.
!
        jl = 0
        do jb =  1, a_i%num_col_blks    ! loop over all column blocks
          do j = a_i%scb(jb),  a_i%ecb(jb)  ! j is global index
            jx = mod(j-1, dif_nx) + 2         
            jy = (j-1) / dif_nx + 2
            jl = jl + 1
            a(1,jl) = real(atmp(jx,jy),long)
          enddo
        enddo

        deallocate(atmp)
        deallocate(aux1)
        deallocate(aux2)
        return
        end subroutine expand_temp_profile


!****************************************************************************!
!*                                                                          *!
!*   Module routine factor_nodes                                            *!
!*                                                                          *!
!*   Purpose: To obtain the powers of prime factorization of the number     *!
!*            nodes, failing if the factorization is not compatible with    *!
!*            FFT supported transform lengths                               *!
!*                                                                          *!
!****************************************************************************!
        subroutine factor_nodes()
!  Arguments: None
!
!  Local variables
        integer n1, n2, l2
!
!   Determine the prime factorization of nnodes, which must
!       be of the form 2**n * 3**m * 5**i * 7**j * 11**k
!       where m cannot be greater than 2 and i, j, and k cannot
!       be greater than 1
!
        n2 = sc_nnodes
        n1 = n2/11
        if( n1*11 .eq. n2) then
            pn_fac(5) = 1
            n2 = n1
        endif

        n1 = n2/7
        if( n1*7 .eq. n2) then
            pn_fac(4) = 1
            n2 = n1
        endif
        
        n1 = n2/5
        if( n1*5 .eq. n2) then
            pn_fac(3) = 1
            n2 = n1
        endif
        
        n1 = n2/3
        if( n1*3 .eq. n2) then
          if ( (n1/3)*3 .eq. n1 ) then
            pn_fac(2) = 2
            n2 = n1/3
          else
            pn_fac(2) = 1
            n2 = n1
          endif
        endif
        
        n1 = minpower2(n2,l2)
        pn_fac(1) = l2

        if( n1 .ne. n2) then
          if( sc_iam .eq. 0) then
            write(*,*) 'Invalid number of nodes, it must have the form:'
            write(*,*) '2**n * 3**m * 5**i * 7**j * 11**k, where '
            write(*,*) ' n >= 0, 0<=m<=2 and 0<= i,j,k <=1 '
            write(*,*) ' choose a power of 2 for best performance'
            call blacs_abort(sc_icontext,1)
          endif
        endif
        end subroutine factor_nodes


!****************************************************************************!
!*                                                                          *!
!*   Module function minpower2                                              *!
!*                                                                          *!
!*   Purpose: To obtain the smallest number which is a power of 2 and       *!
!*            greater than or equal to the input argument                   *!
!*                                                                          *!
!****************************************************************************!
        function minpower2( n, log2n )
!
!   Arguments:
!      n: integer*4, (in), input number
!      log2n: integer*4, (out), log base 2 of the function result
!   Function return:
!      minpower2: integer*4 (out), smallest number, which is a power of 2 
!                 and greater than or equal to n.
!
        integer n, minpower2, log2n
!
!   Local variables.
        integer m, i
        m=n

        if( n < 0 ) write(*,*) 'n cannot be negative'
        powerloop: do i= 1, bit_size(n)
          m = m / 2
          if( m .eq. 0 ) exit powerloop
        enddo powerloop
        if ( 2**(i-1) .ne. n ) then
           if( 2**i < 0) write(*,*) 'n too large'
           log2n = i
           minpower2 = 2**i
        else
           log2n = i-1
           minpower2 = n
        endif
        return
        end function minpower2

      end module fourier
