module lnumz
    integer, parameter:: b4 = selected_real_kind(4)
end module
module csolve
    use lnumz
    contains
        subroutine ludcmp(a,n,np,indx,d)
        use lnumz
        implicit none
        integer n,np,indx(n)
        complex(b4) a(np,*),tiny
        complex(b4) :: tmp
        complex(b4) :: sum
        integer d
        parameter (tiny=1.0e-20_b4)
        integer i,imax,j,k
        real(b4),allocatable :: vv(:)
        real(b4) :: aamax,dum
        allocate(vv(n))
        d=1.0_b4
        do i=1,n
          aamax=0.0_b4
          do j=1,n
             if(abs(a(i,j)) .gt.  aamax) aamax=abs(a(i,j))
          enddo
          if( aamax .eq. 0.0_b4)then
              write(*,*)"sigular matrix"
              stop
          endif
          vv(i)=1.0_b4/aamax
        enddo
        do j=1,n
          do i=1,j-1
            sum=a(i,j)
            do k=1,i-1
                sum=sum-a(i,k)*a(k,j)
            enddo
            a(i,j)=sum
          enddo
          aamax=0.0_b4
          do i=j,n
            sum=a(i,j)
            do k=1,j-1
              sum=sum-a(i,k)*a(k,j)
            enddo
            a(i,j)=sum
            dum=vv(i)*abs(sum)
            if (dum .ge. aamax)then
              imax=i
              aamax=dum
            endif
          enddo
          if ( j .ne. imax)then
            do k=1,n
              tmp=a(imax,k)
              a(imax,k)=a(j,k)
              a(j,k)=tmp
            enddo
            d=-d
            vv(imax)=vv(j)
          endif
          indx(j)=imax
          if(a(j,j) .eq. 0.0_b4)a(j,j)=tiny
          if(j .ne. n)then
            tmp=1.0_b4/a(j,j)
            do i=j+1,n
                a(i,j)=a(i,j)*tmp
            enddo
          endif
         enddo
         deallocate(vv)
         end subroutine

         subroutine lubksb(a,n,np,indx,b)
         use lnumz
         implicit none 
         integer n,np,indx(n)
         complex(b4) :: a(np,np),b(n)
         integer i,ii,j,ll
         complex(b4) sum
         ii=0
         do i=1,n
           ll=indx(i)
           sum=b(ll)
           b(ll)=b(i)
           if (ii .ne. 0)then
             do j=ii,i-1
               sum=sum-a(i,j)*b(j)
             enddo
           else if (sum .ne. 0.0_b4) then
             ii=i
           endif
           b(i)=sum
         enddo
         do i=n,1,-1
           sum=b(i)
           do j=i+1,n
             sum=sum-a(i,j)*b(j)
           enddo
             b(i)=sum/a(i,i)
         enddo
         end subroutine
end module
subroutine cgesv( n, nrhs, a, lda, ipiv, b, ldb, info )
  use lnumz
  use csolve
  implicit none
  integer n,nrhs,lda,ldb,info,id
  integer j
  complex(b4) :: a(lda,*),b(ldb,*)
  integer ipiv(*)
  call ludcmp(a,n,lda,ipiv,id)
  info=0
  do j=1,nrhs
    call lubksb(a,n,lda,ipiv,b(:,j))
  enddo
end subroutine

