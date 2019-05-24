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
      module delete
       use pdata
       implicit none
 
       private
!
!  generic distributed array delete
!
!     subroutine format:
!     subroutine array_delete(a)
!
!     a: fortran 90 pointer to allocated distributed array
!



       public :: delete_s_array, delete_d_array
       public :: delete_c_array, delete_z_array

       contains

        subroutine delete_s_array(array)
        real(short_t), pointer :: array(:,:)
        integer :: status

        deallocate(array,stat=status)
        if( status /= 0) then ! deallocation failed
             write(*,*) "Deallocation error delete_s_array"
             call blacs_abort(icontext,1)
        endif
        return
        end subroutine delete_s_array

        subroutine delete_d_array(array)
        real(long_t), pointer :: array(:,:)
        integer :: status

        deallocate(array,stat=status)
        if( status /= 0) then ! deallocation failed
             write(*,*) "Deallocation error delete_d_array"
             call blacs_abort(icontext,1)
        endif
        return
        end subroutine delete_d_array

        subroutine delete_c_array(array)
        complex(short_t), pointer :: array(:,:)
        integer :: status

        deallocate(array,stat=status)
        if( status /= 0) then ! deallocation failed
             write(*,*) "Deallocation error delete_c_array"
             call blacs_abort(icontext,1)
        endif
        return
        end subroutine delete_c_array

        subroutine delete_z_array(array)
        complex(long_t), pointer :: array(:,:)
        integer :: status

        deallocate(array,stat=status)
        if( status /= 0) then ! deallocation failed
             write(*,*) "Deallocation error delete_z_array"
             call blacs_abort(icontext,1)
        endif
        return
        end subroutine delete_z_array


      end module delete

