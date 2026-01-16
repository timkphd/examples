!
! SPDX-FileCopyrightText: Copyright (c) 2022 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
! SPDX-License-Identifier: LicenseRef-NvidiaProprietary
!
! NVIDIA CORPORATION, its affiliates and licensors retain all intellectual
! property and proprietary rights in and to this material, related
! documentation and any modifications thereto. Any use, reproduction,
! disclosure or distribution of this material and related documentation
! without an express license agreement from NVIDIA CORPORATION or
! its affiliates is strictly prohibited.
!

!
! Jacobi iteration example using Do Concurrent in Fortran
! Build with to target NVIDIA GPU
!   nvfortran -stdpar -Minfo=accel -fast f3.f90
! Build with to target host multicore
!   nvfortran -stdpar=multicore -Minfo=accel -fast f3.f90
!
! This program was modified to solve the stommel problem.  The
! results will not be identical to the other versions because 
! this is real*4, the boundaries are at i=0 & n , j=0 & m, thus
! the gride is slightly smaller.

  
module ver
  contains
    subroutine pv()
      use, intrinsic :: iso_fortran_env, only : compiler_version
      use, intrinsic :: iso_fortran_env, only : compiler_options
      implicit none
      print '(4a)', ' Compiled by ',  compiler_version(), &
                    ' using the options ',  compiler_options()
end subroutine
end module

module sm
contains
 subroutine smooth( a, b ,a1, a2, a3, a4, a5, n, m, niters,force)
  real, dimension(:,:) :: a,b,force
  real :: a1, a2, a3, a4, a5
  integer :: n, m, niters
  integer :: i, j, iter
   do iter = 1,niters
    do concurrent(i=2 : n-1, j=2 : m-1) 
                a(i,j)=a1*b(i+1,j) + a2*b(i-1,j) + &
                       a3*b(i,j+1) + a4*b(i,j-1) - &
                       a5*force(i,j)

    enddo
    do concurrent(i=2 : n-1, j=2 : m-1)
                    b(i,j)=a1*a(i+1,j) + a2*a(i-1,j) + &
                       a3*a(i,j+1) + a4*a(i,j-1) - &
                       a5*force(i,j)
    enddo
   enddo
 end subroutine
 
 subroutine smoothhost( a, b, a1, a2, a3, a4, a5, n, m, niters ,force)
  real, dimension(:,:) :: a,b,force
  real :: a1, a2, a3, a4, a5
  integer :: n, m, niters
  integer :: i, j, iter
   do iter = 1,niters
    do i = 2,n-1
     do j = 2,m-1
                a(i,j)=a1*b(i+1,j) + a2*b(i-1,j) + &
                       a3*b(i,j+1) + a4*b(i,j-1) - &
                       a5*force(i,j)
     enddo
    enddo
    do i = 2,n-1
     do j = 2,m-1
                    b(i,j)=a1*a(i+1,j) + a2*a(i-1,j) + &
                       a3*a(i,j+1) + a4*a(i,j-1) - &
                       a5*force(i,j)
     enddo
    enddo
   enddo
 end subroutine
end module

program main
 use sm
 use ver
 use iso_fortran_env, only: int64, real64
 implicit none
 real(real64) tpar,tseq
 real,dimension(:,:),allocatable :: aahost, bbhost, aapar, bbpar,force
 real :: a1, a2, a3, a4, a5, a6
 integer :: i,j,n,m,iters
 integer (int64) :: c0, c1, c2, c3, c4, cpar, cseq
 integer :: errs, args
 character(10) :: arg
 real :: dif, tol
 integer(int64) :: count_max_val,count_rate_val
 integer num_args
 real :: dx,dy,dx2,dy2,bottom,pi,y
 real :: lx,ly,alpha,beta,gamma
 call system_clock(count_rate=count_rate_val, count_max=count_max_val)


 pi = 3.141592653589793239
 n = 200
 m = n
 lx=2000000.0
 ly=2000000.0
 alpha=1.0e-9
 beta=2.25e-11
 gamma=3.0e-6
 iters = 75000/2
    dx=lx/(n+1)
    dy=ly/(m+1)
    dx2=dx*dx
    dy2=dy*dy
    bottom=2.0*(dx2+dy2)
    a1=(dy2/bottom)+(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
    a2=(dy2/bottom)-(beta*dx2*dy2)/(2.0*gamma*dx*bottom)
    a3=dx2/bottom
    a4=dx2/bottom
    a5=dx2*dy2/(gamma*bottom)
    a6=pi/(lx)
    write(*,*)a1,a2,a3,a4,a5,a6
 allocate( aapar(n,m) )
 allocate( bbpar(n,m) )
 allocate( aahost(n,m) )
 allocate( bbhost(n,m) )
 allocate( force(n,m) )
    aapar=0.0
    aahost=0.0
    bbpar=1.0
    bbhost=1.0
    bbpar(1,:)=0.0
    bbpar(n,:)=0.0
    bbpar(:,1)=0.0
    bbpar(:,m)=0.0 
    
    bbhost(1,:)=0.0
    bbhost(n,:)=0.0
    bbhost(:,1)=0.0
    bbhost(:,m)=0.0 
    do i = 1,n
      do j = 1,m
            y=j*dy
            force(i,j)=-1.0e-9*sin(y*a6)
        enddo
    enddo



 call system_clock( count=c1 )
 call smooth( aapar, bbpar, a1, a2, a3, a4, a5, n, m, iters ,force)
 write(*,*)sum(aapar-bbpar),maxval(aapar),minval(aapar)
 call system_clock( count=c2 )
 cpar = c2 - c1
 call smoothhost( aahost, bbhost, a1, a2, a3, a4, a5, n, m, iters ,force)
 call system_clock( count=c3)
 if (n .le. 20)then
        write(*,"(10e15.7)")aapar
        write(*,*)"*******************************************"
        write(*,"(10e15.7)")aahost
endif
 cseq = c3 - c2
 ! check the results
 errs = 0
 tol = 0.000005
 do i = 1,n
  do j = 1,m
   dif = abs(aapar(i,j) - aahost(i,j))
   if( aahost(i,j) .ne. 0 ) dif = abs(dif/aahost(i,j))
   if( dif .gt. tol )then
    errs = errs + 1
    if( errs .le. 200 )then
     print *, i, j, aapar(i,j), aahost(i,j)
    endif
   endif
  enddo
 enddo
 !print *, cpar, ' microseconds on parallel with do concurrent'
 !print *, cseq, ' microseconds on sequential'
 tpar=real(cpar,real64)/real(count_rate_val,real64)
 tseq=real(cseq,real64)/real(count_rate_val,real64)

 write(*,*)"n= ",n," iterations= ",iters*2
 write(*,'(f15.6,a)')tpar, ' seconds on parallel with do concurrent'
 write(*,'(f15.6,a)')tseq, ' seconds on sequential'
 if (errs .ne. 0) then
    print *, "Test FAILED"
    print *, errs, ' errors found'
    print *,"Total error ",sum(abs(aapar-aahost))
 else
    print *, "Test PASSED"
 endif
 num_args = command_argument_count()
 if (num_args .gt. 0)then
   open(13,file="aapar.dat",access='stream',form='unformatted',status='replace')
   write(13)aapar
   close(13)
   open(13,file="aahost.dat",access='stream',form='unformatted',status='replace')
   write(13)aahost
   close(13)
 endif
 call pv()
end program
