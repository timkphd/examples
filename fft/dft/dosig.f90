    module numz
! module defines the basic real type and pi
!      integer, parameter :: b8 = selected_real_kind(14)
      integer, parameter :: b8 = selected_real_kind(4)
      real(b8), parameter :: pi  = 4.0_b8*(atan(1.0_b8))
      real(b8), parameter :: pi2 = 8.0_b8*(atan(1.0_b8))
      integer, parameter :: nsig = 100
    end module
    program signal
    use numz
    real(b8) :: tmin(nsig),tmax(nsig),amp(nsig),f(nsig)
    real(b8) :: dt,maxt
    real(b8), allocatable :: sig(:)
    real(b8) sval,t,y
    integer :: nc(nsig),num,msig
    integer :: i,j
    read(*,*)num
! subsignals are nonzero between tmin and tmax
! tmin can be < 0.0
! tmax can be > maxt
! with a given max amplitude and frequency (hz)
! nc =  0 constant amplitude between tmin and tmax
! nc = -1 amplitude decreases between tmin and tmax
! nc = +1 amplitude increases between tmin and tmax
    do i=1,num
      read(*,*)tmin(i),tmax(i),amp(i),f(i),nc(i)
    end do
    write(*,*)
    read(*,*)dt,maxt
    msig=maxt/dt
    msig=msig+1
    allocate(sig(msig))
    do j=1,msig
      t=dt*(j-1)
      sig(j)=0.0_b8
      do i=1,num
        y=sval(t,tmin(i),tmax(i),amp(i),f(i),nc(i))
!       write(*,*)i,t,y
        sig(j)=sig(j)+y
      enddo
    enddo
 !   do i=1,msig
 !     write(*,*)sig(i)
 !   enddo
    open(unit=18,file="test.dat",access="stream",status="replace")
    write(18)sig
    end program
    function sval(t,tmin,tmax,amp,f,nc)
    use numz
    real(b8) :: t,tmin,tmax,amp,f,sval
    integer nc
    real(b8) cur
    sval=0.0_b8
    if(t .lt. tmin)return
    if(t .gt. tmax)return
    cur=t-tmin
    sval=amp*sin(pi2*cur*f)
    if(nc .eq.  0)then
      return
    endif
    if(nc .eq. -1)then
      sval=sval*(1.0_b8-cur/(tmax-tmin))
      return
    endif
    if(nc .eq.  1)then
      sval=sval*(cur/(tmax-tmin))
      return
    endif
    write(*,*)"invalid nc:",nc
    end function
    
    
    
    
