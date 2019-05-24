!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1996. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
      module scatter_gather
      use pdata
      implicit none
!
        private

!
!  everything private by default
!

! This module provides generic interfaces for two routines
! scatter and gather. These have the following interfaces
!
!       subroutine scatter(a,a_d,a_glob,trow,tcol)
!
!       This subroutine will take a matrix, a_glob, on processor
!       (trow,tcol) and distribute it over all the participating
!       processors.
!
!        subroutine arguments:
!
!          a :: real or complex array, output, required
!            a is the distributed array into which the array a_glob is
!            scattered.
!
!         a_d :: integer, input,required
!            a_d is the descriptor array corresponding to a.
!
!         a_glob :: input, required, real or complex array
!            a_glob is the array with dimenssion (a_d(1),a_d(2))
!            containg all the pieces of a on input. The array
!            need only be nonzero size on the processor (trow,tcol)
!            from which it is scattered.
!
!         trow  :: input, required, integer
!            Processor row source of scattering matrix.
!
!         tcol  :: input, required, integer
!            Processor column source of scattering matrix.
!
! 
!       subroutine gather(a,a_d,a_glob,trow,tcol)
!
!       This subroutine will take a distibuted matrix, a, and gather
!       all of the pieces of the array into a single array on a
!       target processor.
!
!        subroutine arguments:
!
!          a :: real or complex array, input, required
!            a is the distributed array to be gathered.
!
!         a_d :: integer, input,required
!            a_d is the descriptor array corresponding to a.
!
!         a_glob :: output, required, real or complex array
!            a_glob is the array with dimenssion (a_d(1),a_d(2))
!            containg all the pieces of a on output. The array
!            need only be nonzero size on the processor (trow,tcol)
!            where it is gathered.
!
!         trow  :: input, required, integer
!            processor row where array is to be gathered
!
!         tcol  :: input, required, integer
!            processor column where array is to be gathered
!
!
!     Subroutines called:
!       dgesd2d   from blacs library
!       sgesd2d   from blacs library
!       zgesd2d   from blacs library
!       cgesd2d   from blacs library
!       dgerv2d   from blacs library
!       sgerv2d   from blacs library
!       zgerv2d   from blacs library
!       cgerv2d   from blacs library
!

        public :: dgather, sgather, cgather, zgather
        public :: dscatter, sscatter, cscatter, zscatter
        integer numroc
        external numroc
!
!
      contains

!****************************************************************************!
!*                                                                          *!
!*   Module routine dgather                                                 *!
!*                                                                          *!
!*   Purpose: Take the real parts of the local portions distibuted matrix   *!
!*            and gather them onto a single node                            *!
!*                                                                          *!
!****************************************************************************!
        subroutine dgather(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: real*8, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: real*8, dimension(:,:), entire matrix A on each node.
!

        real(long_t), intent(in) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        real(long_t), intent(out) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dgather, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the 
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'gather: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1
        else
          ldag=-1
          ldal = size(a, dim=1)
        endif

!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!
!  a is not big enough
!
          write(*,*)'gather: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif


     
!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
!  jg is global  row index
          jg = jb * nb + 1
!  nj is number of rows in current block
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
! jbl is local column block 
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
! jl is local column
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a_glob( ig+i-1, jg+j-1 ) = a( il+i-1, jl+j-1)
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call dgerv2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call dgesd2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine dgather

!****************************************************************************!
!*                                                                          *!
!*   Module routine sgather                                                 *!
!*                                                                          *!
!*   Purpose: Take the real parts of the local portions distibuted matrix   *!
!*            and gather them onto a single node                            *!
!*                                                                          *!
!****************************************************************************!

        subroutine sgather(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: real*4, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: real*4, dimension(:,:), entire matrix A on each node.
!

        real(short_t), intent(in) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        real(short_t), intent(out) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dgather, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
     
        if(myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'gather: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1

        else 
          ldag=-1
          ldal = size(a, dim=1)
        endif

!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'gather: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif



!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a_glob( ig+i-1, jg+j-1 ) = a( il+i-1, jl+j-1)
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call sgerv2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call sgesd2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine sgather

!****************************************************************************!
!*                                                                          *!
!*   Module routine cgather                                                 *!
!*                                                                          *!
!*   Purpose: Take the complex parts of the local portions distibuted matrix*!
!*            and gather them onto a single node                            *!
!*                                                                          *!
!****************************************************************************!

        subroutine cgather(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: complex*8, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: complex*8, dimension(:,:), entire matrix A on each node.
!

        complex(short_t), intent(in) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        complex(short_t), intent(out) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dgather, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'gather: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif

          ldag = size(a_glob, dim=1)
          ldal = -1
        else
          ldag=-1
          ldal = size(a, dim=1)
        endif
!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'gather: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif


!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a_glob( ig+i-1, jg+j-1 ) = a( il+i-1, jl+j-1)
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call cgerv2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call cgesd2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine cgather

!****************************************************************************!
!*                                                                          *!
!*   Module routine zgather                                                 *!
!*                                                                          *!
!*   Purpose: Take the complex parts of the local portions distibuted matrix*!
!*            and gather them onto a single node                            *!
!*                                                                          *!
!****************************************************************************!

        subroutine zgather(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: complex*16, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: complex*16, dimension(:,:), entire matrix A on each node.
!

        complex(long_t), intent(in) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        complex(long_t), intent(out) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dgather, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
     
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'gather: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1

        else
          ldag=-1
          ldal = size(a, dim=1)
        endif
!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'gather: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif


!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a_glob( ig+i-1, jg+j-1 ) = a( il+i-1, jl+j-1)
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call zgerv2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call zgesd2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine zgather

!****************************************************************************!
!*                                                                          *!
!*   Module routine dscatter                                                *!
!*                                                                          *!
!*   Purpose: Distribute an array to multiple nodes                         *!
!*                                                                          *!
!****************************************************************************!
        subroutine dscatter(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: real*8, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*u, array descriptor for a.
!     a_glob: real*8, dimension(:,:), entire matrix A on each node.
!

        real(long_t), intent(out) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        real(long_t), intent(in) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dscatter, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
     
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'scatter: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1

        else
          ldag=-1
          ldal = size(a, dim=1)
        endif
!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'scatter: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif


!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a( il+i-1, jl+j-1) = a_glob( ig+i-1, jg+j-1 )
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call dgesd2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call dgerv2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine dscatter

!****************************************************************************!
!*                                                                          *!
!*   Module routine sscatter                                                *!
!*                                                                          *!
!*   Purpose: Distribute an array to multiple nodes                         *!
!*                                                                          *!
!****************************************************************************!

        subroutine sscatter(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: real*4, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: real*4, dimension(:,:), entire matrix A on each node.
!

        real(short_t), intent(out) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        real(short_t), intent(in) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dscatter, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
     
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'scatter: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1

        else
          ldag=-1
          ldal = size(a, dim=1)
        endif
!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'scatter: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif

!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a( il+i-1, jl+j-1) = a_glob( ig+i-1, jg+j-1 )
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call sgesd2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call sgerv2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine sscatter

!****************************************************************************!
!*                                                                          *!
!*   Module routine cscatter                                                *!
!*                                                                          *!
!*   Purpose: Distribute an array to multiple nodes                         *!
!*                                                                          *!
!****************************************************************************!

        subroutine cscatter(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: complex*8, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: complex*8, dimension(:,:), entire matrix A on each node.
!

        complex(short_t), intent(out) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        complex(short_t), intent(in) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dscatter, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
     
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'scatter: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1

        else
          ldag=-1
          ldal = size(a, dim=1)
        endif
!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'scatter: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif


!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a( il+i-1, jl+j-1) = a_glob( ig+i-1, jg+j-1 )
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call cgesd2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call cgerv2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine cscatter

!****************************************************************************!
!*                                                                          *!
!*   Module routine zscatter                                                *!
!*                                                                          *!
!*   Purpose: Distribute an array to multiple nodes                         *!
!*                                                                          *!
!****************************************************************************!

        subroutine zscatter(a,a_d,a_glob,trow,tcol)
!
!    Arguments:
!     a: complex*16, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: complex*16, dimension(:,:), entire matrix A on each node.
!

        complex(long_t), intent(out) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM), trow, tcol
        complex(long_t), intent(in) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj, ldag, ldal
        integer :: nrows, ncols
!
!    m is number of rows in global matrix.
!    n is number of columns in global matrix.
!    mb and nb are rows and columns in each block.
!    prow and  pcol are the processor row and column containing a block.
!    ib, jb, ibl, jbl are global and local  block indices.
!    il, jl, ig, jg are local and global matrix indices.
!

!
!
!     Start of executable code.
!
!====================================================================
!

! Determine the total number of row and column blocks.
        m = a_d(M_)
        n = a_d(N_)
        mb = a_d(MB_)
        nb = a_d(NB_)
        iarow = a_d(RSRC_)
        iacol = a_d(CSRC_)
        nrow_blks =  ( m + mb -1 )/ mb
        ncol_blks = ( n + nb - 1 )/ nb
!
! Determine leading dimension of global array.
!

        if( (trow .lt.0 .or. trow .ge. nprows) .or.                            &
     &      (tcol .lt.0 .or. tcol .ge. npcols)) then
            write(*,*) 'ERROR in dscatter, invalid target processor'
            write(*,*) 'Target column = ', tcol
            write(*,*) 'Target row    = ', trow
            write(*,*) 'Number of rows and columns are ', nprows, npcols
            call blacs_abort(icontext,1)
        endif
     
        if( myrow. eq. trow .and. mycol .eq. tcol) then
!
!   check that the  target array is big enough to fit all of the
!   data
!
          if(size(a_glob,1).lt.m .or. size(a_glob,2) .lt.n) then
!
!                not big enough
            write(*,*)'scatter: global array not big enough'
            write(*,*)'size :: ',size(a_glob,1), size(a_glob,2)
            write(*,*)'required :: ', m, n
            call blacs_abort(icontext,1)
          endif
          ldag = size(a_glob, dim=1)
          ldal = -1

        else
          ldag=-1
          ldal = size(a, dim=1)
        endif
!
!  next determine that the local array is big enough
!
        nrows = numroc(m,mb,myrow,iarow,nprows)
        ncols = numroc(n,nb,mycol,iacol,npcols)
        if(size(a,1).lt.nrows .or. size(a,2) .lt.ncols) then
!         
!  a is not big enough
!
          write(*,*)'scatter: local array not big enough'
          write(*,*)'size :: ',size(a,1), size(a,2)
          write(*,*)'required :: ', nrows, ncols
          call blacs_abort(icontext,1)
        endif

!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = (jb - mod(mycol+npcols-iacol,npcols))/npcols
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcols )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = (ib - mod(myrow+nprows-iarow,nprows))/nprows
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprows )
!
!   Determine if I am target
!
            if( trow .eq. myrow .and. tcol .eq. mycol) then  ! Iam the target
!
!   Determine this block is my bloc
               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Copy the block to my processor
!
                 do j = 1, nj
                    do i  = 1, ni
                       a( il+i-1, jl+j-1) = a_glob( ig+i-1, jg+j-1 )
                    enddo
                 enddo
               else  ! Iam target but this block isn't on the target
!
!  send to the block to the target
!
                 call zgesd2d(icontext,ni,nj,a_glob(ig,jg),                   &
     &                     ldag, prow, pcol)

               endif
            else   ! I'm not the target

               if( myrow .eq. prow .and. mycol .eq. pcol ) then
!
!  Block is on my processor, send it to the target
!
!
                 call zgerv2d(icontext,ni,nj,a(il,jl),ldal,trow,tcol)
               endif
            endif
            
          enddo
        enddo

        return
        end subroutine zscatter

      end module scatter_gather

