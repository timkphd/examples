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
      module diffusion
!
!   Purpose: Assign problem parameters and initial data.
!
!   Routines called:
!       none
!
      use parameters
      use scale
      implicit none
      private
!
! Make all entities private by default.
! Have all public entities have the prefix dif_.
!
!  The following are the publically available routines.
!
      public init_diffusion, init_temp, diff_coef

!
!     The following are publically available variables.
!

      real, public :: dif_ly_ratio
      integer, public :: dif_nx, dif_ny, dif_npts, dif_ntemps
      real(long), public :: dif_delta_t
      real(long), public, allocatable :: dif_x(:), dif_y(:)

!
!     dif_ly_ratio  is the ratio of the x and y lengths of the beam.
!     dif_nx        is the number of sine expansion coefficients to use
!                   in the x direction.
!     dif_ny        is the number of sine expansion coefficients to use
!                   in the y direction.
!     dif_delta_t   is the size of the time step to be display on output.
!     dif_ntemps    is the total number of temperatures to display per point.
!     dif_npts      is the total number of points to output.
!     dif_x         is the x coordinates of the points.
!     dif_y         is the y coordinates of the points.
!
!

!
!     Private variables
!
      integer :: init_f=1, diff_f=1
!   init_f chooses the functional form of initial distribution of temperature.
!   diff_f chooses the functional form for spatially dependent head diffusion
!          coefficient.

      contains

!****************************************************************************!
!*                                                                          *!
!*   Module routine init_diffusion                                          *!
!*                                                                          *!
!*   Purpose: Initialize problem size, number of output point and           *!
!*            functional form of diffusion constant and initial temperature *!
!*            distribution                                                  *!
!*                                                                          *!
!****************************************************************************!
        subroutine init_diffusion
        namelist /input/ ly_ratio, delta_t, numx, numy, nx, ny, numt,         &
     &                    init_f, diff_f
        integer :: numx=5, numy=5, nx=7, ny=7, numt=20
        real(long) :: ly_ratio=1.d0, delta_t=0.1
        real(long) :: delx, dely
        integer :: i, j, ij
        logical :: ex
!==============================================================================!
!          Start of executable code                                            !

        inquire ( file='diffus.naml', exist=ex)
        if( ex ) then
          open( 10, file='diffus.naml', action='read')
          read( 10, input)
          close(10)
        endif

        dif_ly_ratio = ly_ratio
        dif_npts = numx*numy
        dif_delta_t = delta_t
        dif_ntemps  = numt
        dif_nx = nx
        dif_ny = ny
        allocate( dif_x(numx*numy) )
        allocate( dif_y(numy*numx) )
!
! Assign a simple linear array of points.
!
        delx = PI/ ( numx + 1.d0)
        dely = PI/ ( numy + 1.d0)
        do i = 1, numx
          do j = 1, numy
            ij = numx*(j-1)  + i
            dif_x(ij) = delx* i
            dif_y(ij) = dely * j
          enddo
        enddo
        return
        end subroutine init_diffusion

!****************************************************************************!
!*                                                                          *!
!*   Module routine init_temp                                               *!
!*                                                                          *!
!*   Purpose: Return the initial temperature of the bar at a particular     *!
!*            point                                                         *!
!*                                                                          *!
!****************************************************************************!
        function init_temp(x, y)
!
!     Arguments:
!       x: real*8 (in), x coordinate
!       y: real*8 (in), y coordinate
!     Function return:
!     init_temp: real*8 (out), initial temperature at (x,y)
!
        real(long), intent(in) :: x, y
        real(long) :: init_temp

!
!   The problem has been scaled to go from 0 to pi in both the x
!   and y directions. To calculate the expansion coefficients, we 
!   define the function to be odd about pi and use the range 0 < x < 2*pi
!
!  Local variables.
        integer :: isign
        real(long) :: x1, y1
!
        isign = 1
        x1 = x
        if( x .gt. pi ) then
          isign = -isign
          x1 = twopi - x
        endif
        y1 = y
        if( y .gt. pi ) then
          isign = -isign
          y1 = twopi - y
        endif

!
! Choose very simple temperature profile cases.
!
        select case (init_f)
          case (1)
             init_temp = isign*(x1*(pi-x1))*y1*(pi-y1)
          case (2)
             init_temp = isign*(x1*(pi-x1))*y1*(pi-y1)*y1
          case (3)
             init_temp = isign*(x1*(pi-x1))*y1*(pi-y1)*x1
          case (4)
             init_temp = isign*(x1*(pi-x1))*y1*(pi-y1)*x1*y1
          case (5)
             init_temp = isign*(x1*(pi-x1))*y1*(pi-y1)
          case (6)
             init_temp = isign*(x1*(pi-x1))**2 *y1*(pi-y1)
          case (7)
             init_temp = isign*(x1*(pi-x1))*(y1*(pi-y1))**2
          case default
             init_temp = isign*sin(x1)*sin(y1)
        end select
        return
        end function init_temp



!****************************************************************************!
!*                                                                          *!
!*   Module routine diff_coef                                               *!
!*                                                                          *!
!*   Purpose: Return the value of the thermal diffusion coefficient at      *!
!*            an arbitrary point                                            *!
!*                                                                          *!
!****************************************************************************!
        function diff_coef(x, y)
!     Arguments:
!       x: real*8 (in), x coordinate
!       y: real*8 (in), y coordinate
!     Function return:
!       diff_coef: real*8 (out), diffusion coefficient at (x,y)
!
         real(long), intent(in) :: x, y
         real(long) :: diff_coef

!
!   The problem has been scaled to go from 0 to pi in both the x
!   and y directions. To simplify the matrix element calculations,
!   we define the function to be even about pi.
!

!  Local variables.
        real(long) :: x1, y1

!==============================================================================!
!          Start of executable code.                                           !
        x1 = x
        if( x .gt. pi )  x1 = twopi - x
        y1 = y
        if( y .gt. pi ) y1 = twopi - y

!
! Choose very simple diffusion coefficient cases.
!
        select case (diff_f)
           case (1)
             diff_coef = .5d0 + (x1 + y1) / (2 * twopi)
           case (2)
             diff_coef = ((1.d0 + x1)*(pi - x1 + 1.d0)*(y1 + pi))/ 3*pi
           case (3)
             diff_coef = (y1 + pi) * pi/((pi + x1) * (2* pi - x1))
           case default
             diff_coef = 1.d0
           end select
        return
        end function diff_coef


      end module diffusion
