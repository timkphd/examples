module numz
! module defines the basic real type and pi
	integer, parameter:: b8 = selected_real_kind(14)
          integer, parameter:: i8 = selected_int_kind(15)
          real(b8), parameter :: pi = 3.141592653589793239_b8
contains
     function ccm_time()
        implicit none
        integer i
        integer :: ccm_start_time(8) = (/(-100,i=1,8)/)
        real(b8) :: ccm_time,tmp
        integer,parameter :: norm(13)=(/  &   
               0, 2678400, 5097600, 7776000,10368000,13046400,&
        15638400,18316800,20995200,23587200,26265600,28857600,31536000/)
        integer,parameter :: leap(13)=(/  &   
               0, 2678400, 5184000, 7862400,10454400,13132800,&
        15724800,18403200,21081600,23673600,26352000,28944000,31622400/)
        integer :: values(8),m,sec
        save
        call date_and_time(values=values)
        if(mod(values(1),4) .eq. 0)then
           m=leap(values(2))
        else
           m=norm(values(2))
        endif
        sec=((values(3)*24+values(5))*60+values(6))*60+values(7)
        tmp=real(m,b8)+real(sec,b8)+real(values(8),b8)/1000.0_b8
        !write(*,*)"vals ",values
        if(values(1) .ne. ccm_start_time(1))then
            if(mod(ccm_start_time(1),4) .eq. 0)then
                tmp=tmp+real(leap(13),b8)
            else
                tmp=tmp+real(norm(13),b8)
            endif
        endif
        ccm_time=tmp
    end function
end module


module doset 
contains
! This routine creates a matrix with a know inverse
! See Communications of the ACM
! Volume 6 Issue 3, March 1963
subroutine mset(m,  n,  in)
    use numz
	real(b8) :: m(:,:)
	integer n,in
	integer i,j
	do i=1,n
		do j=1,n
			if( i .eq. j)then
				m(i,j)=in
			else
				m(i,j)=0.1
			endif
		enddo
	enddo
end subroutine

end module

program tvert
	use numz
#ifdef MINE
	use myinvert
#endif
	use doset
	implicit none
	real(b8), allocatable :: A(:,:),B(:,:),x(:),times(:)
	real(b8)t1,t2,dtmin,dt,tstart,dtmax
	integer, allocatable :: IPIV(:)
	integer, parameter:: rhs=1
	integer n,nrhs,lda,ldb,info
	integer i,j,count
	NRHS=rhs
	read(*,*)N
	LDA=n
	LDB=N
	allocate(a(n,n))
	allocate(b(n,nrhs))
	allocate(x(n))
	allocate(ipiv(n))
	call mset(a,n,10)
	b=5.0_b8
	dtmin=huge(dtmin)
	dtmax=0.0_b8
	j=500
	allocate(times(j))
	tstart=ccm_time()
	do i=1,j
	t1=ccm_time()
	CALL dGESV( N, NRHS, A, LDA, IPIV, B, LDB, INFO )
	t2=ccm_time()
	count=i
	dt=t2-t1
	times(count)=dt
	if(dt < dtmin)dtmin=dt
	if(dt > dtmax)dtmax=dt
	if(t2-tstart > 120.0)exit
	enddo
	write(*,100)n,dtmin,dtmax,t2-tstart,count
 100 format("size=",i6," min time=",f10.5," max time=",f10.5,"  total time=",f13.5," inverts", i6)
    write(*,"(8f10.4)")times(1:count)

end program



