!
!   -- MAGMA (version 1.0) --
!      Univ. of Tennessee, Knoxville
!      Univ. of California, Berkeley
!      Univ. of Colorado, Denver
!      November 2010
!
!  @generated c
!
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

      module mympi
        include "mpif.h"
      end module

      program testing_cgetrf_gpu_f

      use magma
      use mympi
      use ccm_time_mod

      external cublas_init, cublas_set_matrix, cublas_get_matrix
      external cublas_shutdown, cublas_alloc
      external clange, cgemm, cgesv, slamch

      real clange, slamch
      integer cublas_alloc

      real              :: rnumber(2), Anorm, Bnorm, Rnorm, Xnorm 
      real, allocatable :: work(:)
      complex, allocatable       :: h_A(:), h_B(:), h_X(:)
      magma_devptr_t                :: devptrA, devptrB
      integer,    allocatable       :: ipiv(:)

      complex                    :: zone, mzone
      integer                       :: i, n, info, stat, lda
      integer                       :: size_of_elt, nrhs
      real(kind=8)                  :: flops, t
      integer                       :: tstart(2), tend(2)
      real(b_8)time1,time2

      PARAMETER          ( nrhs = 1, zone = 1., mzone = -1. )
      integer ierr,myid,numprocs,nlen
      character (len=MPI_MAX_PROCESSOR_NAME):: name
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(name,nlen,ierr)
	write(*,*)"myid=",myid 
      ierr=cudaSetDevice(myid)
      call cublas_init()

      n   = 2048
      lda  = n
      ldda = ((n+31)/32)*32
      size_of_elt = sizeof_complex
 
!------ Allocate CPU memory
      allocate(h_A(lda*n))
      allocate(h_B(lda*nrhs))
      allocate(h_X(lda*nrhs))
      allocate(work(n))
      allocate(ipiv(n))

!------ Allocate GPU memory
      stat = cublas_alloc(ldda*n, size_of_elt, devPtrA)
      if (stat .ne. 0) then
         write(*,*) "device memory allocation failed"
         stop
      endif

      stat = cublas_alloc(ldda*nrhs, size_of_elt, devPtrB)
      if (stat .ne. 0) then
         write(*,*) "device memory allocation failed"
         stop
      endif

!---- Initializa the matrix
      do i=1,lda*n
         call random_number(rnumber)
         h_A(i) = rnumber(1)
      end do

      do i=1,lda*nrhs
        call random_number(rnumber)
        h_B(i) = rnumber(1)
      end do
      h_X(:) = h_B(:)

!---- devPtrA = h_A
      call cublas_set_matrix(n, n, size_of_elt, h_A, lda, devptrA, ldda)

!---- devPtrB = h_B
      call cublas_set_matrix(n, nrhs, size_of_elt, h_B, lda, devptrB, ldda)

!---- Call magma LU ----------------
      call magma_gettime_f(tstart)
      time1=ccm_time()
      call magmaf_cgetrf_gpu(n, n, devptrA, ldda, ipiv, info)
      time2=ccm_time()
      call magma_gettime_f(tend)
      write(*,"(i4,3f15.3)")myid,time1,time2,time2-time1

      if ( info .ne. 0 )  then
         write(*,*) "Info : ", info
      end if

!---- Call magma solve -------------
      call magmaf_cgetrs_gpu('n', n, nrhs, devptrA, ldda, ipiv, devptrB, ldda, info)

      if ( info .ne. 0 )  then
         write(*,*) "Info : ", info
      end if

!---- h_X = devptrB
      call cublas_get_matrix (n, nrhs, size_of_elt, devptrB, ldda, h_X, lda)

!---- Compare the two results ------
      Anorm = clange('I', n, n,    h_A, lda, work)
      Bnorm = clange('I', n, nrhs, h_B, lda, work)
      Xnorm = clange('I', n, nrhs, h_X, lda, work)
      call cgemm('n', 'n', n,  nrhs, n, zone, h_A, lda, h_X, lda, mzone, h_B, lda)
      Rnorm = clange('I', n, nrhs, h_B, lda, work)

      write(*,*)
      write(*,*  ) 'Solving A x = b using LU factorization:'
      write(*,105) '  || A || = ', Anorm
      write(*,105) '  || b || = ', Bnorm
      write(*,105) '  || x || = ', Xnorm
      write(*,105) '  || b - A x || = ', Rnorm

      flops = 2. * n * n * n / 3.  
      call magma_gettimervalue_f(tstart, tend, t)

      write(*,*)   '  Gflops  = ',  flops / t / 1e6
      write(*,*)

      Rnorm = Rnorm / ( (Anorm*Xnorm+Bnorm) * n * slamch('E') )

      if ( Rnorm > 60. ) then
         write(*,105) '  Solution is suspicious, ', Rnorm
      else
         write(*,105) '  Solution is CORRECT' 
      end if

!---- Free CPU memory
      deallocate(h_A, h_X, h_B, work, ipiv)

!---- Free GPU memory
      call cublas_free(devPtrA)
      call cublas_free(devPtrB)
      call cublas_shutdown()

 105  format((a35,es10.3))
      call MPI_FINALIZE(ierr)
      end
