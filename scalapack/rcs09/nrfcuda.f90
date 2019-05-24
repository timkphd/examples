!gfortran nrfcuda.f90 -O3 -I$CULA_ROOT/include -L$CULA_ROOT/lib64 -lcula -lcula_fortran -lcublas -lcudart -o nrfcuda

module lnumz
    integer, parameter:: b4 = selected_real_kind(4)
end module
module pmatrix
interface print_matrix
      subroutine print_matrixc( desc, m, n, a, lda )
      use lnumz
      implicit none
      character*(*) desc
      integer m, n, lda
      complex(b4) a( lda, * )
      end subroutine print_matrixc
      subroutine print_matrixr( desc, m, n, a, lda )
      use lnumz
      implicit none
      character*(*) desc
      integer m, n, lda
      real(b4) a( lda, * )
      end subroutine print_matrixr
end interface
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


program bonk 
  use lnumz
  use pmatrix
        use CULA_STATUS
        use CULA_LAPACK
  implicit none
  complex (b4) a(4,4),b(4,2)
  integer indx(4)
  integer nrhs,lda,ldb
  integer N,NP,status
  !EXTERNAL CULA_INITIALIZE
  !EXTERNAL CULA_SHUTDOWN

  !INTEGER CULA_INITIALIZE
  !INTEGER CULA_cgesv

  data  a/ &
      ( 1.23,-5.50),(-2.14,-1.12),(-4.30,-7.10),( 1.27, 7.29), &
      ( 7.91,-5.38),(-9.92,-0.79),(-6.47, 2.52),( 8.90, 6.92), &
      (-9.80,-4.86),(-9.18,-1.12),(-6.51,-2.67),(-8.82, 1.25), &
      (-7.32, 7.57),( 1.37, 0.43),(-5.86, 7.38),( 5.41, 5.37)  /
  data  b/ &
      ( 8.33,-7.32),(-6.18,-4.80),(-5.71,-2.80),(-1.60, 3.08), &
      (-6.11,-3.81),( 0.14,-7.71),( 1.41, 3.40),( 8.54,-4.05)  /
  n=4
  np=4
!  call ludcmp(a,n,np,indx,id)
!  call lubksb(a,n,np,indx,b)
  nrhs=2
  lda=4
  ldb=4
!  call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
         WRITE(*,*) 'Initializing CULA'
         STATUS = CULA_INITIALIZE()
         CALL CULA_CHECK_STATUS(STATUS)

         WRITE(*,*) 'Calling CULA_cgesv'
! (int n, int nrhs, culaFloatComplex* a, int lda, culaInt* ipiv, culaFloatComplex* b, int ldb);
         status=cula_cgesv( n, nrhs, a,  lda, indx, b,ldb)
!         call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
         CALL CULA_CHECK_STATUS(STATUS)

         WRITE(*,*) 'Shutting down CULA'
         CALL CULA_SHUTDOWN()
  call print_matrix( "details of lu factorization", 4, 4, a, lda )
  call print_matrix( "solution", 4, 2, b, ldb )
end program
  
! solution
! ( -1.09, -0.18) (  1.28,  1.21)
! (  0.97,  0.52) ( -0.22, -0.97)
! ( -0.20,  0.19) (  0.53,  1.36)
! ( -0.59,  0.92) (  2.22, -1.00)
! 
! details of lu factorization
! ( -4.30, -7.10) ( -6.47,  2.52) ( -6.51, -2.67) ( -5.86,  7.38)
! (  0.49,  0.47) ( 12.26, -3.57) ( -7.87, -0.49) ( -0.98,  6.71)
! (  0.25, -0.15) ( -0.60, -0.37) (-11.70, -4.64) ( -1.35,  1.38)
! ( -0.83, -0.32) (  0.05,  0.58) (  0.93, -0.50) (  2.66,  7.86)

subroutine cgesv( n, nrhs, a, lda, ipiv, b, ldb, info )
  use lnumz
  use csolve
  implicit none
  integer n,nrhs,lda,ldb,info
  integer j
  complex(b4) :: a(lda,*),b(ldb,*)
  integer ipiv(*)
  call ludcmp(a,n,lda,ipiv,info)
  do j=1,nrhs
    call lubksb(a,n,lda,ipiv,b(:,j))
  enddo
end subroutine

      subroutine print_matrixc( desc, m, n, a, lda )
      use lnumz
      implicit none
      character*(*)    desc
      integer          m, n, lda
      complex(b4)          a( lda, * )
!
      integer          i, j
!
      write(*,*)
      write(*,*) desc
      do i = 1, m
         write(*,9998) ( a( i, j ), j = 1, n )
      end do
!
 9998 format( 11(:,1x,'(',f6.2,',',f6.2,')') )
      return
      end subroutine

      subroutine print_matrixr( desc, m, n, a, lda )
      use lnumz
      implicit none
      character*(*)    desc
      integer          m, n, lda
      real(b4)          a( lda, * )
!
      integer          i, j
!
      write(*,*)
      write(*,*) desc
      do i = 1, m
         write(*,9998) ( a( i, j ), j = 1, n )
      end do
!
 9998 format( 22(:,1x,f6.2) )
      return
      end subroutine

