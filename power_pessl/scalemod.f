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
      module scale
!
!  Purpose: To initialize the communications and provide a few
!           communication utility routines.
!
!  Routines called:
!    blacs_abort
!    blacs_get
!    blacs_gridinfo
!    blacs_gridinit
!    blacs_pinfo
!    dgebr2d
!    dgebs2d
!    numroc
!
        use parameters
        implicit none
        external numroc
!
!  All variables private by default.
!
        private
!
!   Publically accessible routines follow.
!
        public initialize_scale
        public initialize_rarray, initialize_carray
        public clocal_to_rglobal, rlocal_to_rglobal
        public g_index

!
!   Public variables follow.
!
        integer, public :: sc_icontext, sc_iam, sc_nnodes

!
!   Private variables follow.
!
!   MAXBLOCK is the maximum block size. Here it is set to a very
!            large number to force an equal noncyclic block distribution
!            for the FFTs.
!
!
        integer, public, parameter :: MAXBLOCK=50000
        integer, public, parameter :: MAX_SC_INDEX=10
        integer, public, parameter :: DESC_DIM=9
        integer, public, parameter :: DTYPE_=1
        integer, public, parameter :: CTXT_=2
        integer, public, parameter :: M_=3
        integer, public, parameter :: N_=4
        integer, public, parameter :: MB_=5
        integer, public, parameter :: NB_=6
        integer, public, parameter :: RSRC_=7
        integer, public, parameter :: CSRC_=8
        integer, public, parameter :: LLD_=9
        integer :: numroc
        integer :: nprow, npcol, myrow, mycol
!
!  The block sizes for a given array size are indexed in the 
!  nblock, mblock and nsize arrays so that, for a given array size,
!  the block size calculation is done only once and exactly the same
!  block sizes are returned for any particular array size.
!
        integer :: nblock(MAX_SC_INDEX), mblock(MAX_SC_INDEX)
        integer :: nsize(MAX_SC_INDEX)
!
!  The number of different array sizes is limited by the fixed 
!  dimension of the arrays nblock, mblock and nsize.
!
        integer :: icontext, iam, nnodes
        integer, save :: sc_indx=0
        integer, parameter :: rsrc=0, csrc=0
        logical, save :: initialized = .false.
!
!  All of the manipulation of the PESSL and SP variables will be
!  done in this module and held privately.
!
      contains

!****************************************************************************!
!*                                                                          *!
!*   Module routine initialize_scale                                        *!
!*                                                                          *!
!*   Purpose: Initialize blacs and calculate a block size                   *!
!*                                                                          *!
!****************************************************************************!
        subroutine initialize_scale (n, index)
!
!     Arguments:
!       n: integer*4 (in), matrix or vector size.
!       index: integer*4 (out), index into an array of block sizes.
!              Provides a mechanism for creating similar descriptor arrays.
!

!
!  This routine assigns the block size based on a given
!  n and returns an index, so that multiple arrays can be created with
!  compatible block sizes.
!
        integer n, index
        integer  npc, npr, i
        
        if ( .not. initialized ) then
          call blacs_pinfo( iam, nnodes )
          sc_iam = iam
          sc_nnodes = nnodes
!
!      Get the number of nodes.
!

!
!   The Fourier transform routines require that the processors 
!   be laid out in a 1 by nnodes arrangement.
!
          nprow = 1
          npcol = nnodes 
        
          call blacs_get(0,0,icontext)
          sc_icontext = icontext
          call blacs_gridinit( icontext, 'R', nprow, npcol)
          sc_icontext = icontext
          call blacs_gridinfo( icontext, npr, npc, myrow, mycol)
!
!      Check that the system is gridded as expected.
!
          if( npr .ne. nprow .or. npc .ne. npcol) then
            if( iam .eq. 0) then
              write(*,*) 'number of processor rows and columns' 
              write(*,*) 'incorrect ', nprow, npr, npcol, npc
              call blacs_abort(icontext,1)
            endif
          endif
          initialized = .true.
        endif
        
!
!  If we have already calculated a block size based on estimated
!  array size, return the index for that block size.
!
        do i = 1, sc_indx
           if( n .eq. nsize(i)) then
              index = i
              return
           endif
        enddo
        
!
!     Compute a block size.
!
        sc_indx = sc_indx + 1
        if ( sc_indx .GT. MAX_SC_INDEX ) then
          if( iam .eq. 0 ) then
            write(*,*) 'Used more than the maximum number of '
            write(*,*) 'indices in initialize_scale, Maximum is ',             &
     &                  MAX_SC_INDEX 
            call blacs_abort(icontext,1)
          endif
        endif
                
        index = sc_indx
        nsize(index) = n
        
!
!  Always choose a square block with a maximum dimension of MAXBLOCK.
!
        if( ( n ) / nnodes .gt. MAXBLOCK ) then
            mblock(index) = MAXBLOCK
        else
            mblock(index) = (n ) / nnodes 
        endif
        if( mblock(index) .lt. 1 ) then
            if( iam .eq. 0 ) then
              write(*,*) 'problem size too small for number of nodes'
              write(*,*) 'try increasing the nx and ny'
              write(*,*) n, nnodes
              call blacs_abort(sc_icontext, 1)
            endif
        endif
        nblock(index) = mblock(index)
        
        return
        end subroutine initialize_scale


!
!   This routine is provided to allocate dynamically the space
!   needed for the local part of a global array and initialize the
!   associated array descriptor.  It also returns array-useful
!   indices to do local to global index conversion.
!
!  initialize_rarray => real array initialization.
!  initialize_carray => complex array initialization.
!

!****************************************************************************!
!*                                                                          *!
!*   Module routine initialize_rarray                                       *!
!*                                                                          *!
!*   Purpose: Allocate space for a real array and create associated         *!
!*            descriptor array and index array                              *!
!*                                                                          *!
!****************************************************************************!
        subroutine initialize_rarray( array, desc_array,                       &
     &                               index_array, m, n, blk_index)
!
!    Arguments:
!       array: pointer to real*8 (out), pointer to real array, initialized.
!       desc_array: integer*4 (out), empty disciptor array, initialized.
!       index_array: g_index (out), pointer to g_index structure,
!                   see parameter.f, initialized.
!       m: integer*4 (out), scalar number of rows in global array.
!       n: integer*4 (out), scalar number of columns in global array.
!       blk_index: integer*4 (in), index into array of block sizes to use
!                   for initializing the descriptor array.
!
        integer, intent(out) :: desc_array(DESC_DIM)
        integer, intent(in) :: m, n, blk_index
        type (g_index), pointer :: index_array
        real(long), pointer :: array(:,:)

! Local variables
        integer :: irows, icols, istat, i, j
        integer :: start_row_block, start_col_block
        integer :: mb, nb, num_mb, num_nb

!
!   Check to see if the block sizes were already calculated.
!
        if ( blk_index .lt.1 .or. blk_index .gt. sc_indx ) then
           if( iam .eq. 0 ) then
              write(*,*) 'No initialization done for index ', blk_index
              call blacs_abort(icontext, 1)
           endif
        endif

        mb = mblock(blk_index)
        nb = nblock(blk_index)

        irows = numroc( m, mb, myrow, rsrc, nprow )
        icols = numroc( n, nb, mycol, csrc, npcol )
        
        allocate(array(max(irows,1),max(icols,1)), stat=istat)
        if ( istat .ne. 0) then
           write(*,*) 'allocate failed in initialize_array'
           call blacs_abort(icontext,1)
        endif

!
!   Calculate the number of row and column blocks.
!
        num_mb = ( (irows + mb -1)/ mb )
        num_nb = ( (icols + nb -1)/ nb )
          
        allocate (index_array)
        index_array%num_row_blks = num_mb
        index_array%num_col_blks = num_nb

        allocate(index_array%srb(num_mb))
        allocate(index_array%erb(num_mb))
        allocate(index_array%scb(num_nb))
        allocate(index_array%ecb(num_nb))
          
        desc_array(DTYPE_) = 1
        desc_array(M_) = m
        desc_array(N_) = n
        desc_array(MB_) = mb
        desc_array(NB_) = nb
        desc_array(RSRC_) = rsrc
        desc_array(CSRC_) = csrc
        desc_array(CTXT_) = icontext
        desc_array(LLD_) = max(irows,1)

!
        start_row_block = mod( nprow + myrow - rsrc , nprow )
        start_col_block = mod( npcol + mycol - csrc , npcol )

        do i = 1, index_array%num_row_blks
          index_array%srb(i) = (start_row_block + (i - 1)*nprow) *             &
     &                       mb+1
          index_array%erb(i) = index_array%srb(i) + mb - 1
        enddo
        index_array%erb(num_mb) = mod(irows-1,mb) +                            &
     &                              index_array%srb(num_mb) 

        do i = 1, index_array%num_col_blks
          index_array%scb(i) = (start_col_block + (i - 1)*npcol) *             &
     &                          nb + 1
          index_array%ecb(i) = index_array%scb(i) + nb - 1
        enddo
        index_array%ecb(num_nb) = mod(icols-1,nb) +                            &
     &                              index_array%scb(num_nb) 


        end subroutine initialize_rarray
         
! Complex array initialization.
! 
!****************************************************************************!
!*                                                                          *!
!*   Module routine initialize_carray                                       *!
!*                                                                          *!
!*   Purpose: Allocate space for a complex array and create associated      *!
!*            descriptor array and index array                              *!
!*                                                                          *!
!****************************************************************************!
        subroutine initialize_carray( array, desc_array,                       &
     &                               index_array, m, n, blk_index)
!
!    Arguments:
!       array: pointer to complex (out), pointer to real array, initialized.
!       desc_array: integer*4 (out), empty disciptor array, initialized.
!       index_array: g_index (out), pointer to g_index structure,
!                   see parameter.f, initialized.
!       m: integer*4 (out), scalar number of rows in global array.
!       n: integer*4 (out), scalar number of columns in global array.
!       blk_index: integer*4 (in), index into array of block sizes to use
!                   for initializing the descriptor array.
!
        integer desc_array(DESC_DIM), m, n, blk_index
        type (g_index),pointer :: index_array
        complex(long), pointer :: array(:,:)


! Local variables
        integer :: irows, icols, istat, i, j
        integer :: start_row_block, start_col_block
        integer :: mb, nb, num_mb, num_nb

!
!   Check to see if the block sizes were already calculated.
!
        if ( blk_index .lt.1 .or. blk_index .gt. sc_indx ) then
           if( iam .eq. 0 ) then
              write(*,*) 'No initialization done for index ', blk_index
              call blacs_abort(icontext, 1)
           endif
        endif

        mb = mblock(blk_index)
        nb = nblock(blk_index)

        irows = numroc( m, mb, myrow, rsrc, nprow )
        icols = numroc( n, nb, mycol, csrc, npcol )
        
        allocate(array(max(irows,1),max(icols,1)), stat=istat)
        if ( istat .ne. 0) then
           write(*,*) 'allocate failed in initialize_array'
           call blacs_abort(icontext,1)
        endif


!
!   Calculate the number of row and column blocks.
!
        num_mb = ( (irows + mb -1)/ mb )
        num_nb = ( (icols + nb -1)/ nb )
          
        allocate(index_array, stat=istat)
        if ( istat .ne. 0) then
           write(*,*) 'allocate failed in initialize_array'
           call blacs_abort(icontext,1)
        endif

        index_array%num_row_blks = num_mb
        index_array%num_col_blks = num_nb

        allocate(index_array%srb(num_mb))
        allocate(index_array%erb(num_mb))
        allocate(index_array%scb(num_nb))
        allocate(index_array%ecb(num_nb))


          
        desc_array(DTYPE_) = 1
        desc_array(M_) = m
        desc_array(N_) = n
        desc_array(MB_) = mb
        desc_array(NB_) = nb
        desc_array(RSRC_) = rsrc
        desc_array(CSRC_) = csrc
        desc_array(CTXT_) = icontext
        desc_array(LLD_) = max(irows,1)


!
        start_row_block = mod( nprow + myrow - rsrc , nprow )
        start_col_block = mod( npcol + mycol - csrc , npcol )


        do i = 1, index_array%num_row_blks
          index_array%srb(i) = (start_row_block + (i - 1)*nprow) *             &
     &                       mb+1
          index_array%erb(i) = index_array%srb(i) + mb - 1
        enddo
        index_array%erb(num_mb) = mod(irows-1,mb) +                            &
     &                              index_array%srb(num_mb)

        do i = 1, index_array%num_col_blks
          index_array%scb(i) = (start_col_block + (i - 1)*npcol) *             &
     &                          nb + 1
          index_array%ecb(i) = index_array%scb(i) + nb - 1
        enddo
        index_array%ecb(num_nb) = mod(icols-1,nb) +                            &
     &                              index_array%scb(num_nb)

        end subroutine initialize_carray
         

!
!****************************************************************************!
!*                                                                          *!
!*   Module routine clocal_to_rglobal                                       *!
!*                                                                          *!
!*   Purpose: Take the real parts of the local portions of a complex matrix *!
!*            and distribute them globally to each node                     *!
!*                                                                          *!
!****************************************************************************!
        subroutine clocal_to_rglobal(a,a_d,a_glob)
!
!    Arguments:
!     a: complex*16, dimension(:,:), is the local part of a 
!                                    global complex array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: real*8, dimension(:,:), entire matrix A on each node.
!

        complex(long), intent(in) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM)
        real(long), intent(out) :: a_glob(:,:)
!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, lda, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj
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
        lda = size(a_glob, dim=1)
     
!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices.
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = ( jb + iacol ) / npcol  - (mycol + iacol) / npcol 
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcol )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = ( ib + iarow ) / nprow - (myrow + iarow) /nprow
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprow )
!
!   Determine if this block is on my processor.
!
            if( prow .eq. myrow .and. pcol .eq. mycol) then
!
!   Block is on my processor.
!
!   using Fortran 90 array language this is
!       a_glob(ig:ig+ni-1,jg:jg+nj-1) = a(il:il+ni-1:jl+nj-1)
!
              do j = 1, nj
                 do i  = 1, ni
                    a_glob( ig+i-1, jg+j-1 ) = a( il+i-1, jl+j-1)
                 enddo
              enddo
              call dgebs2d(icontext,'ALL',' ',ni,nj,a_glob(ig,jg),lda)
            else
!
!   Block is on somebody elses processor.
!
              call dgebr2d(icontext,'ALL',' ',ni,nj,a_glob(ig,jg),             &
     &                     lda, prow, pcol)
            endif
            
          enddo
        enddo

        return
        end subroutine clocal_to_rglobal


!****************************************************************************!
!*                                                                          *!
!*   Module routine rlocal_to_rglobal                                       *!
!*                                                                          *!
!*   Purpose: Take the local portions of a real matrix                      *!
!*            and distribute them globally to each node                     *!
!*                                                                          *!
!****************************************************************************!
        subroutine rlocal_to_rglobal(a,a_d,a_glob)
!
!    Arguments:
!     a: real*8, dimension(:,:), is the local part of a global real array.
!     a_d: integer*4, array descriptor for a.
!     a_glob: real*8, dimension(:,:), entire matrix A on each node.
!
!   Input arguments.
!
        real(long), intent(in) :: a(:,:)
        integer, intent(in) :: a_d(DESC_DIM)
        real(long), intent(out) :: a_glob(:,:)

!
!    Local variables.
!
        integer :: nrow_blks, ncol_blks, ib, jb, ibl, jbl, i, j
        integer :: m, n, nb, mb, ig, jg, lda, il, jl, prow, pcol
        integer :: iarow, iacol, ni, nj
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
        lda = size(a_glob, dim=1)
     
!
!  Loop over all of the blocks.
!
        do jb = 0, ncol_blks - 1
!
!  Loop over column blocks, determining both local and global j indices
          jg = jb * nb + 1
          nj = nb
          if (jb .eq. ncol_blks - 1) nj = mod( n - 1, nb) + 1
          jbl = ( jb + iacol ) / npcol  - (mycol + iacol) / npcol 
          jl = jbl * nb + 1
          pcol = mod((jb + iacol), npcol )

          do ib = 0, nrow_blks - 1
!
!  Loop over row blocks, determining both local and global i indices.
            ig = ib * mb + 1
            ni = mb
            if (ib .eq. nrow_blks - 1) ni = mod( m - 1, mb) + 1
            ibl = ( ib + iarow ) / nprow - (myrow + iarow) /nprow
            il = ibl * mb  + 1
            prow = mod((ib + iarow), nprow )
!
!   Determine if this block is on my processor.
!
            if( prow .eq. myrow .and. pcol .eq. mycol) then
!
!   Block is on my processor.
!
              do j = 1, nj
                 do i  = 1, ni
                    a_glob( ig+i-1, jg+j-1 ) = a( il+i-1, jl+j-1)
                 enddo
              enddo
              call dgebs2d(icontext,'ALL',' ',ni,nj,a_glob(ig,jg),lda)
            else
!
!   Block is on somebody elses processor.
!
              call dgebr2d(icontext,'ALL',' ',ni,nj,a_glob(ig,jg),             &
     &                     lda, prow, pcol)
            endif
            
          enddo
        enddo

        return
        end subroutine rlocal_to_rglobal

      end module scale

