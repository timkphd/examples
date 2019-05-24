!pgf90  -mp openmp.f90 -O3 -I/opt/development/gpu/current/cula/include -L/opt/development/gpu/current/cula/lib64 -lcula -lcula_fortran -lcublas -lcudart -o doopen
!qsub  -I -V -l nodes=n48 -l naccesspolicy=singlejob -l walltime=00:15:00
!export OMP_NUM_THREADS=2
module mycula
   interface
    integer(C_INT) function culaselectdevice(n) BIND(C,name="culaSelectDevice")
   use iso_c_binding, only: c_int
   integer(C_INT), value :: n
    end function
   end interface
end module
module ccm_time_mod
    integer, parameter:: b_8 = selected_real_kind(10)
    integer,save,private :: ccm_start_time(8) = (/-1, -1, -1, -1, -1, -1, -1, -1/)
contains
 function ccm_time()
        implicit none
        real(b_8) :: ccm_time,tmp
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
        tmp=real(m,b_8)+real(sec,b_8)+real(values(8),b_8)/1000.0_b_8
        if(values(1) .ne. ccm_start_time(1))then
            if(mod(ccm_start_time(1),4) .eq. 0)then
                tmp=tmp+real(leap(13),b_8)
            else
                tmp=tmp+real(norm(13),b_8)
            endif
        endif
        ccm_time=tmp
    end function
end module ccm_time_mod
module lnumz
    integer, parameter:: b_4 = selected_real_kind(4)
end module
module pmatrix
interface print_matrix
      subroutine print_matrixc( desc, m, n, a, lda )
      use lnumz
      implicit none
      character*(*) desc
      integer m, n, lda
      complex(b_4) a( lda, * )
      end subroutine print_matrixc
      subroutine print_matrixr( desc, m, n, a, lda )
      use lnumz
      implicit none
      character*(*) desc
      integer m, n, lda
      real(b_4) a( lda, * )
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
        complex(b_4) a(np,*),tiny
        complex(b_4) :: tmp
        complex(b_4) :: sum
        integer d
        parameter (tiny=1.0e-20_b_4)
        integer i,imax,j,k
        real(b_4),allocatable :: vv(:)
        real(b_4) :: aamax,dum
        allocate(vv(n))
        d=1.0_b_4
        do i=1,n
          aamax=0.0_b_4
          do j=1,n
             if(abs(a(i,j)) .gt.  aamax) aamax=abs(a(i,j))
          enddo
          if( aamax .eq. 0.0_b_4)then
              write(*,*)"sigular matrix"
              stop
          endif
          vv(i)=1.0_b_4/aamax
        enddo
        do j=1,n
          do i=1,j-1
            sum=a(i,j)
            do k=1,i-1
                sum=sum-a(i,k)*a(k,j)
            enddo
            a(i,j)=sum
          enddo
          aamax=0.0_b_4
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
          if(a(j,j) .eq. 0.0_b_4)a(j,j)=tiny
          if(j .ne. n)then
            tmp=1.0_b_4/a(j,j)
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
         complex(b_4) :: a(np,np),b(n)
         integer i,ii,j,ll
         complex(b_4) sum
         ii=0
         do i=1,n
           ll=indx(i)
           sum=b(ll)
           b(ll)=b(i)
           if (ii .ne. 0)then
             do j=ii,i-1
               sum=sum-a(i,j)*b(j)
             enddo
           else if (sum .ne. 0.0_b_4) then
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
  use ccm_time_mod
  use cula_status
  use cula_lapack
  use mycula
  implicit none
  integer, parameter:: msize=4000
  
  complex (b_4) a(msize,msize),b(msize,2)
  complex (b_4) a1(msize,msize),b1(msize,2)
  complex (b_4) a2(msize,msize),b2(msize,2)
  complex (b_4) a3(msize,msize),b3(msize,2)
  complex (b_4) a4(msize,msize),b4(msize,2)
  real(b_8)time1_1,time1_2,time1_3,time1_4
  real(b_8)time2_1,time2_2,time2_3,time2_4
  real(b_8)time3_1,time3_2,time3_3,time3_4
  real(b_8)time4_1,time4_2,time4_3,time4_4

  integer indx(msize),idiag
  integer nrhs,lda,ldb
  integer N,NP,status
  integer  omp_get_thread_num

  EXTERNAL CULA_INITIALIZE
  EXTERNAL CULA_SHUTDOWN

!  INTEGER CULA_INITIALIZE
!  integer cula_SelectDevice
!  integer culaSelectDevice
!  INTEGER CULA_cgesv

!  data  a/ &
!      ( 1.23,-5.50),(-2.14,-1.12),(-4.30,-7.10),( 1.27, 7.29), &
!      ( 7.91,-5.38),(-9.92,-0.79),(-6.47, 2.52),( 8.90, 6.92), &
!      (-9.80,-4.86),(-9.18,-1.12),(-6.51,-2.67),(-8.82, 1.25), &
!      (-7.32, 7.57),( 1.37, 0.43),(-5.86, 7.38),( 5.41, 5.37)  /
!  data  b/ &
!      ( 8.33,-7.32),(-6.18,-4.80),(-5.71,-2.80),(-1.60, 3.08), &
!      (-6.11,-3.81),( 0.14,-7.71),( 1.41, 3.40),( 8.54,-4.05)  /
  n=msize
  np=msize
!  call ludcmp(a,n,np,indx,id)
!  call lubksb(a,n,np,indx,b)
  nrhs=2
  lda=msize
  ldb=msize
  a=cmplx(1e-5,1e-5)
  do idiag=1,msize
          a(idiag,idiag)=cmplx(1,2)
  enddo
  b=1.0 
  a1=a
  a2=a
  a3=a
  a4=a
  b1=b
  b2=b
  b3=b
  b4=b
  
!$omp parallel sections
!$omp section
         WRITE(*,*) 'cula_SelectDevice CULA',omp_get_thread_num()
         STATUS=culaSelectDevice(omp_get_thread_num())
         CALL CHECK_STATUS(STATUS)
         WRITE(*,*) 'Initializing CULA',omp_get_thread_num()
         time1_1=ccm_time()
         STATUS = CULA_INITIALIZE()
         time1_2=ccm_time()
         CALL CHECK_STATUS(STATUS)

         WRITE(*,*) 'Calling CULA_cgesv'
! (int n, int nrhs, culaFloatComplex* a, int lda, culaInt* ipiv, culaFloatComplex* b, int ldb);
         time1_3=ccm_time()
         status=cula_cgesv( n, nrhs, a1,  lda, indx, b1,ldb)
         time1_4=ccm_time()
!         call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
         CALL CHECK_STATUS(STATUS)
!$omp section
         WRITE(*,*) 'cula_SelectDevice CULA',omp_get_thread_num()
         STATUS=culaSelectDevice(omp_get_thread_num())
         CALL CHECK_STATUS(STATUS)
         WRITE(*,*) 'Initializing CULA',omp_get_thread_num()
         time2_1=ccm_time()
         STATUS = CULA_INITIALIZE()
         time2_2=ccm_time()
         CALL CHECK_STATUS(STATUS)

         WRITE(*,*) 'Calling CULA_cgesv'
! (int n, int nrhs, culaFloatComplex* a, int lda, culaInt* ipiv, culaFloatComplex* b, int ldb);
         time2_3=ccm_time()
         status=cula_cgesv( n, nrhs, a2,  lda, indx, b2,ldb)
         time2_4=ccm_time()
!         call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
         CALL CHECK_STATUS(STATUS)
!$omp section
         WRITE(*,*) 'cula_SelectDevice CULA',omp_get_thread_num()
         STATUS=culaSelectDevice(omp_get_thread_num())
         CALL CHECK_STATUS(STATUS)
         WRITE(*,*) 'Initializing CULA',omp_get_thread_num()
         time3_1=ccm_time()
         STATUS = CULA_INITIALIZE()
         time3_2=ccm_time()
         CALL CHECK_STATUS(STATUS)

         WRITE(*,*) 'Calling CULA_cgesv'
! (int n, int nrhs, culaFloatComplex* a, int lda, culaInt* ipiv, culaFloatComplex* b, int ldb);
         time3_3=ccm_time()
         status=cula_cgesv( n, nrhs, a3,  lda, indx, b3,ldb)
         time3_4=ccm_time()
!         call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
!$omp section
         WRITE(*,*) 'culaSelectDevice CULA',omp_get_thread_num()
         STATUS=culaSelectDevice(omp_get_thread_num())
         CALL CHECK_STATUS(STATUS)
         WRITE(*,*) 'Initializing CULA',omp_get_thread_num()
         time4_1=ccm_time()
         STATUS = CULA_INITIALIZE()
         time4_2=ccm_time()
         CALL CHECK_STATUS(STATUS)

         WRITE(*,*) 'Calling CULA_cgesv'
! (int n, int nrhs, culaFloatComplex* a, int lda, culaInt* ipiv, culaFloatComplex* b, int ldb);
         time4_3=ccm_time()
         status=cula_cgesv( n, nrhs, a4,  lda, indx, b4,ldb)
         time4_4=ccm_time()
!         call cgesv( n, nrhs, a, lda, indx, b, ldb, info )
!$omp end parallel sections

         WRITE(*,*) 'Shutting down CULA'
         CALL CULA_SHUTDOWN()
  call print_matrix( "details of lu factorization", 4, 4, a1, lda )
  call print_matrix( "solution", 4, 2, b1, ldb )
  call print_matrix( "details of lu factorization", 4, 4, a2, lda )
  call print_matrix( "solution", 4, 2, b2, ldb )
  write(*,"(a18,a18)")"init time","invert time"
  write(*,"(2f18.3)")time1_2-time1_1,time1_4-time1_3
  write(*,"(2f18.3)")time2_2-time2_1,time2_4-time2_3
  write(*,"(2f18.3)")time3_2-time3_1,time3_4-time3_3
  write(*,"(2f18.3)")time4_2-time4_1,time4_4-time4_3
  write(*,"(36x,a18,a18)")"start invert","end invert"
  write(*,"(4f18.3)")time1_1,time1_2,time1_3,time1_4
  write(*,"(4f18.3)")time2_1,time2_2,time2_3,time2_4
  write(*,"(4f18.3)")time3_1,time3_2,time3_3,time3_4
  write(*,"(4f18.3)")time4_1,time4_2,time4_3,time4_4
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
  complex(b_4) :: a(lda,*),b(ldb,*)
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
      complex(b_4)          a( lda, * )
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
      real(b_4)          a( lda, * )
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


      SUBROUTINE CHECK_STATUS(STATUS)
      use cula_status
         INTEGER STATUS
!         INTEGER INFO
!         INTEGER CULA_GETERRORINFO

         IF (STATUS .NE. 0) THEN
            IF (STATUS .EQ. 6) THEN
!              culaArgumentError
               INFO = cula_get_error_info()
               WRITE(*,*) 'Invalid value for parameter ', INFO
            ELSE IF (STATUS .EQ. 9) THEN
!              culaRuntimeError
               INFO = cula_get_error_info()
               WRITE(*,*) 'Runtime error (', INFO ,')'
            ELSE
!              others
!               call CULA_GETSTATUSSTRING(STATUS)
                write(*,*)"status not 0",status
            ENDIF
            STOP 1
         END IF
      END

