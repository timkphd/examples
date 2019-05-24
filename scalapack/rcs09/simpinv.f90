module numz
! module defines the basic real type and pi
  integer, parameter:: d8 = selected_real_kind(14)
  integer, parameter:: d4 = selected_real_kind(5)
  real(d8), parameter :: pi = 3.141592653589793239_d8
end module
program doinv
use numz
implicit none
real(d8), allocatable ::  a8(:,:),b8(:,:)
real(d8) :: tot
integer n,nrhs
integer lda, ldb, info 
integer,  allocatable :: ipiv(:)
logical :: do4,do8
integer stime,etime,rtime,mtime,m,i
character*1 trans
logical :: lu

nrhs=1
read(*,*,end=1234,err=1234)n,m,lu
goto 3456
1234 continue
n=2
m=10
lu=.true.
3456 continue
lda=n
ldb=n
allocate(ipiv(n))
tot=0.0


  allocate(a8(n,n))
  allocate(b8(n,nrhs))
  if(n .eq. 2)then
  a8(1,1)=1;
  a8(2,1)=6;
  a8(1,2)=3;
  a8(2,2)=7;
  b8(1,1)=2;
  b8(2,1)=4;
!octave:9> a8\b8
!ans =
!
!  -0.18182
!   0.72727
  else
  CALL RANDOM_NUMBER(a8)
  CALL RANDOM_NUMBER(b8)
  endif
  do i=1,m
      trans="N"
      call system_clock(stime, rtime,mtime)
      if (lu)then
      call dgetrf( n, n, a8, n, ipiv, info )
      call dgetrs(trans, n, nrhs, a8, lda, ipiv, b8, ldb, info)
      else
      call dgesv( n, nrhs, a8, lda, ipiv, b8, ldb, info )
      endif
!      call sgesv( n, nrhs, a8, lda, ipiv, b8, ldb, info )
      call system_clock(etime)
      if (etime .lt. stime)etime=etime+mtime
      tot=tot+real(etime - stime,d8) / real(rtime,d8)
      if(n .le. 10)write(*,*)b8
      if ( i .ne. m)then 
         CALL RANDOM_NUMBER(a8)
         CALL RANDOM_NUMBER(b8)
      endif
  enddo 
  print *, "size:",n,"  elapsed time: ",tot/m," did lu:",lu

end program

