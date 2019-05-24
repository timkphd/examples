!this program is the kernel for an optical propagation program.
!it does a series of 2d ffts followed by a multiplication.
!it is modeled after the AFWL program HELP or High Energy
!Laser Propagation.
!
!it does the 2d fft by first doing a collection of 1d ffts
!then a transpose followed by a second collection of 1d ffts.
!
!the sections of the program that are commented out represent
!different ways of doing the operations.  the most interesting
!addition is using the using the subroutine shuff to generate
!a nonuniform ordering for accessing the array.

!the routines four1 was taken from the book 
!"numerical recipes in fortran, 1st addition."  
!however, the authors of that book derived their routine
!from the routine fourn that was in the AFWL program HELP.
!the original routine, fourn, contained many additional 
!options


!disclaimer:  for a production code you would most likely 
!use a vendor supplied library to do the fft instead of a
!hand written one.


module ccm_numz
! basic real types
    integer, parameter:: b8 = selected_real_kind(10)
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
end module ccm_numz

program two_d_fft
        use ccm_numz
        implicit none
!       integer size
        integer,parameter:: size=1024
!        integer omp_get_max_threads
        integer i,j,k,ijk,isign,iseed
        real(b8),allocatable:: x(:)
        integer, allocatable:: index(:)
        complex(b8), allocatable:: a(:,:)
!        complex(b8) :: a(size,size)
!        complex(b8), allocatable:: temp(:)
        complex(b8) tmp
        complex(b8) factor
        real(b8) gen,fft1,fft2,trans,totf,fact
        real(b8) t0,t1,t2,t3,t4,t5
        integer OMP_GET_MAX_THREADS
        interface
            subroutine shuff(index,m,n)
              dimension index(:)
              integer m,n
            end subroutine
        end interface
        factor=size
        factor=1.0_b8/(factor)
        iseed=-12345
        isign=1
        gen=0
        fft1=0
        fft2=0
        trans=0
        totf=0
        fact=0
!       read(12,*)size
        allocate(a(size,size))
        allocate(x(size),index(size))
        call shuff(index,size,8)
!       dummy=ran1(iseed)
!       write(*,*)"dummy=",dummy
        t0=ccm_time ()
        do j=1,size
           call random_number(x)
           do i=1,size
                a(i,j)=cmplx(x(i),0.0_b8)
           enddo
        enddo
        write(*,'(("(",g20.10,",",g20.10,")"))')a(size/2+1,size-2)
        
!        do 10 ijk=1,20  ! change to 4 to run faster
        do 10 ijk=1,20
            t1=ccm_time ()
!$OMP PARALLEL DO SCHEDULE (RUNTIME) 
            do i=1,size
                 call four1(a(:,i),size,isign)
                !call four1(a(i,:),size,isign)
            enddo
!$OMP END PARALLEL DO 
            t2=ccm_time ()
!$OMP PARALLEL DO SCHEDULE (RUNTIME) PRIVATE(i,j,k,tmp)
            do k=1,size
                i=k
! i=index(k)
                do j=i,size
! tmp=a(j,i)
! a(j,i)=a(i,j)
! a(i,j)=tmp
                    tmp=a(i,j)
                    a(i,j)=a(j,i)
                    a(j,i)=tmp
                enddo
! j=i
! temp(j:size)=a(i,j:size)
! a(i,j:size)=a(j:size,i)
! a(j:size,i)=temp(j:size)
            enddo
!$OMP END PARALLEL DO 
            t3=ccm_time ()
!$OMP PARALLEL DO SCHEDULE (RUNTIME) 
            do i=1,size
                 call four1(a(:,i),size,isign)
                !call four1(a(i,:),size,isign)
            enddo
!$OMP END PARALLEL DO 
            t4=ccm_time ()
!$OMP PARALLEL DO SCHEDULE (RUNTIME) 
            do j=1,size
            do i=1,size
                  a(i,j)=factor*a(i,j)
               enddo
            enddo
!$OMP END PARALLEL DO 
            t5=ccm_time ()
            gen=gen+t1-t0
            fft1=fft1+t2-t1
            fft2=fft2+t4-t3
            trans=trans+t3-t2
            totf=totf+t5-t1
            fact=fact+t5-t4
            isign=isign*(-1)
            write(*,'(i3)',advance="no")ijk
    10  continue
        write(*,*)
        write(*,'(("(",g20.10,",",g20.10,")"))')a(size/2+1,size-2)
        write(*,*)"number of  transforms",ijk-1
        !write(*,'("generation time= ",f7.1)')gen
        write(*,'("      fft1 time= ",f9.4)')fft1
        write(*,'(" transpose time= ",f9.4)')trans
        write(*,'("      fft2 time= ",f9.4)')fft2
        write(*,'("   scaling time= ",f9.4)')fact
        write(*,'("    total time = ",f9.4)',advance="no")totf
        write(*,'(" for matrix of size",i6)')size
        write(*,*)"THREADS   = ",OMP_GET_MAX_THREADS()
        stop
end program two_d_fft

      subroutine four1(data,nn,isign)
      use ccm_numz
      implicit none
      integer i,j,isign,nn,n,m,mmax,istep
      real(b8), parameter :: two_pi = 6.283185307179586477_b8
      real(b8) wr,wi,wpr,wpi,wtemp,theta,tempr,tempi
      real(b8) data(16384)
      n=2*nn
      j=1
      do 11 i=1,n,2
        if(j.gt.i)then
          tempr=data(j)
          tempi=data(j+1)
          data(j)=data(i)
          data(j+1)=data(i+1)
          data(i)=tempr
          data(i+1)=tempi
        endif
        m=n/2
1       if ((m.ge.2).and.(j.gt.m)) then
          j=j-m
          m=m/2
        go to 1
        endif
        j=j+m
11    continue
      mmax=2
2     if (n.gt.mmax) then
        istep=2*mmax
        theta=two_pi/(isign*mmax)
        wpr=-2.0_b8*sin(0.5_b8*theta)**2
        wpi=sin(theta)
        wr=1.0_b8
        wi=0.0_b8
        do 13 m=1,mmax,2
          do 12 i=m,n,istep
            j=i+mmax
            tempr=(wr)*data(j)-(wi)*data(j+1)
            tempi=(wr)*data(j+1)+(wi)*data(j)
            data(j)=data(i)-tempr
            data(j+1)=data(i+1)-tempi
            data(i)=data(i)+tempr
            data(i+1)=data(i+1)+tempi
12        continue
          wtemp=wr
          wr=wr*wpr-wi*wpi+wr
          wi=wi*wpr+wtemp*wpi+wi
13      continue
        mmax=istep
      go to 2
      endif
      return
      end

subroutine shuff(index,m,n)
    integer tens,ones
    dimension index(:)
    tens=n
    ones=1
    j=0
    k=1
    do while (j < m)
       j=j+1
       if(k.gt. m)then
         write(*,*)k,m
         stop
       endif
       index(k)=j
       k=k+tens
       if(k .gt. m)then
         ones=ones+1
         k=ones
       endif
    enddo
end subroutine shuff

