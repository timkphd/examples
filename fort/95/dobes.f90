!    #include <math.h>
!    double myj(double* x ) { return j0(*x); }


module cmath_c 
 interface
  real (c_double) function myj0 (x) bind(c, name='myj')
    use iso_c_binding
    implicit none
    real (c_double) :: x
  end function myj0 
 end interface
end module

program bessy
  use cmath_c
  double precision xin
  do i=0,100
   xin=i
   xin=xin/10.0d0
   write(*,"(f5.1,1x,g24.16)")xin,myj0(xin)
  end do
end program

