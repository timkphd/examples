! a thread safe random number generator
module numz
!*************************************
! description:
    ! basic types module, included in all other routines
!*************************************
    integer, parameter:: b8 = selected_real_kind(p=12) ! basic real types
    integer, parameter:: b4 = selected_real_kind(p=4)
end module
module ran_mod
 contains 
    function ran1(idum)
! returns a uniform random number between 0 and 1
! see numerical recipes
! press,flannery,teukolsky & vetterling
! cambridge university press 1986 pp 191-2-3
    use numz
    implicit none
    real(b8) ran1
    integer, intent(inout), optional :: idum
    integer m1,m2,m3,ia1,ia2,ia3,ic1,ic2,ic3
    integer iff
    integer ix1,ix2,ix3,j
    real(b8) r(97),rm1,rm2
    parameter (m1=259200,ia1=7141,ic1=54773)
    parameter (m2=134456,ia2=8121,ic2=28411)
    parameter (m3=243000,ia3=4561,ic3=51349)
    data iff /0/
!$OMP THREADPRIVATE(iff,ix1,ix2,ix3,j,r,rm1,rm2) 
    save iff,ix1,ix2,ix3,j,r,rm1,rm2
    if(present(idum))then
        if (idum<0.or.iff.eq.0)then
            rm1=1.0_b8/m1
            rm2=1.0_b8/m2
            iff=1
            ix1=mod(ic1-idum,m1)
            ix1=mod(ia1*ix1+ic1,m1)
            ix2=mod(ix1,m2)
            ix1=mod(ia1*ix1+ic1,m1)
            ix3=mod(ix1,m3)
            do  j=1,97
              ix1=mod(ia1*ix1+ic1,m1)
              ix2=mod(ia2*ix2+ic2,m2)
              r(j)=(float(ix1)+float(ix2)*rm2)*rm1
            enddo 
            idum=1
        endif
    endif
    ix1=mod(ia1*ix1+ic1,m1)
    ix2=mod(ia2*ix2+ic2,m2)
    ix3=mod(ia3*ix3+ic3,m3)
    j=1+(97*ix3)/m3
    if(j>97.or.j<1)then
    write(*,*)' error in ran1 j=',j
    stop
    endif
    ran1=r(j)
    r(j)=(float(ix1)+float(ix2)*rm2)*rm1
    return
    end function ran1
    
    function gasdev()
        use numz
!        interface ran1
!            function ran1(idum)
!                use numz
!                integer, intent(inout), optional :: idum
!                real(b8) ran1
!            end function ran1
!        end interface
        implicit none
        real(b8) gasdev
        integer iset 
        real(b8) fac,gset,rsq,v1,v2
        save iset,gset
        data iset/0/ 
        if (iset.eq.0) then 
     1        v1=2.*ran1()-1. 
            v2=2.*ran1()-1. 
            rsq=v1**2+v2**2
            if(rsq.ge.1..or.rsq.eq.0.)goto 1 
            fac=sqrt(-2.*log(rsq)/rsq) 
            gset=v1*fac
            gasdev=v2*fac 
            iset=1 
        else 
            gasdev=gset 
            iset=0 
        endif 
        return 
    end function gasdev
    
    function norml(mean,sigma)
        use numz
        implicit none
        real(b8) norml
        real(b8) mean,sigma
        norml = gasdev() * sigma + mean
    end function norml

    function spread(min,max)
        use numz
        implicit none
        real(b8) spread
        real(b8) min,max
        spread=(max - min) * ran1() + min
    end function spread

end module ran_mod

program doit
   use numz
   use ran_mod
   real(b8) x
   integer omp_get_thread_num,myt
   read(*,*)iseed
!$OMP parallel
!$OMP critical
   myt=omp_get_thread_num()
   jseed=-abs(iseed)
   jseed=jseed-myt
   x=ran1(jseed)
        write(*,'("inside critical myt=",i4,f12.8)')myt,x
!$OMP end critical
!$OMP end parallel

!$OMP parallel
!$OMP critical
  myt=omp_get_thread_num()
  write(*,*)" for thread ",myt
  do i=1,20000
    x=ran1()
 !     write(*,*)i,x
   enddo
   write(*,'("final for ",i4,i8,f12.8)')myt,i-1,x
!$OMP end critical
!$OMP end parallel
end program

   
   
