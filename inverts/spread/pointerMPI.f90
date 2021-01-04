!http://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-intel-mkl-100-threading/#3
module numz
! module defines the basic real type and pi
          integer, parameter:: b8 = selected_real_kind(14)
          integer, parameter:: i8 = selected_int_kind(15)
          real(b8), parameter :: pi = 3.141592653589793239_b8
end module
      program testinvert
      use numz
      USE MKL_VSL_TYPE
      USE MKL_VSL
      implicit none
      include "mpif.h"
      character (len=MPI_MAX_PROCESSOR_NAME):: pname
      integer myid,numprocs,ierr
      real(b8), allocatable,target :: tarf(:,:,:)
      real(b8), pointer :: twod(:,:)
!     real(b8), pointer :: one(:)
      real(b8), allocatable,target :: bs(:,:)
      integer, allocatable,target :: IPIVS(:,:)
      integer, allocatable :: infos(:)
      real(b8),allocatable :: cnt1(:),cnt2(:)
      real(b8) stime,etime
      integer i,j,k,kmax
      integer omp_get_max_threads,OMP_GET_THREAD_NUM,maxthreads
      integer msize,nrays
      integer N, NRHS,LDA, LDB
      integer(i8) asize
      TYPE (VSL_STREAM_STATE), allocatable :: stream(:)
      integer , allocatable :: seed(:),errcode(:)
      integer brng,method
      real(b8) a,sigma
      pname="out.dat"
      myid=0
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(pname,nlen,ierr)
      open(unit=17,name=trim(pname))
! set up random number generators for each thread
      maxthreads=omp_get_max_threads()
      allocate(stream(maxthreads))
      allocate(seed(maxthreads))
      allocate(errcode(maxthreads))
      brng=VSL_BRNG_MCG31
      method=0
      a=1.0_b8
      sigma=1.0_b8
!$OMP PARALLEL DO
      do i=1,maxthreads
        seed(i)=i+i**2
        errcode(i)=vslnewstream(stream(i), brng,  seed(i) )
!        write(17,*)i,errcode(i)
      enddo
      msize=1000
      nrays=4
      kmax=1
      if(myid .eq. 0)then
      read(*,*)msize,nrays,kmax
      endif
      call MPI_Bcast(mysize, 1, MPI_Integer, 0, MPI_COMM_WORLD, ierr)
      call MPI_Bcast(nrays, 1, MPI_Integer, 0, MPI_COMM_WORLD, ierr)
      call MPI_Bcast(kmax, 1, MPI_Integer, 0, MPI_COMM_WORLD, ierr)
      nrhs=1
      n=msize
      lda=msize
      ldb=msize
      allocate(tarf(msize,msize,nrays))
      allocate(bs(msize,nrays))
      allocate(IPIVS(msize,nrays))
      allocate(infos(nrays))
      allocate(cnt1(nrays))
      allocate(cnt2(nrays))
!      one=>tarf(:,1,1)
! this is very bad practice
!      do i=1,(msize*msize*nrays)
!      	one(i)=i
!      enddo
!      write(17,*)size(one)
      write(17,*)"matrix size=",msize
      write(17,*)"copies=",nrays
      asize=size(tarf,kind=i8)
      write(17,'(" bytes=",i15," gbytes=",f10.3)')asize*8_i8,real(asize,b8)*8.0_b8/1073741824.0_b8
      do k=1,kmax
      write(17,*)"generating data for run",k," of ",kmax
      call my_clock(stime)
!$OMP PARALLEL DO PRIVATE(twod)
      do i=1,nrays 
        twod=>tarf(:,:,i)
        j=omp_get_thread_num()+1
        errcode(j)=vdrnggaussian( method, stream(j), msize*msize, twod, a,sigma)
!        write(17,*)"sub array ",i,j,errcode(j),twod(1,1)
      enddo
!      call RANDOM_NUMBER(bs)
!      bs=1.0_b8
      call my_clock(etime)
      write(17,'(" generating time=",f12.3," threads=",i3)'),real(etime-stime,b8),maxthreads

!      write(17,*)tarf
      write(17,*)"starting inverts"

      call my_clock(stime)

!$OMP PARALLEL DO PRIVATE(twod)
      do i=1,nrays
        twod=>tarf(:,:,i)
!        write(17,*)twod
        call my_clock(cnt1(i))
        CALL DGESV( N, NRHS, twod, LDA, IPIVs(:,i), Bs(:,i), LDB, INFOs(i) )
        call my_clock(cnt2(i))
        write(17,'(i5,i5,3(f12.3))')i,infos(i),cnt2(i),cnt1(i),real(cnt2(i)-cnt1(i),b8)
      enddo
      call my_clock(etime)
      write(17,'(" invert time=",f12.3)'),real(etime-stime,b8)
      enddo
      call MPI_FINALIZE(ierr)
      end program
!
      subroutine my_clock(x)
      use numz
      real(b8) x
      integer vals(8)
      call date_and_time(values=vals)
      x=real(vals(8),b8)/1000.0_b8
      x=x+real(vals(7),b8)
      x=x+real(vals(6),b8)*60
      x=x+real(vals(5),b8)*3600
      end subroutine

