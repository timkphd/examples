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
      module pdata
      implicit none
      public

!  declare long and short kinds
        integer, public, parameter :: long_t = kind(1.d0)
        integer, public, parameter :: short_t = kind(1.e0)
        integer, public, parameter :: DESC_OFFSET = 0
        integer, public, parameter :: DTYPE_ = DESC_OFFSET + 1
        integer, public, parameter :: CTXT_ = DESC_OFFSET + 2
        integer, public, parameter :: M_ = DESC_OFFSET + 3
        integer, public, parameter :: N_ = DESC_OFFSET + 4
        integer, public, parameter :: MB_ = DESC_OFFSET + 5
        integer, public, parameter :: NB_ = DESC_OFFSET + 6
        integer, public, parameter :: RSRC_ = DESC_OFFSET + 7
        integer, public, parameter :: CSRC_ = DESC_OFFSET + 8
        integer, public, parameter :: LLD_ = DESC_OFFSET + 9
        integer, public, parameter :: DESC_DIM=9+DESC_OFFSET
        integer, public, parameter :: CREATE_BLOCK=1
        integer, public, parameter :: CREATE_CYCLIC=2
        integer, public, parameter :: TWO_D_TYPE=1

!
! error return codes
!
     
      integer, public     :: icontext=-1
      logical, public     :: initialized = .false.
      integer, public     :: nprows=-1, npcols=-1
      integer, public     :: myrow=-1, mycol=-1
      integer, public     :: mynode, numprocs

      
      end module pdata

