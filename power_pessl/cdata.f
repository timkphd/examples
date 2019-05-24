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
      module cdata
      use pdata
        implicit none
!
!  All variables public by default.
!
!  This is really a filter routine to give programs using
!  pessl_utilities access to parameters without giving access
!  to any internal variables such as icontext.
!

!  Subroutines called:
!    none
!
        private
!
!   Publically accessible routines follow.
!
!

!  declare long and short kinds
        public :: long_t
        public :: short_t
        public :: DESC_OFFSET
        public :: M_
        public :: N_
        public :: MB_
        public :: NB_
        public :: RSRC_
        public :: CSRC_
        public :: CTXT_
        public :: LLD_
        public :: DESC_DIM
        public :: CREATE_BLOCK
        public :: CREATE_CYCLIC

      end module cdata
