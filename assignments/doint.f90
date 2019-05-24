! This program calculates an integral of a polynomial
! Inputs:
!  integer            np    = the order of the polynomial
!  double precision   poly  = array of polynomial coefficients
!  double precision   a     = lower bound for integration
!  double precision   b     = upper bound for integration
!  double precision   eps   = desired accuracy
!  integer            jmax  = maximum subdivisions for the 
!                             trapezoidal integration
! Suggested input:
! 3
! 1
! 2
! 3
! 4
! 0 1000
! 1e-20 20
!
! Output:
! Integral over the range 0 to 1000 =         1.001001e+12
!
!    Timothy H. Kaiser 
!    tkaiser@mines.edu
!    Aug 2010
!    Revised Sep 2012

module numz
!*************************************
    integer, parameter:: b8 = selected_real_kind(14) ! basic real types
    integer, parameter :: pmax=10
    real(b8) poly(0:pmax)
    integer np
end module

!myfunc: Evaluate a polynomial at a point (x)
!        The coefficients for the polynomial
!        are in the array poly.  The order is
!        np.

function myfunc(x)
   use numz
   implicit none
   real(b8) x,myfunc,sum,xt
   integer i
   sum=poly(0)
   xt=x
   do i=1,np
     sum=sum+xt*poly(i)
     xt=xt*x
   enddo
 myfunc=sum
end function
   
! trapzd and qsimp are adapted from:
! Numerical Recipes: the art of scientific computing /William H. Press ... [et al.].
! with various additions and years of publication
! Publisher:	Cambridge University Press
!
! Taken together trapzd and qsimp calculate the integral 
! of a function over same range, a to b.  The function to
! be integrated is passed in as an argument.  EPS is the
! desired accuracy and JMAX is the maximum number of times
! that trapzd is called, each time refining the previous
! estimate of the integral.  The routine trapzd integrates
! by the trapezoidal rule.

subroutine trapzd(func,a,b,s,n)
      use numz
      implicit none
      real(b8) :: func,a,b,s
      integer n
      external func
      real(b8) :: del,sum,x
      integer it,tnm,j
      if (n.eq.1) then
        s=0.5_b8*(b-a)*(func(a)+func(b))
      else
        it=2**(n-2)
        tnm=it
        del=(b-a)/tnm
        x=a+0.5_b8*del
        sum=0.0_b8
        do j=1,it
          sum=sum+func(x)
          x=x+del
        enddo
        s=0.5_b8*(s+(b-a)*sum/tnm)
      endif
end subroutine

subroutine qsimp(func,a,b,s,eps,jmax)
      use numz
      implicit none
      integer jmax
      real(b8) :: a,b,func,s,eps
      external func
      real(b8) ost,os,st
      integer j
      ost=-1.e30
      os= -1.e30
      do j=1,jmax
!        write(*,*)j
        call trapzd(func,a,b,st,j)
        s=(4.*st-ost)/3.
        if (abs(s-os).lt.eps*abs(os)) return
        if (s.eq.0..and.os.eq.0..and.j.gt.6) return
        os=s
        ost=st
      enddo
      write(*,*)'too many steps in qsimp'
end subroutine

program doint
   use numz
   implicit none
   external myfunc
   real(b8) a,b,s,eps,myfunc
   character (len=100)::aform
   integer jmax,i
   aform='("Integral over the range ",f10.5," to ",f10.5,"=",g20.7)'
! We are integrating a polynomial read in the order (np)
! then the coefficients (poly).
   read(*,*)np
   read(*,*)(poly(i),i=0,np)
! Read the lower (a) and upper (b) integrations bounds.
   read(*,*)a,b
! Read the desired accuracy (eps) and the 
! maximum subdivisions for the trapezoidal
! integration (jmax).
   read(*,*)eps,jmax
   call qsimp(myfunc,a,b,s,eps,jmax)
   write(*,aform)a,b,s
end program

   
