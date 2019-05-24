!gfortran cudaonly.f90 -o3 -i$cula_root/include -l$cula_root/lib64 -lcula -lcula_fortran -lcublas -lcudart -o nrfcuda

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

program bonk 
  use lnumz
  use pmatrix
  complex (b4) a(4,4),b(4,2)
  integer indx(4)
  integer nrhs,lda,ldb,info
  external cula_initialize
  external cula_shutdown

  integer cula_initialize
  integer cula_cgesv

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
  nrhs=2
  lda=4
  ldb=4
! the next line is the mkl/lapack call to solve this system
!  call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
         write(*,*) 'initializing cula'
         status = cula_initialize()
         call check_status(status)

         write(*,*) 'calling cula_cgesv'
!                         (int n, int nrhs, culafloatcomplex* a, 
!                          int lda, culaint* ipiv, culafloatcomplex* b, 
!                          int ldb);
         status=cula_cgesv( n, nrhs, a,  lda, indx, b,ldb)
!         call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
         call check_status(status)

         write(*,*) 'shutting down cula'
         call cula_shutdown()
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
      subroutine check_status(status)
         integer status
         integer info
         integer cula_geterrorinfo

         if (status .ne. 0) then
            if (status .eq. 6) then
!              culaargumenterror
               info = cula_geterrorinfo()
               write(*,*) 'invalid value for parameter ', info
            else if (status .eq. 9) then
!              cularuntimeerror
               info = cula_geterrorinfo()
               write(*,*) 'runtime error (', info ,')'
            else
!              others
               call cula_getstatusstring(status)
            endif
            stop 1
         end if
      end

