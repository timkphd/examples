module numz
    integer, parameter:: b4 = selected_real_kind(4)
    integer, parameter:: i4 = selected_int_kind(4)
end module
module maxsize
        integer nmax
        parameter  (nmax=8000)
end module
module ccm_time_mod
    integer, parameter:: b8 = selected_real_kind(10)
    integer,save,private :: ccm_start_time(8) = (/-1, -1, -1, -1, -1, -1, -1, -1/)
contains
    function ccm_time()
        implicit none
        real(b8) :: ccm_time,tmp
        integer,parameter :: norm(13)=(/  &   
               0, 2678400, 5097600, 7776000,10368000,13046400,&
        15638400,18316800,20995200,23587200,26265600,28857600,31536000/)
        integer,parameter :: leap(13)=(/  &   
               0, 2678400, 5184000, 7862400,10454400,13132800,&
        15724800,18403200,21081600,23673600,26352000,28944000,31622400/)
        integer :: values(8),m,sec
        call date_and_time(values=values)
        if(ccm_start_time(1) .eq. -1)ccm_start_time=values
        if(mod(values(1),4) .eq. 0)then
           m=leap(values(2))
        else
           m=norm(values(2))
        endif
        sec=((values(3)*24+values(5))*60+values(6))*60+values(7)
        tmp=real(m,b8)+real(sec,b8)+real(values(8),b8)/1000.0_b8
        if(values(1) .ne. ccm_start_time(1))then
            if(mod(ccm_start_time(1),4) .eq. 0)then
                tmp=tmp+real(leap(13),b8)
            else
                tmp=tmp+real(norm(13),b8)
            endif
        endif
        ccm_time=tmp
    end function
end module ccm_time_mod
module special
    contains
    function j1(x)
        use numz
        implicit none
        real(b4) j1,x
        integer n
        real(b4) bjn,by,bin,bk
        n=1
        call besse(x,bjn,by,bin,bk,n)
        j1=bjn
    end function
    function h0(x)
        use numz
        implicit none
        complex(b4) h0,j
        real(b4) x
        integer n
        real(b4) bjn,by,bin,bk
        j=cmplx(0,1)
        n=0
        call besse(x,bjn,by,bin,bk,n)
        h0=bjn-j*by
    end function
    function h1(x)
        use numz
        implicit none
        complex(b4) h1,j
        real(b4) x
        integer n
        real(b4) bjn,by,bin,bk
        j=cmplx(0,1)
        n=1
        call besse(x,bjn,by,bin,bk,n)
        h1=bjn-j*by
    end function

    subroutine besse (x, bjn, by, bin, bk,nord)
    use numz
    implicit none
    real(b4) x, bjn, by, bin, bk
    integer nord
    logical finished, done_wron,done
    real(b4) an, ai, ak, fn, gam, t, s, xa, c, d, phi
    real(b4) pn, qn, u, den, xb, pi, bi, xi
    real(b4) bj0, by0, bi0, bk0, bk1, by1, p
    integer k, n, m, i 
    pi = 3.14159265358979323846_b4
    gam =0.57721566490153286060_b4
    fn = nord
!   x=x4
    if ((x - fn - 6.0) .lt. 0.0) then
    xa = x / 2.0
    xb = (xa)**2
    n = 0
! beginning of j_n_i_n_1
    call jnin(an,n,t,s,xa,bjn,bin,done,k,den,xb)
    finished = .false.
 300    if((n .le. 1) .and. (.not. finished))then
    if (n .eq. 0) then
    by = 2.0 / pi * (gam + log(xa)) * bjn
    bk = -(gam + log(xa)) * bin
    t = xb
    s = 1.0
    xi = 1.0
    k = 2
    ak = k
 200    if((by + t * xi - by) .ne. 0.0)then
    bk = bk + t * xi
    by = by + 2.0 / pi * s * t * xi
    t = t * xb / (ak * ak)
    xi = xi + 1.0 / ak
    s = -s
    k = k + 1
    ak = k
    goto 200
        endif
    if (nord .gt. 0) then
    n = 1
    bj0 = bjn
    bi0 = bin
    by0 = by
    bk0 = bk
    call jnin(an,n,t,s,xa,bjn,bin,done,k,den,xb)
    else
        finished = .true.
    endif
    elseif (n .eq. 1) then
    by = (bjn * by0 - 2.0 / (pi * x)) / bj0
    bk = (1.0 / x - bin * bk0) / bi0
    p = 1
    if (nord .gt. 1) then
    done_wron = .false.
 100    if(.not. done_wron)then
    by1 = by
    bk1 = bk
    by = 2.0 * p / x * by1 - by0
    bk = 2.0 * p / x * bk1 + bk0
    p = p + 1
    if (nord .gt. 2) then
    by0 = by1
    bk0 = bk1
    nord = nord - 1
    else
    done_wron = .true.
    endif
    goto 100
    endif
    n = nint(p)
    call jnin(an,n,t,s,xa,bjn,bin,done,k,den,xb)
    else
        finished = .true.
    endif
        else
    finished = .true.
    endif
    goto 300
    endif
    else
! beginning of   asymptot
    c = 4 * nord * nord
    d = 8.0 * x
    an = nord
    phi = x - ((2.0 * an + 1.0) / 4.0) * pi
    m = int(x + 1 + sqrt(x * x + an * an))
    t = (c - 1.0) / d
    s = 1.0
    u = 1.0
    pn = 1.0
    qn = t
    bk = 1.0 + t
    bi = 1.0 - t
    i = 2
 1  continue
    ai = i
    t = (c - (2.0 * ai - 1.0)**2) / d * t / ai
    bk = bk + t
    bi = bi + t * s
    if (s .gt. 0.0) then
    pn = pn - t * s * u
    u = -u
    else
    qn = qn - t * s * u
    endif
    s = -s
    i = i + 1
    if((i.gt.m) .or. (((qn + t) - qn).eq.0.0))goto 2
    goto 1
 2  continue
    bk = exp(-x) * bk * sqrt(pi / (2.0 * x))
    if ((x - fn - 6.0) .ge. 0.0) then
    bjn = (pn * cos(phi) - qn * sin(phi)) * sqrt(2.0 / (pi * x))
    by = (pn * sin(phi) + qn * cos(phi)) * sqrt(2.0 / (pi * x))
    if(x.lt.75.9853)then
    bin = exp(x) * bi / sqrt(2.0 * pi * x)
    else
    bin=1e33
    endif
    endif
! end of   asymptot
    endif
    nord = nint(fn)
    return
    end subroutine
    subroutine jnin(an,n,t,s,xa,bjn,bin,done,k,den,xb)
    use numz
    implicit none
    real(b4) bjn,bin
!   integer nord
!   logical finished, done_wron
    logical done
    real(b4) an, t, s, xa
!   real(b4) pn, qn,pi, bi,c, d, ak, fn,u,bk,by,phi,gam
    real(b4) den, xb
!   real(b4) bj0, by0, bi0, bk0, bk1, by1, p,xi,x,ai,w
    integer k, n
!   integer m, i 
    an = n
    t = 1.0
    s = -1.0
 101    if(an .gt. 0.0)then
    t = t * xa / an
    an = an - 1
    goto 101
    endif
    bjn = t
    bin = t
    done = .false.
    k = 1
 201    continue
    den = k * (k + n)
    t = t * xb / den
    if (((bjn + t) - bjn ).ne. 0.0) then
    bjn = bjn + t * s
    bin = bin + t
    s = -s
    k = k + 1
    else
    done = .true.
    endif
    if(done)goto 301
    goto 201
 301    continue
    return
    end subroutine
end module

!###########################################################
program rcs
    use numz
    use maxsize
    use ccm_time_mod
    use special
    implicit none
    external cgesv
    integer magma_init ,magma_finalize ,magma_cgesv_gpu,magma_cgesv

    integer(i4) n,m,nbox
    real(b8) it1,it2,ts,tend,ttot,tgen
    complex(b4) c(nmax,nmax),i,eps(nmax),j,ei(nmax),e(nmax),es
!   real(b4) zero
    real(b4) k,lambda,pi,x(nmax),y(nmax),a(nmax),r,rhon,xin,yin
    real(b4) ang1
    real(b4) theta1,theta2,theta,thetas,xs,ys,dx,dy
    real(b4) thetamin,thetamax
    real(b4) ereal,eimag
! start stuff for mkl library
    integer nrhs, ipiv(nmax),lda,ldb,info
! end stuff for mkl library
    complex(b4) b(nmax,1)
    complex(b4) cn
    character(len=10) :: method
    integer ijk
    write(*,*)magma_init()
    call magma_print_environment ()
    do ijk=1,4
    ts=ccm_time()
    pi = 3.14159265358979323846_b4
    j=cmplx(0,1)
    i=j
    open(8,file='wing.dat',status='old')
    open(12,file='source.dat',status='old')
    open(10,file='out.dat',status='unknown')
!   open(11,file='scat.dat',status='new')
!   open(file="scat.dat",access="stream",unit=11,form="unformatted")
    read(12,*)method
    read(12,*)lambda
    ys=3000.0_b4
    xs=-250.0_b4
!   read(12,*)xs,ys
    read(12,*)theta1,theta2
    k=2.0_b4*pi/lambda
    do nbox=1,nmax
      read(8,*,end=200)x(nbox),y(nbox),a(nbox),ereal,eimag
      eps(nbox)=cmplx(ereal,eimag)
      a(nbox)=a(nbox)*2.0_b4/sqrt(pi)
!     write(*,*)x(nbox),y(nbox),a(nbox),eps(nbox)
    enddo
 200 nbox=nbox-1
    do n=1,nbox
    	do m=n+1,nbox
    		r=sqrt( ( x(m)-x(n) )**2+( y(m)-y(n) )**2)
            if(r .le. 1e-4)then
                write(*,*)"points overlap",n,m
                stop
            endif
    		c(m,n)=h0(k*r)
    		c(n,m)=c(m,n)
    	enddo
    enddo
    do n=1,nbox
    	c(n,n)=(j/2.0_b4)*(pi*k*a(n)*h1(k*a(n))-2.0_b4*j)
    enddo
    do  n=1,nbox
        cn=(j*pi*k*a(n)/2.0_b4)*(eps(n)-1.0_b4)*j1(k*a(n))
        do  m=1,nbox
            if(n.eq.m)then
                c(n,n)=1.0_b4+(eps(n)-1.0_b4)*c(n,n)
            else
                c(m,n)=c(m,n)*cn
            endif
        enddo
    enddo
!    do  n=1,nbox
!        cn=(j*pi*k*a(n)/2.0_b4)*(eps(n)-1.0_b4)*j1(k*a(n))
!        do  m=1,nbox
!        if(n.eq.m)then
!            c(n,n)=1.0_b4+(eps(n)-1.0_b4)*(j/2.0_b4)*(pi*k*a(n)*h1(k*a(n))-2.0_b4*j)
!        else
!            r=sqrt( ( x(m)-x(n) )**2+( y(m)-y(n) )**2)
!            if(r .le. 1e-4)then
!                write(*,*)"points overlap",n,m
!                stop
!            endif
!            c(m,n)=cn*h0(k*r)
!        endif
!        enddo
!    enddo
    it1=ccm_time()
    tgen=it1-ts
    write(*,*)' matrix generated',tgen," of size ",nbox
! calculate the source field
    theta1=theta1*pi/180.0_b4
    theta2=theta2*pi/180.0_b4
    thetas=atan2(ys,xs)
    thetamin=thetas-theta1
    thetamax=theta2+thetas
    if(thetamax .lt. thetamin)then
        thetamax=thetas-theta1
        thetamin=theta2+thetas
    endif
!   write(*,*)"beam=",thetamin*180.0_b4/pi,thetas*180_b4/pi,thetamax*180.0_b4/pi
    write(*,*)"beam=",thetamin*180.0_b4/pi,thetas*180.0_b4/pi,thetamax*180.0_b4/pi
    do  m=1,nbox
        dx=(xs-x(m))
        dy=(ys-y(m))
        theta=atan2(dy,dx)
        if((theta.ge.thetamin).and.(theta.le.thetamax))then
            r=sqrt(dx*dx+dy*dy)
            ei(m)=exp(j*k*r)
        else
            ei(m)=0.0_b4
        endif
!       write(*,*)' theta=',theta*180.0/pi,ei(m),m
    enddo
    it1=ccm_time()
    method=adjustl(method)
    select case (method)
      case ("cgesv")
! start stuff for mkl library
        nrhs=1
        lda=nmax
        ldb=nmax
        info=0
        b(:,1)=ei
!        call cgesv( nbox, nrhs, c, lda, ipiv, b, ldb, info )
         write(*,*)magma_cgesv( %VAL(nbox), %VAL(nrhs), c, %VAL(lda), ipiv, b, %VAL(ldb), info )

        e=b(:,1)
        if( info.gt.0 ) then
         write(*,*)'the diagonal element of the triangular factor of c,'
         write(*,*)'u(',info,',',info,') is zero, so that'
         write(*,*)'c is singular; the solution could not be computed.'
         stop
        end if
      case ("invert")
        call invert(c,nbox)
        call backsub(c,ei,e,nbox)
    end select
    it2=ccm_time()
    it2=it2-it1
    write(*,*)nbox,' did solve',it2,"    using :",method
!   do  n=1,nbox
!       write(11,"(3g20.10)")e(n),cabs(e(n))
!   enddo 
 16 format(i4,",",g20.10)
    do m=0,359
        ang1=m
        ang1=ang1*pi/180.0_b4
        xin=1000.0_b8*cos(ang1)
        yin=1000.0_b8*sin(ang1)
        es=cmplx(0,0)
        do n=1,nbox
            rhon=sqrt((xin-x(n))**2+(yin-y(n))**2)
            es=es+(eps(n)-1.0_b4)*e(n)*a(n)*j1(k*a(n))*h0(k*rhon)
        enddo
        es=-es*pi*k*j/2.0_b4
!       write(*,"(4g20.10)")xin,yin,es
!       write(10,16)m,20.0_b4*log10(abs(es)/0.001_b4)
        write(10,'(g10.5,2x,g20.10)')ang1,20.0_b4*log10(abs(es)/0.001_b4)
!       write(11)abs(es)
    enddo
    tend=ccm_time()
    ttot=tend-ts
    write(*,*)'matrix generation time',tgen
    write(*,*)'matrix solve time ',it2
    write(*,*)'total computaion time ',ttot
    close(8)
    close(10)
    close(12)
        if(ijk == 1)write(13,"(2g15.7)")e(1:nbox)
 enddo
    write(*,*)magma_finalize()
end program
    subroutine backsub(a,b,c,m)
        use numz
        use maxsize
        implicit none
        integer m,n,i,k
        complex(b4) a(nmax,nmax),b(nmax),c(nmax)
        n=m
        do  i=1,m
          c(i)=0.0_b4
          do  k=1,n
            c(i)=c(i)+a(i,k)*b(k)
          enddo
        enddo
        return
    end subroutine
    subroutine invert (matrix,size)
    use numz
    use maxsize
    implicit none
    integer switch,k, jj, kp1, i, j, l, krow, irow,size
    dimension switch(nmax,2)
    complex(b4) matrix(nmax,nmax)
    complex(b4) pivot, temp
    do 100 k = 1,size
    jj = k
        if (k .ne. size) then
        kp1 = k + 1
        pivot = (matrix(k, k))
        do 1 i = kp1,size
        temp = (matrix(i, k))
        if (abs(pivot) .lt. abs(temp)) then
        pivot = temp
        jj = i
        endif
 1  continue
        endif
    switch(k, 1) = k
    switch(k, 2) = jj
    if (jj .ne. k) then
        do 2  j = 1 ,size 
    temp = matrix(jj, j)
    matrix(jj, j) = matrix(k, j)
    matrix(k, j) = temp
 2  continue
    endif
    do 3 j = 1,size
    if (j .ne. k)matrix(k, j) = matrix(k, j) / matrix(k, k)
 3  continue
    matrix(k, k) = 1.0 / matrix(k, k)
    do 4 i = 1,size
    if (i.ne.k) then
    do 40 j = 1,size
    if(j.ne.k)matrix(i,j)=matrix(i,j)-matrix(k,j)*matrix(i,k)
 40 continue
    endif
 4  continue
    do 5 i = 1, size
    if (i .ne. k)matrix(i, k) = -matrix(i, k) * matrix(k, k)
 5  continue
 100    continue
    do 6 l = 1,size
    k = size - l + 1
    krow = switch(k, 1)
    irow = switch(k, 2)
    if (krow .ne. irow) then
    do 60 i = 1,size
    temp = matrix(i, krow)
    matrix(i, krow) = matrix(i, irow)
    matrix(i, irow) = temp
 60 continue
    endif
 6  continue
    return
    end

    

