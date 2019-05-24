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
      module init
      use pdata
      private  ! set everything private by default
      implicit none

!
!  This module initializes the blacs communication subsystem and
!  stores the row and column processor information. Most of the other
!  utility routines use the information stored by this routine.
!  while this imposes certain restraints on the user, e.g. only a
!  single blacs grid. It also simplifies the other utility routines
!  allowing a user to develop prototype message passing code more 
!  quickly. The init module contains three routines as follows
!
!  
!        subroutine initutils(status,nprs,npcs)
!
! This routine inializes blacs with the processor configuration
! nearest to a square grid if the optional arguments are not given.
! If nprs or npcs are provided, they are used to determine the 
! processor shape.  If both are provided, their product must be equal
! to the number of processors in the current job.
!
!        subroutine arguments:
!
!          status :: integer, required, output
!                    returns initialization status
!                      0: properly initialized
!                      1: initialization failed
!
!          nprs ::   integer, optional, input
!                    number of row processor requested
!
!          npcs ::   integer, optional, input
!                    number of column processor requested
!
!      Subroutines called:
!        blacs_pinfo    from blacs library
!        blacs_gridinit from blacs library
!        blacs_gridexit from blacs library

!
!      subroutine exitutils
!
!      This subroutine exits from the current blacs grid and
!      marks the utilities as uninitialized
!

!      integer function p_context()
!
!      this function returns the blacs context for these utilities
!


      
      public initutils, p_context, exitutils
  
       contains
       subroutine initutils(status,nprs,npcs)
         integer,intent(out)             :: status
         integer, optional,intent(in) :: nprs, npcs
         integer                         :: i,j

         if(initialized) call exitutils
         call blacs_pinfo(mynode,numprocs)
         
         if(present(nprs) ) then   
           if( present(npcs)) then 
!
! both number of rows and columns are input
!
             if( nprs*npcs .gt. numprocs) then
               status = 1                      !don't have enough processors
               return
             endif
             nprows = nprs
             npcols = npcs

           else
!
! only number of rows are present
!
             if( nprs .gt. numprocs) then
               status = 1                      !don't have enough processors
               return
             endif
             nprows = nprs
             npcols = numprocs/nprs
           endif

         else
           if( present(npcs)) then 
!
! only number of columns are present
!
             if( npcs .gt. numprocs) then
               status = 1                      !don't have enough processors
               return
             endif
             npcols = npcs
             nprows = numprocs/npcs
           else
!
! neither number of columns or rows present, pick the nearest to square
! grid
!
           nprows = int(sqrt(float(numprocs)))
           npcols = numprocs/nprows
           do while ( nprows*npcols .ne. numprocs)
             nprows = nprows - 1
             npcols = numprocs/nprows
           enddo
           endif
        
         endif

         call blacs_get(0,0,icontext)
         call blacs_gridinit(icontext,'r',nprows,npcols)
         call blacs_gridinfo(icontext,nprows,npcols,myrow,mycol)
         initialized = .true.
         status = 0
         return
       end subroutine initutils

       integer function p_context()

         p_context = -1
         if( initialized) p_context = icontext
       return
       end function p_context

       subroutine exitutils(close)
       integer, optional :: close
      
 
        if(initialized) then
         call blacs_gridexit(icontext)
         icontext = -1
         npcols = -1
         nprows = -1
         initialized = .false.
        endif
        if( present(close)) then
          call blacs_exit(close)
        endif
        return
       end subroutine exitutils
         

      end module init
