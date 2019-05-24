      program boz6
c234567
c
      parameter (jmax=131072,iwork=2*jmax+15)
      real wind(jmax),x(jmax),work(iwork)
	  data x/jmax*1.0/
      write(*,*)'window type'
      write(*,*)'1 - kaiser-bessel (alpha=3.0)'
      write(*,*)'2 - sin^2'
      write(*,*)'3 - rectangle'
      write(*,*)'4 - 74 db blackman-harris'
      read(*,*)iwt
      write(*,*)' how many points per sample '
      write(*,*)' 0 - other'
      write(*,*)' 1 -    256'
      write(*,*)' 2 -    512'
      write(*,*)' 3 -   1024'
      write(*,*)' 4 -   2048'
      write(*,*)' 5 -   4096'
      write(*,*)' 6 -   8192'
      write(*,*)' 7 -  16384'
      write(*,*)' 8 -  32768'
      write(*,*)' 9 -  65536'
      write(*,*)'10 - 131072'
      read(*,*)imax
      if(imax.eq.0)then
      write(*,*)' enter the other number'
      read(*,*)imax
      else
      imax=2**(imax+7)
      endif
	  nn=imax
	  time1=secnds(0.0)
      call appwin(x,wind,nn,iwt)
	  time2=secnds(0.0)
	  call rffti(nn,work)
      call rfftf(nn,x,work)
	  time3=secnds(0.0)
      if(iwt .eq. 4)write(*,*)'a 74 db balckman-harris window was used'
      if(iwt .eq. 3)write(*,*)'a uniform window was used'
      if(iwt .eq. 2)write(*,*)'a sin^2 window was used'
      if(iwt.eq.1)write(*,*)'a kaiser-bessel (alpha=3) window was used'
	  write(*,*)"time for window generation = ",time2-time1
	  write(*,*)"time for fft of ",nn," points  = ",time3-time2
	  write(*,"(2f20.5)")(x(i),i=1,imax)
      stop
      end


      subroutine kb(w,nin,alpha)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension w(jmax)
c      write(*,*)'generating kaiser-bessel window a=',alpha
c      write(*,*)'window is symetric'
      pi=3.14159265358979
      f=pi*alpha
      bign=nin-1.0
      bot=bessi0(f)
      top=1.0/bot
      o2=bign/2.0
      o2=o2*o2
      n2p=nin/2
      n2m=-n2p
      do 1 i=1,nin
      zn=(i-1)-bign/2.0
      z=1.0-zn*zn/o2
      if(z.lt.0.0)z=0.0
      wn=top*bessi0(f*sqrt(z))
      w(i)=wn
c     write(12,*)i,',',w(i)
 1    continue
      return
      end
      function bessi0(x)
      real*8 y,p1,p2,p3,p4,p5,p6,p7,
     *    q1,q2,q3,q4,q5,q6,q7,q8,q9
      data p1,p2,p3,p4,p5,p6,p7/1.0d0,3.5156229d0,3.0899424d0,1.2067492d
     *0,
     *    0.2659732d0,0.360768d-1,0.45813d-2/
      data q1,q2,q3,q4,q5,q6,q7,q8,q9/0.39894228d0,0.1328592d-1,
     *    0.225319d-2,-0.157565d-2,0.916281d-2,-0.2057706d-1,
     *    0.2635537d-1,-0.1647633d-1,0.392377d-2/
      if (abs(x).lt.3.75) then
        y=(x/3.75)**2
        bessi0=p1+y*(p2+y*(p3+y*(p4+y*(p5+y*(p6+y*p7)))))
      else
        ax=abs(x)
        y=3.75/ax
        bessi0=(exp(ax)/sqrt(ax))*(q1+y*(q2+y*(q3+y*(q4
     *      +y*(q5+y*(q6+y*(q7+y*(q8+y*q9))))))))
      endif
      return
      end
      subroutine sinn(w,nin,alpha)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension w(jmax)
      pi=3.14159265358979
c      write(*,*)'generating sin^',alpha,' window'
c      write(*,*)'window is symetric'
      do 66 i=1,nin
      j=i-1
      w(i)=sin((j*pi)/float(nin-1))
      w(i)=w(i)**alpha
c      write(12,*)i,',',w(i)
 66   continue
      return
      end
      subroutine win1(w,nin,alpha)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension w(jmax)
c      write(*,*)'generating a uniform window'
      do 66 i=0,nin-1
      w(i+1)=1
 66   continue
      return
      end
      subroutine remdc(x,n)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension x(jmax)
      dc=0.0
      rn=n
      do 1 i=1,n
 1      dc=dc+x(i)
      dc=dc/rn
      do 2 i=1,n
 2      x(i)=x(i)-dc
      return
      end
      subroutine addz(x,n,m)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension x(jmax)
      dc=0.0
      if(m.le.n)return
      do 1 i=n+1,m
 1      x(i)=0.0
      return
      end
      subroutine appwin(x,wind,n,iwt)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension x(jmax)
      dimension wind(jmax)
c define the window
      if(iwt .eq. 4)then
      call bh(wind,n,1.0)
      endif
      if(iwt .eq. 3)then
      call win1(wind,n,1.0)
      endif
      if(iwt .eq. 2)then
      call asinn(wind,n,2.0)
      endif
      if(iwt.eq.1)then
      call akb(wind,n,3.0)
      endif
c apply it
      do 1 i=1,n
 1      x(i)=x(i)*wind(i)
      return
      end
      subroutine bh(w,nin,alpha)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension w(jmax)
	  dimension a(0:3)
	  data a/0.40217,0.49703,0.09392,0.00183/
c      write(*,*)'generating blackman harris window 74db'
c      write(*,*)'window is not symetric'
	  pi2n=3.141592653589793239*2.0/nin
	  do 1 n=0,nin-1
	  wn=a(0)-a(1)*cos(pi2n*n)+a(2)*cos(pi2n*2*n)-a(3)*cos(pi2n*3*n)
	  w(n+1)=wn
 1    continue
      return
	  end
      subroutine akb(w,nin,alpha)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension w(jmax)
c      write(*,*)'generating kaiser-bessel window a=',alpha
c      write(*,*)'window is not symetric'
      pi=3.14159265358979
      f=pi*alpha
      bign=nin-1.0
      bot=bessi0(f)
      top=1.0/bot
      o2=nin/2.0
      o2=o2*o2
      n2p=nin/2
      n2m=-n2p
      do 1 n=n2m,n2p-1
      z=1.0-n*n/o2
      if(z.lt.0.0)z=0.0
      wn=top*bessi0(f*sqrt(z))
      i=(n-n2m)+1
      w(i)=wn
c      write(12,*)i,',',w(i)
 1    continue
      return
      end

      subroutine asinn(w,nin,alpha)
      parameter (jmax=131072,mmax=400000,iwork=2*jmax+15)
      dimension w(jmax)
      pi=3.14159265358979
c      write(*,*)'generating sin^',alpha,' window'
c      write(*,*)'window is not symetric'
      do 66 i=1,nin
      j=i-1
      w(i)=sin((j*pi)/float(nin))
      w(i)=w(i)**alpha
c      write(12,*)i,',',w(i)
 66   continue
      return
      end
      subroutine rfftf(n,r,wsave)
c***begin prologue  rfftf
c***date written   790601   (yymmdd)
c***revision date  861211   (yymmdd)
c***category no.  j1a1
c***keywords  library=slatec,type=single precision(rfftf-s cfftf-c),
c             fourier transform
c***author  swarztrauber, p. n., (ncar)
c***purpose  forward transform of a real, periodic sequence.
c***description
c
c  subroutine rfftf computes the fourier coefficients of a real
c  perodic sequence (fourier analysis).  the transform is defined
c  below at output parameter r.
c
c  input parameters
c
c  n       the length of the array r to be transformed.  the method
c          is most efficient when n is a product of small primes.
c          n may change so long as different work arrays are provided
c
c  r       a real array of length n which contains the sequence
c          to be transformed
c
c  wsave   a work array which must be dimensioned at least 2*n+15
c          in the program that calls rfftf.  the wsave array must be
c          initialized by calling subroutine rffti(n,wsave), and a
c          different wsave array must be used for each different
c          value of n.  this initialization does not have to be
c          repeated so long as n remains unchanged.  thus subsequent
c          transforms can be obtained faster than the first.
c          the same wsave array can be used by rfftf and rfftb.
c
c
c  output parameters
c
c  r       r(1) = the sum from i=1 to i=n of r(i)
c
c          if n is even set l = n/2; if n is odd set l = (n+1)/2
c
c            then for k = 2,...,l
c
c               r(2*k-2) = the sum from i = 1 to i = n of
c
c                    r(i)*cos((k-1)*(i-1)*2*pi/n)
c
c               r(2*k-1) = the sum from i = 1 to i = n of
c
c                   -r(i)*sin((k-1)*(i-1)*2*pi/n)
c
c          if n is even
c
c               r(n) = the sum from i = 1 to i = n of
c
c                    (-1)**(i-1)*r(i)
c
c   *****  note:
c               this transform is unnormalized since a call of rfftf
c               followed by a call of rfftb will multiply the input
c               sequence by n.
c
c  wsave   contains results which must not be destroyed between
c          calls of rfftf or rfftb.
c***references  (none)
c***routines called  rfftf1
c***end prologue  rfftf
      dimension       r(*)       ,wsave(*)
c***first executable statement  rfftf
      if (n .eq. 1) return
      call rfftf1 (n,r,wsave,wsave(n+1),wsave(2*n+1))
      return
      end
      subroutine radf2(ido,l1,cc,ch,wa1)
c***begin prologue  radf2
c***refer to  rfftf
c***routines called  (none)
c***end prologue  radf2
      dimension       ch(ido,2,l1)           ,cc(ido,l1,2)           ,
     1                wa1(*)
c***first executable statement  radf2
      do 101 k=1,l1
         ch(1,1,k) = cc(1,k,1)+cc(1,k,2)
         ch(ido,2,k) = cc(1,k,1)-cc(1,k,2)
  101 continue
      if (ido-2) 107,105,102
  102 idp2 = ido+2
      if((ido-1)/2.lt.l1) go to 108
      do 104 k=1,l1
cdir$ ivdep
         do 103 i=3,ido,2
            ic = idp2-i
            tr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            ti2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            ch(i,1,k) = cc(i,k,1)+ti2
            ch(ic,2,k) = ti2-cc(i,k,1)
            ch(i-1,1,k) = cc(i-1,k,1)+tr2
            ch(ic-1,2,k) = cc(i-1,k,1)-tr2
  103    continue
  104 continue
      go to 111
  108 do 110 i=3,ido,2
         ic = idp2-i
cdir$ ivdep
         do 109 k=1,l1
            tr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            ti2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            ch(i,1,k) = cc(i,k,1)+ti2
            ch(ic,2,k) = ti2-cc(i,k,1)
            ch(i-1,1,k) = cc(i-1,k,1)+tr2
            ch(ic-1,2,k) = cc(i-1,k,1)-tr2
  109    continue
  110 continue
  111 if (mod(ido,2) .eq. 1) return
  105 do 106 k=1,l1
         ch(1,2,k) = -cc(ido,k,2)
         ch(ido,1,k) = cc(ido,k,1)
  106 continue
  107 return
      end
      subroutine radf3(ido,l1,cc,ch,wa1,wa2)
c***begin prologue  radf3
c***refer to  rfftf
c***routines called  (none)
c***end prologue  radf3
      dimension       ch(ido,3,l1)           ,cc(ido,l1,3)           ,
     1                wa1(*)     ,wa2(*)
      save taur, taui
      data taur,taui /-.5,.866025403784439/
c***first executable statement  radf3
      do 101 k=1,l1
         cr2 = cc(1,k,2)+cc(1,k,3)
         ch(1,1,k) = cc(1,k,1)+cr2
         ch(1,3,k) = taui*(cc(1,k,3)-cc(1,k,2))
         ch(ido,2,k) = cc(1,k,1)+taur*cr2
  101 continue
      if (ido .eq. 1) return
      idp2 = ido+2
      if((ido-1)/2.lt.l1) go to 104
      do 103 k=1,l1
cdir$ ivdep
         do 102 i=3,ido,2
            ic = idp2-i
            dr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            di2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            dr3 = wa2(i-2)*cc(i-1,k,3)+wa2(i-1)*cc(i,k,3)
            di3 = wa2(i-2)*cc(i,k,3)-wa2(i-1)*cc(i-1,k,3)
            cr2 = dr2+dr3
            ci2 = di2+di3
            ch(i-1,1,k) = cc(i-1,k,1)+cr2
            ch(i,1,k) = cc(i,k,1)+ci2
            tr2 = cc(i-1,k,1)+taur*cr2
            ti2 = cc(i,k,1)+taur*ci2
            tr3 = taui*(di2-di3)
            ti3 = taui*(dr3-dr2)
            ch(i-1,3,k) = tr2+tr3
            ch(ic-1,2,k) = tr2-tr3
            ch(i,3,k) = ti2+ti3
            ch(ic,2,k) = ti3-ti2
  102    continue
  103 continue
      return
  104 do 106 i=3,ido,2
         ic = idp2-i
cdir$ ivdep
         do 105 k=1,l1
            dr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            di2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            dr3 = wa2(i-2)*cc(i-1,k,3)+wa2(i-1)*cc(i,k,3)
            di3 = wa2(i-2)*cc(i,k,3)-wa2(i-1)*cc(i-1,k,3)
            cr2 = dr2+dr3
            ci2 = di2+di3
            ch(i-1,1,k) = cc(i-1,k,1)+cr2
            ch(i,1,k) = cc(i,k,1)+ci2
            tr2 = cc(i-1,k,1)+taur*cr2
            ti2 = cc(i,k,1)+taur*ci2
            tr3 = taui*(di2-di3)
            ti3 = taui*(dr3-dr2)
            ch(i-1,3,k) = tr2+tr3
            ch(ic-1,2,k) = tr2-tr3
            ch(i,3,k) = ti2+ti3
            ch(ic,2,k) = ti3-ti2
  105    continue
  106 continue
      return
      end
      subroutine radf4(ido,l1,cc,ch,wa1,wa2,wa3)
c***begin prologue  radf4
c***refer to  rfftf
c***routines called  (none)
c***end prologue  radf4
      dimension       cc(ido,l1,4)           ,ch(ido,4,l1)           ,
     1                wa1(*)     ,wa2(*)     ,wa3(*)
      save hsqt2
      data hsqt2 /.7071067811865475/
c***first executable statement  radf4
      do 101 k=1,l1
         tr1 = cc(1,k,2)+cc(1,k,4)
         tr2 = cc(1,k,1)+cc(1,k,3)
         ch(1,1,k) = tr1+tr2
         ch(ido,4,k) = tr2-tr1
         ch(ido,2,k) = cc(1,k,1)-cc(1,k,3)
         ch(1,3,k) = cc(1,k,4)-cc(1,k,2)
  101 continue
      if (ido-2) 107,105,102
  102 idp2 = ido+2
      if((ido-1)/2.lt.l1) go to 111
      do 104 k=1,l1
cdir$ ivdep
         do 103 i=3,ido,2
            ic = idp2-i
            cr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            ci2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            cr3 = wa2(i-2)*cc(i-1,k,3)+wa2(i-1)*cc(i,k,3)
            ci3 = wa2(i-2)*cc(i,k,3)-wa2(i-1)*cc(i-1,k,3)
            cr4 = wa3(i-2)*cc(i-1,k,4)+wa3(i-1)*cc(i,k,4)
            ci4 = wa3(i-2)*cc(i,k,4)-wa3(i-1)*cc(i-1,k,4)
            tr1 = cr2+cr4
            tr4 = cr4-cr2
            ti1 = ci2+ci4
            ti4 = ci2-ci4
            ti2 = cc(i,k,1)+ci3
            ti3 = cc(i,k,1)-ci3
            tr2 = cc(i-1,k,1)+cr3
            tr3 = cc(i-1,k,1)-cr3
            ch(i-1,1,k) = tr1+tr2
            ch(ic-1,4,k) = tr2-tr1
            ch(i,1,k) = ti1+ti2
            ch(ic,4,k) = ti1-ti2
            ch(i-1,3,k) = ti4+tr3
            ch(ic-1,2,k) = tr3-ti4
            ch(i,3,k) = tr4+ti3
            ch(ic,2,k) = tr4-ti3
  103    continue
  104 continue
      go to 110
  111 do 109 i=3,ido,2
         ic = idp2-i
cdir$ ivdep
         do 108 k=1,l1
            cr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            ci2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            cr3 = wa2(i-2)*cc(i-1,k,3)+wa2(i-1)*cc(i,k,3)
            ci3 = wa2(i-2)*cc(i,k,3)-wa2(i-1)*cc(i-1,k,3)
            cr4 = wa3(i-2)*cc(i-1,k,4)+wa3(i-1)*cc(i,k,4)
            ci4 = wa3(i-2)*cc(i,k,4)-wa3(i-1)*cc(i-1,k,4)
            tr1 = cr2+cr4
            tr4 = cr4-cr2
            ti1 = ci2+ci4
            ti4 = ci2-ci4
            ti2 = cc(i,k,1)+ci3
            ti3 = cc(i,k,1)-ci3
            tr2 = cc(i-1,k,1)+cr3
            tr3 = cc(i-1,k,1)-cr3
            ch(i-1,1,k) = tr1+tr2
            ch(ic-1,4,k) = tr2-tr1
            ch(i,1,k) = ti1+ti2
            ch(ic,4,k) = ti1-ti2
            ch(i-1,3,k) = ti4+tr3
            ch(ic-1,2,k) = tr3-ti4
            ch(i,3,k) = tr4+ti3
            ch(ic,2,k) = tr4-ti3
  108    continue
  109 continue
  110 if (mod(ido,2) .eq. 1) return
  105 do 106 k=1,l1
         ti1 = -hsqt2*(cc(ido,k,2)+cc(ido,k,4))
         tr1 = hsqt2*(cc(ido,k,2)-cc(ido,k,4))
         ch(ido,1,k) = tr1+cc(ido,k,1)
         ch(ido,3,k) = cc(ido,k,1)-tr1
         ch(1,2,k) = ti1-cc(ido,k,3)
         ch(1,4,k) = ti1+cc(ido,k,3)
  106 continue
  107 return
      end
      subroutine radf5(ido,l1,cc,ch,wa1,wa2,wa3,wa4)
c***begin prologue  radf5
c***refer to  rfftf
c***routines called  (none)
c***end prologue  radf5
      dimension       cc(ido,l1,5)           ,ch(ido,5,l1)           ,
     1                wa1(*)     ,wa2(*)     ,wa3(*)     ,wa4(*)
      save tr11, ti11, tr12, ti12
      data tr11,ti11,tr12,ti12 /.309016994374947,.951056516295154,
     1-.809016994374947,.587785252292473/
c***first executable statement  radf5
      do 101 k=1,l1
         cr2 = cc(1,k,5)+cc(1,k,2)
         ci5 = cc(1,k,5)-cc(1,k,2)
         cr3 = cc(1,k,4)+cc(1,k,3)
         ci4 = cc(1,k,4)-cc(1,k,3)
         ch(1,1,k) = cc(1,k,1)+cr2+cr3
         ch(ido,2,k) = cc(1,k,1)+tr11*cr2+tr12*cr3
         ch(1,3,k) = ti11*ci5+ti12*ci4
         ch(ido,4,k) = cc(1,k,1)+tr12*cr2+tr11*cr3
         ch(1,5,k) = ti12*ci5-ti11*ci4
  101 continue
      if (ido .eq. 1) return
      idp2 = ido+2
      if((ido-1)/2.lt.l1) go to 104
      do 103 k=1,l1
cdir$ ivdep
         do 102 i=3,ido,2
            ic = idp2-i
            dr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            di2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            dr3 = wa2(i-2)*cc(i-1,k,3)+wa2(i-1)*cc(i,k,3)
            di3 = wa2(i-2)*cc(i,k,3)-wa2(i-1)*cc(i-1,k,3)
            dr4 = wa3(i-2)*cc(i-1,k,4)+wa3(i-1)*cc(i,k,4)
            di4 = wa3(i-2)*cc(i,k,4)-wa3(i-1)*cc(i-1,k,4)
            dr5 = wa4(i-2)*cc(i-1,k,5)+wa4(i-1)*cc(i,k,5)
            di5 = wa4(i-2)*cc(i,k,5)-wa4(i-1)*cc(i-1,k,5)
            cr2 = dr2+dr5
            ci5 = dr5-dr2
            cr5 = di2-di5
            ci2 = di2+di5
            cr3 = dr3+dr4
            ci4 = dr4-dr3
            cr4 = di3-di4
            ci3 = di3+di4
            ch(i-1,1,k) = cc(i-1,k,1)+cr2+cr3
            ch(i,1,k) = cc(i,k,1)+ci2+ci3
            tr2 = cc(i-1,k,1)+tr11*cr2+tr12*cr3
            ti2 = cc(i,k,1)+tr11*ci2+tr12*ci3
            tr3 = cc(i-1,k,1)+tr12*cr2+tr11*cr3
            ti3 = cc(i,k,1)+tr12*ci2+tr11*ci3
            tr5 = ti11*cr5+ti12*cr4
            ti5 = ti11*ci5+ti12*ci4
            tr4 = ti12*cr5-ti11*cr4
            ti4 = ti12*ci5-ti11*ci4
            ch(i-1,3,k) = tr2+tr5
            ch(ic-1,2,k) = tr2-tr5
            ch(i,3,k) = ti2+ti5
            ch(ic,2,k) = ti5-ti2
            ch(i-1,5,k) = tr3+tr4
            ch(ic-1,4,k) = tr3-tr4
            ch(i,5,k) = ti3+ti4
            ch(ic,4,k) = ti4-ti3
  102    continue
  103 continue
      return
  104 do 106 i=3,ido,2
         ic = idp2-i
cdir$ ivdep
         do 105 k=1,l1
            dr2 = wa1(i-2)*cc(i-1,k,2)+wa1(i-1)*cc(i,k,2)
            di2 = wa1(i-2)*cc(i,k,2)-wa1(i-1)*cc(i-1,k,2)
            dr3 = wa2(i-2)*cc(i-1,k,3)+wa2(i-1)*cc(i,k,3)
            di3 = wa2(i-2)*cc(i,k,3)-wa2(i-1)*cc(i-1,k,3)
            dr4 = wa3(i-2)*cc(i-1,k,4)+wa3(i-1)*cc(i,k,4)
            di4 = wa3(i-2)*cc(i,k,4)-wa3(i-1)*cc(i-1,k,4)
            dr5 = wa4(i-2)*cc(i-1,k,5)+wa4(i-1)*cc(i,k,5)
            di5 = wa4(i-2)*cc(i,k,5)-wa4(i-1)*cc(i-1,k,5)
            cr2 = dr2+dr5
            ci5 = dr5-dr2
            cr5 = di2-di5
            ci2 = di2+di5
            cr3 = dr3+dr4
            ci4 = dr4-dr3
            cr4 = di3-di4
            ci3 = di3+di4
            ch(i-1,1,k) = cc(i-1,k,1)+cr2+cr3
            ch(i,1,k) = cc(i,k,1)+ci2+ci3
            tr2 = cc(i-1,k,1)+tr11*cr2+tr12*cr3
            ti2 = cc(i,k,1)+tr11*ci2+tr12*ci3
            tr3 = cc(i-1,k,1)+tr12*cr2+tr11*cr3
            ti3 = cc(i,k,1)+tr12*ci2+tr11*ci3
            tr5 = ti11*cr5+ti12*cr4
            ti5 = ti11*ci5+ti12*ci4
            tr4 = ti12*cr5-ti11*cr4
            ti4 = ti12*ci5-ti11*ci4
            ch(i-1,3,k) = tr2+tr5
            ch(ic-1,2,k) = tr2-tr5
            ch(i,3,k) = ti2+ti5
            ch(ic,2,k) = ti5-ti2
            ch(i-1,5,k) = tr3+tr4
            ch(ic-1,4,k) = tr3-tr4
            ch(i,5,k) = ti3+ti4
            ch(ic,4,k) = ti4-ti3
  105    continue
  106 continue
      return
      end
      subroutine radfg(ido,ip,l1,idl1,cc,c1,c2,ch,ch2,wa)
c***begin prologue  radfg
c***refer to  rfftf
c***routines called  (none)
c***end prologue  radfg
      dimension       ch(ido,l1,ip)          ,cc(ido,ip,l1)          ,
     1                c1(ido,l1,ip)          ,c2(idl1,ip),
     2                ch2(idl1,ip)           ,wa(*)
      save tpi
      data tpi/6.28318530717959/
c***first executable statement  radfg
      arg = tpi/float(ip)
      dcp = cos(arg)
      dsp = sin(arg)
      ipph = (ip+1)/2
      ipp2 = ip+2
      idp2 = ido+2
      nbd = (ido-1)/2
      if (ido .eq. 1) go to 119
      do 101 ik=1,idl1
         ch2(ik,1) = c2(ik,1)
  101 continue
      do 103 j=2,ip
         do 102 k=1,l1
            ch(1,k,j) = c1(1,k,j)
  102    continue
  103 continue
      if (nbd .gt. l1) go to 107
      is = -ido
      do 106 j=2,ip
         is = is+ido
         idij = is
         do 105 i=3,ido,2
            idij = idij+2
            do 104 k=1,l1
               ch(i-1,k,j) = wa(idij-1)*c1(i-1,k,j)+wa(idij)*c1(i,k,j)
               ch(i,k,j) = wa(idij-1)*c1(i,k,j)-wa(idij)*c1(i-1,k,j)
  104       continue
  105    continue
  106 continue
      go to 111
  107 is = -ido
      do 110 j=2,ip
         is = is+ido
         do 109 k=1,l1
            idij = is
cdir$ ivdep
            do 108 i=3,ido,2
               idij = idij+2
               ch(i-1,k,j) = wa(idij-1)*c1(i-1,k,j)+wa(idij)*c1(i,k,j)
               ch(i,k,j) = wa(idij-1)*c1(i,k,j)-wa(idij)*c1(i-1,k,j)
  108       continue
  109    continue
  110 continue
  111 if (nbd .lt. l1) go to 115
      do 114 j=2,ipph
         jc = ipp2-j
         do 113 k=1,l1
cdir$ ivdep
            do 112 i=3,ido,2
               c1(i-1,k,j) = ch(i-1,k,j)+ch(i-1,k,jc)
               c1(i-1,k,jc) = ch(i,k,j)-ch(i,k,jc)
               c1(i,k,j) = ch(i,k,j)+ch(i,k,jc)
               c1(i,k,jc) = ch(i-1,k,jc)-ch(i-1,k,j)
  112       continue
  113    continue
  114 continue
      go to 121
  115 do 118 j=2,ipph
         jc = ipp2-j
         do 117 i=3,ido,2
            do 116 k=1,l1
               c1(i-1,k,j) = ch(i-1,k,j)+ch(i-1,k,jc)
               c1(i-1,k,jc) = ch(i,k,j)-ch(i,k,jc)
               c1(i,k,j) = ch(i,k,j)+ch(i,k,jc)
               c1(i,k,jc) = ch(i-1,k,jc)-ch(i-1,k,j)
  116       continue
  117    continue
  118 continue
      go to 121
  119 do 120 ik=1,idl1
         c2(ik,1) = ch2(ik,1)
  120 continue
  121 do 123 j=2,ipph
         jc = ipp2-j
         do 122 k=1,l1
            c1(1,k,j) = ch(1,k,j)+ch(1,k,jc)
            c1(1,k,jc) = ch(1,k,jc)-ch(1,k,j)
  122    continue
  123 continue
c
      ar1 = 1.
      ai1 = 0.
      do 127 l=2,ipph
         lc = ipp2-l
         ar1h = dcp*ar1-dsp*ai1
         ai1 = dcp*ai1+dsp*ar1
         ar1 = ar1h
         do 124 ik=1,idl1
            ch2(ik,l) = c2(ik,1)+ar1*c2(ik,2)
            ch2(ik,lc) = ai1*c2(ik,ip)
  124    continue
         dc2 = ar1
         ds2 = ai1
         ar2 = ar1
         ai2 = ai1
         do 126 j=3,ipph
            jc = ipp2-j
            ar2h = dc2*ar2-ds2*ai2
            ai2 = dc2*ai2+ds2*ar2
            ar2 = ar2h
            do 125 ik=1,idl1
               ch2(ik,l) = ch2(ik,l)+ar2*c2(ik,j)
               ch2(ik,lc) = ch2(ik,lc)+ai2*c2(ik,jc)
  125       continue
  126    continue
  127 continue
      do 129 j=2,ipph
         do 128 ik=1,idl1
            ch2(ik,1) = ch2(ik,1)+c2(ik,j)
  128    continue
  129 continue
c
      if (ido .lt. l1) go to 132
      do 131 k=1,l1
         do 130 i=1,ido
            cc(i,1,k) = ch(i,k,1)
  130    continue
  131 continue
      go to 135
  132 do 134 i=1,ido
         do 133 k=1,l1
            cc(i,1,k) = ch(i,k,1)
  133    continue
  134 continue
  135 do 137 j=2,ipph
         jc = ipp2-j
         j2 = j+j
         do 136 k=1,l1
            cc(ido,j2-2,k) = ch(1,k,j)
            cc(1,j2-1,k) = ch(1,k,jc)
  136    continue
  137 continue
      if (ido .eq. 1) return
      if (nbd .lt. l1) go to 141
      do 140 j=2,ipph
         jc = ipp2-j
         j2 = j+j
         do 139 k=1,l1
cdir$ ivdep
            do 138 i=3,ido,2
               ic = idp2-i
               cc(i-1,j2-1,k) = ch(i-1,k,j)+ch(i-1,k,jc)
               cc(ic-1,j2-2,k) = ch(i-1,k,j)-ch(i-1,k,jc)
               cc(i,j2-1,k) = ch(i,k,j)+ch(i,k,jc)
               cc(ic,j2-2,k) = ch(i,k,jc)-ch(i,k,j)
  138       continue
  139    continue
  140 continue
      return
  141 do 144 j=2,ipph
         jc = ipp2-j
         j2 = j+j
         do 143 i=3,ido,2
            ic = idp2-i
            do 142 k=1,l1
               cc(i-1,j2-1,k) = ch(i-1,k,j)+ch(i-1,k,jc)
               cc(ic-1,j2-2,k) = ch(i-1,k,j)-ch(i-1,k,jc)
               cc(i,j2-1,k) = ch(i,k,j)+ch(i,k,jc)
               cc(ic,j2-2,k) = ch(i,k,jc)-ch(i,k,j)
  142       continue
  143    continue
  144 continue
      return
      end
      subroutine rfftf1(n,c,ch,wa,ifac)
c***begin prologue  rfftf1
c***refer to  rfftf
c***routines called  radf2,radf3,radf4,radf5,radfg
c***end prologue  rfftf1
      dimension       ch(*)      ,c(*)       ,wa(*)      ,ifac(*)
c***first executable statement  rfftf1
      nf = ifac(2)
      na = 1
      l2 = n
      iw = n
      do 111 k1=1,nf
         kh = nf-k1
         ip = ifac(kh+3)
         l1 = l2/ip
         ido = n/l2
         idl1 = ido*l1
         iw = iw-(ip-1)*ido
         na = 1-na
         if (ip .ne. 4) go to 102
         ix2 = iw+ido
         ix3 = ix2+ido
         if (na .ne. 0) go to 101
         call radf4 (ido,l1,c,ch,wa(iw),wa(ix2),wa(ix3))
         go to 110
  101    call radf4 (ido,l1,ch,c,wa(iw),wa(ix2),wa(ix3))
         go to 110
  102    if (ip .ne. 2) go to 104
         if (na .ne. 0) go to 103
         call radf2 (ido,l1,c,ch,wa(iw))
         go to 110
  103    call radf2 (ido,l1,ch,c,wa(iw))
         go to 110
  104    if (ip .ne. 3) go to 106
         ix2 = iw+ido
         if (na .ne. 0) go to 105
         call radf3 (ido,l1,c,ch,wa(iw),wa(ix2))
         go to 110
  105    call radf3 (ido,l1,ch,c,wa(iw),wa(ix2))
         go to 110
  106    if (ip .ne. 5) go to 108
         ix2 = iw+ido
         ix3 = ix2+ido
         ix4 = ix3+ido
         if (na .ne. 0) go to 107
         call radf5 (ido,l1,c,ch,wa(iw),wa(ix2),wa(ix3),wa(ix4))
         go to 110
  107    call radf5 (ido,l1,ch,c,wa(iw),wa(ix2),wa(ix3),wa(ix4))
         go to 110
  108    if (ido .eq. 1) na = 1-na
         if (na .ne. 0) go to 109
         call radfg (ido,ip,l1,idl1,c,c,c,ch,ch,wa(iw))
         na = 1
         go to 110
  109    call radfg (ido,ip,l1,idl1,ch,ch,ch,c,c,wa(iw))
         na = 0
  110    l2 = l1
  111 continue
      if (na .eq. 1) return
      do 112 i=1,n
         c(i) = ch(i)
  112 continue
      return
      end
      subroutine rffti(n,wsave)
c***begin prologue  rffti
c***date written   790601   (yymmdd)
c***revision date  861211   (yymmdd)
c***category no.  j1a1
c***keywords  library=slatec,type=single precision(rffti-s cffti-c),
c             fourier transform
c***author  swarztrauber, p. n., (ncar)
c***purpose  initialize for rfftf and rfftb.
c***description
c
c  subroutine rffti initializes the array wsave which is used in
c  both rfftf and rfftb.  the prime factorization of n together with
c  a tabulation of the trigonometric functions are computed and
c  stored in wsave.
c
c  input parameter
c
c  n       the length of the sequence to be transformed.
c
c  output parameter
c
c  wsave   a work array which must be dimensioned at least 2*n+15.
c          the same work array can be used for both rfftf and rfftb
c          as long as n remains unchanged.  different wsave arrays
c          are required for different values of n.  the contents of
c          wsave must not be changed between calls of rfftf or rfftb.
c***references  (none)
c***routines called  rffti1
c***end prologue  rffti
      dimension       wsave(*)
c***first executable statement  rffti
      if (n .eq. 1) return
      call rffti1 (n,wsave(n+1),wsave(2*n+1))
      return
      end
      subroutine rffti1(n,wa,ifac)
c***begin prologue  rffti1
c***refer to  rffti
c***routines called  (none)
c***end prologue  rffti1
      dimension       wa(*)      ,ifac(*)    ,ntryh(4)
      save ntryh
      data ntryh(1),ntryh(2),ntryh(3),ntryh(4)/4,2,3,5/
c***first executable statement  rffti1
      nl = n
      nf = 0
      j = 0
  101 j = j+1
      if (j-4) 102,102,103
  102 ntry = ntryh(j)
      go to 104
  103 ntry = ntry+2
  104 nq = nl/ntry
      nr = nl-ntry*nq
      if (nr) 101,105,101
  105 nf = nf+1
      ifac(nf+2) = ntry
      nl = nq
      if (ntry .ne. 2) go to 107
      if (nf .eq. 1) go to 107
      do 106 i=2,nf
         ib = nf-i+2
         ifac(ib+2) = ifac(ib+1)
  106 continue
      ifac(3) = 2
  107 if (nl .ne. 1) go to 104
      ifac(1) = n
      ifac(2) = nf
      tpi = 6.28318530717959
      argh = tpi/float(n)
      is = 0
      nfm1 = nf-1
      l1 = 1
      if (nfm1 .eq. 0) return
      do 110 k1=1,nfm1
         ip = ifac(k1+2)
         ld = 0
         l2 = l1*ip
         ido = n/l2
         ipm = ip-1
         do 109 j=1,ipm
            ld = ld+l1
            i = is
            argld = float(ld)*argh
            fi = 0.
            do 108 ii=3,ido,2
               i = i+2
               fi = fi+1.
               arg = fi*argld
               wa(i-1) = cos(arg)
               wa(i) = sin(arg)
  108       continue
            is = is+ido
  109    continue
         l1 = l2
  110 continue
      return
      end