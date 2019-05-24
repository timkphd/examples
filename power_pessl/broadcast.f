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
      module bcast
        use pdata
        implicit none
!
!     everything private by default
!
!
!  generic routines for broadcasting scalars or arrays from
!  on processor to all others. The call format is
!
!         subroutine broadcast(a,trow,tcol)
!
!   this subroutine broadcasts a scalar or an array from one
!   processor to all other processors
!
!        subroutine arguments:
!
!          a :: input or output, integer, real or complex scalar or array
!            This scalar or array sent by one processor and recieved
!            by all others
!
!          trow :: input, integer
!            row processor number of sending processor
!
!          tcol :: input, integer
!            column processor number of sending processor
!
!     Subroutines called:
!
!       igebs2d  from  blacs library
!       sgebs2d  from  blacs library
!       dgebs2d  from  blacs library
!       cgebs2d  from  blacs library
!       zgebs2d  from  blacs library
!       igebr2d  from  blacs library
!       sgebr2d  from  blacs library
!       dgebr2d  from  blacs library
!       cgebr2d  from  blacs library
!       zgebr2d  from  blacs library


!
      private 

      public :: broad_int, broad_single, broad_double
      public :: broad_complex, broad_dcomplex
      public :: broad_iarray, broad_sarray, broad_darray
      public :: broad_carray, broad_dcarray

      contains
!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_int                                               *!
!*                                                                          *!
!*   Purpose: Broadcast a single integer                                    *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_int(a,trow,tcol)
!
!    Arguments:
!     a: integer  integer to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      integer, intent(inout) :: a
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call igebs2d(icontext,'all','1-tree',1,1,a,1)
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call igebr2d(icontext,'all','1-tree',1,1,a,1,trow,tcol)
         endif
       endif
      
      end subroutine broad_int


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_single                                            *!
!*                                                                          *!
!*   Purpose: Broadcast a single single                                     *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_single(a,trow,tcol)
!
!    Arguments:
!     a: single  single to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      real(short_t), intent(inout) :: a
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call sgebs2d(icontext,'all','1-tree',1,1,a,1)
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call sgebr2d(icontext,'all','1-tree',1,1,a,1,trow,tcol)
         endif
       endif
      
      end subroutine broad_single


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_double                                            *!
!*                                                                          *!
!*   Purpose: Broadcast a single double                                     *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_double(a,trow,tcol)
!
!    Arguments:
!     a: double  double to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      real(long_t), intent(inout) :: a
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call dgebs2d(icontext,'all','1-tree',1,1,a,1)
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call dgebr2d(icontext,'all','1-tree',1,1,a,1,trow,tcol)
         endif
       endif
      
      end subroutine broad_double


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_complex                                           *!
!*                                                                          *!
!*   Purpose: Broadcast a single complex                                    *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_complex(a,trow,tcol)
!
!    Arguments:
!     a: complex  complex to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      complex(short_t), intent(inout) :: a
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call cgebs2d(icontext,'all','1-tree',1,1,a,1)
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call cgebr2d(icontext,'all','1-tree',1,1,a,1,trow,tcol)
         endif
       endif
      
      end subroutine broad_complex


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_dcomplex                                          *!
!*                                                                          *!
!*   Purpose: Broadcast a single dcomplex                                   *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_dcomplex(a,trow,tcol)
!
!    Arguments:
!     a: dcomplex  dcomplex to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      complex(long_t), intent(inout) :: a
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call zgebs2d(icontext,'all','1-tree',1,1,a,1)
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call zgebr2d(icontext,'all','1-tree',1,1,a,1,trow,tcol)
         endif
       endif
      
      end subroutine broad_dcomplex


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_iarray                                            *!
!*                                                                          *!
!*   Purpose: Broadcast a integer array                                     *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_iarray(a,trow,tcol)
!
!    Arguments:
!     a: integer  integer array to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      integer, intent(inout) :: a(:,:)
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call igebs2d(icontext,'all','1-tree',size(a,1),size(a,2),a,          &
     &                size(a,1))
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call igebr2d(icontext,'all','1-tree',size(a,1),size(a,2),a,         &
     &                size(a,1),trow,tcol)
         endif
       endif
      
      end subroutine broad_iarray


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_sarray                                            *!
!*                                                                          *!
!*   Purpose: Broadcast a single array                                      *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_sarray(a,trow,tcol)
!
!    Arguments:
!     a: single  single array to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      real(short_t), intent(inout) :: a(:,:)
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call sgebs2d(icontext,'all','1-tree',size(a,1),size(a,2),a,          &
     &                size(a,1))
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call sgebr2d(icontext,'all','1-tree',size(a,1),size(a,2),a,         &
     &                size(a,1),trow,tcol)
         endif
       endif
      
      end subroutine broad_sarray


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_darray                                            *!
!*                                                                          *!
!*   Purpose: Broadcast a double array                                      *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_darray(a,trow,tcol)
!
!    Arguments:
!     a: double  double array to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      real(long_t), intent(inout) :: a(:,:)
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call dgebs2d(icontext,'all','1-tree',size(a,1),size(a,2),a,          &
     &                size(a,1))
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call dgebr2d(icontext,'all','1-tree',size(a,1),size(a,2),a,         &
     &                size(a,1),trow,tcol)
         endif
       endif
      
      end subroutine broad_darray


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_carray                                            *!
!*                                                                          *!
!*   Purpose: Broadcast a complex array                                     *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_carray(a,trow,tcol)
!
!    Arguments:
!     a: complex  complex array to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      complex(short_t), intent(inout) :: a(:,:)
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call cgebs2d(icontext,'all','1-tree',size(a,1),size(a,2),a,          &
     &                size(a,1))
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call cgebr2d(icontext,'all','1-tree',size(a,1),size(a,2),a,         &
     &                size(a,1),trow,tcol)
         endif
       endif
      
      end subroutine broad_carray


!****************************************************************************!
!*                                                                          *!
!*   Module routine broad_dcarray                                           *!
!*                                                                          *!
!*   Purpose: Broadcast a dcomplex array                                    *!
!*                                                                          *!
!****************************************************************************!
        subroutine broad_dcarray(a,trow,tcol)
!
!    Arguments:
!     a: dcomplex  dcomplex array to be broadcast
!     trow:  originating processor column
!     tcol:  originating processor row
!
      complex(long_t), intent(inout) :: a(:,:)
      integer, intent(in)    :: trow, tcol
       
       if ( trow .lt. 0 .or. trow .ge. nprows .or.                             &
     &      tcol .lt. 0 .or. tcol .ge. npcols) then
          write(*,*) 'Invalid broadcast target ', trow, tcol
          call blacs_abort(icontext,1)
       endif

       if( myrow .eq. trow .and. mycol .eq. tcol) then
         call zgebs2d(icontext,'all','1-tree',size(a,1),size(a,2),a,          &
     &                size(a,1))
       else
         if( myrow .ge. 0 .and. mycol .ge. 0) then 
          call zgebr2d(icontext,'all','1-tree',size(a,1),size(a,2),a,         &
     &                size(a,1),trow,tcol)
         endif
       endif
      
      end subroutine broad_dcarray


      end module bcast
