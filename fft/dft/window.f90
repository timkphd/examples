    module numz
! module defines the basic real type and pi
     integer, parameter:: b8 = selected_real_kind(14)
     integer, parameter:: b4 = selected_real_kind(5)
     integer, parameter :: jmax=131072
    end module
      subroutine appwin(x,wind,n,iwt)
      use numz
      real(b4) x(jmax)
      real(b4) wind(jmax)
      integer n,iwt,i
! apply it
      if(iwt .eq. 0)then
      do  i=1,n
       x(i)=x(i)*wind(i)
      enddo
      return
      endif
! define the window
      if(iwt .eq. 4)then
      call bh(wind,n,1.0_b4)
      return
      endif
      if(iwt .eq. 3)then
      call win1(wind,n,1.0_b4)
      return
      endif
      if(iwt .eq. 2)then
      call asinn(wind,n,2.0_b4)
      return
      endif
      if(iwt.eq.1)then
      call akb(wind,n,3.0_b4)
      return
      endif
      return
      end
      subroutine bh(w,nin,alpha)
      use numz
      real(b4) w(jmax),alpha
      integer nin
      real(b4) a(0:3)
      data a/0.40217_b4,0.49703_b4,0.09392_b4,0.00183_b4/
      integer n
      real(b4) pi2n,wn
!      write(*,*)'generating blackman harris window 74db'
!      write(*,*)'window is not symetric'
      pi2n=(atan(1.0_b4)*4.0_b4)*2.0/nin
      do  n=0,nin-1
      wn=a(0)-a(1)*cos(pi2n*n)+a(2)*cos(pi2n*2*n)-a(3)*cos(pi2n*3*n)
      w(n+1)=wn
      enddo
! next line surpress warning with option -wa
      alpha=alpha
      return
      end
      subroutine akb(w,nin,alpha)
      use numz
      real(b4) w(jmax)
      integer nin
      real(b4) alpha
      real(b4) pi,f,bign,bot,top,o2
      integer n2p,n2m,n,i
      real(b4) bessi0,z,wn
!      write(*,*)'generating kaiser-bessel window a=',alpha
!      write(*,*)'window is not symetric'
      pi=atan(1.0_b4)*4.0_b4
      f=pi*alpha
      bign=nin-1.0_b4
      bot=bessi0(f)
      top=1.0/bot
      o2=nin/2.0_b4
      o2=o2*o2
      n2p=nin/2
      n2m=-n2p
      do  n=n2m,n2p-1
        z=1.0_b4-n*n/o2
        if(z.lt.0.0)z=0.0_b4
        wn=top*bessi0(f*sqrt(z))
        i=(n-n2m)+1
        w(i)=wn
!      write(12,*)i,',',w(i)
      enddo
      return
      end
      subroutine asinn(w,nin,alpha)
      use numz
      real(b4) w(jmax)
      integer nin
      real(b4) alpha
      real(b4) pi
      integer i,j
      pi=atan(1.0_b4)*4.0_b4
!      write(*,*)'generating sin^',alpha,' window'
!      write(*,*)'window is not symetric'
      do  i=1,nin
        j=i-1
        w(i)=sin((j*pi)/float(nin))
        w(i)=w(i)**alpha
!      write(12,*)i,',',w(i)
      enddo
      return
      end
      function bessi0(x)
      use numz
      real(b4)x,bessi0
      real(b8)ax
      real(b8) y,p1,p2,p3,p4
      real(b8) p5,p6,p7
      real(b8) q1,q2,q3
      real(b8) q4,q5,q6
      real(b8) q7,q8,q9
      data p1,p2,p3,p4/1.0d0,3.5156229d0,3.0899424d0,1.2067492d0/
      data p5,p6,p7   /0.2659732d0,0.360768d-1,0.45813d-2/
      data q1,q2,q3/0.39894228d0,0.1328592d-1,0.225319d-2/
      data q4,q5,q6/-0.157565d-2,0.916281d-2,-0.2057706d-1/
      data q7,q8,q9/0.2635537d-1,-0.1647633d-1,0.392377d-2/
      if (abs(x).lt.3.75_b8) then
        y=(x/3.75_b8)**2
        bessi0=p1+y*(p2+y*(p3+y*(p4+y*(p5+y*(p6+y*p7)))))
      else
        ax=abs(x)
        y=3.75_b8/ax
        bessi0=(exp(ax)/sqrt(ax))*(q1+y*(q2+y*(q3+y*(q4+y*(q5+y*(q6+y*(q7+y*(q8+y*q9))))))))
      endif
      return
      end
