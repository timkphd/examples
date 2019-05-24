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
      module parameters
!
!   Purpose: Define system wide parameters and pessl structure.
!
        implicit none
        public
        integer, parameter :: long=8, short=4
        real(long), parameter :: pi = 3.141592653589793d0
        real(long), parameter :: twopi = 2.d0*pi

        type g_index
         integer :: num_row_blks, num_col_blks
         integer, pointer :: srb(:), scb(:), erb(:), ecb(:)
        end type g_index
!
!  The g_index type was created for convenience
!     components:
!        num_row_blks: number of block repetitions over matrix rows.
!        num_col_blks: number of block repetitions over matrix columns.
!        srb: global row index at start of a block
!             corresponding local index is ( block # -1) * mb
!             where mb is the number of rows in the block.
!
!        scb: global column index at start of a block
!             corresponding local index is ( block # -1) * nb
!             where nb is the number of columns in the block.
!        
!        erb: last global row index in the block.
!        ecb: last global column index in the block.
        public g_index

      end module parameters

