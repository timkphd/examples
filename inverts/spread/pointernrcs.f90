!http://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-intel-mkl-100-threading/#3

module numz
! module defines the basic real type and pi
          integer, parameter:: b8 = selected_real_kind(14)
          integer, parameter:: i8 = selected_int_kind(15)
          real(b8), parameter :: pi = 3.141592653589793239_b8
end module
      program testinvert
      use numz
      implicit none
      real(b8), allocatable,target :: tarf(:,:,:)
      real(b8), pointer :: twod(:,:)
!     real(b8), pointer :: one(:)
      real(b8), allocatable,target :: bs(:,:)
      real(b8), allocatable :: cs(:)
      integer, allocatable,target :: IPIVS(:,:)
      integer, allocatable :: infos(:)
      real(b8),allocatable :: cnt1(:),cnt2(:)
      real(b8) stime,etime
      integer i,j,k,kmax
      integer omp_get_max_threads,OMP_GET_THREAD_NUM,maxthreads
      integer msize,nrays
      integer N, NRHS,LDA, LDB
      integer(i8) asize
      integer idiag
!papi stuff start
      include "f90papi.h"
      integer*8 values(10)
      integer ijk
      integer events(7)
      integer eventnum
      integer availcounters
      integer retval
      integer tests_quiet, get_quiet
      external get_quiet
      character*PAPI_MAX_STR_LEN name
      integer len_trim
      external len_trim
      eventnum = 2
      call PAPIf_num_counters(availcounters)
      if (eventnum .GT. availcounters) then
         print *, "Not enough hardware counters!"
         stop
      end if

      retval = PAPI_VER_CURRENT
      call PAPIf_library_init(retval)
      if ( retval.NE.PAPI_VER_CURRENT) then
        write(*,*)"papi fail version"
        stop
      end if
      events(1)=PAPI_L1_DCM
      events(2)=PAPI_L2_DCM 
      events(3)=PAPI_L1_DCH 
      events(4)=PAPI_L2_TCH
!      events(1)=PAPI_FP_INS
!      events(2)=PAPI_TOT_CYC
!papi stuff end
! set up random number generators for each thread
      maxthreads=0
      maxthreads=omp_get_max_threads()
      if( maxthreads .gt. 1)write(*,*)" WARNING! PAIP enabled with maxthreads=",maxthreads
      msize=1000
      nrays=4
      kmax=1
      read(*,*)msize,nrays,kmax
      nrhs=1
      n=msize
      lda=msize
      ldb=msize
      allocate(tarf(msize,msize,nrays))
      allocate(bs(msize,nrays))
      allocate(cs(msize))
      allocate(IPIVS(msize,nrays))
      allocate(infos(nrays))
      allocate(cnt1(nrays))
      allocate(cnt2(nrays))
      infos=0
!      one=>tarf(:,1,1)
! this is very bad practice
!      do i=1,(msize*msize*nrays)
!      	one(i)=i
!      enddo
!      write(*,*)size(one)
      write(*,*)"matrix size=",msize
      write(*,*)"copies=",nrays
      asize=size(tarf,kind=i8)
      write(*,'(" bytes=",i15," gbytes=",f10.3)')asize*8_i8,real(asize,b8)*8.0_b8/1073741824.0_b8
      write(*,*)"not using lapack for inverts"
      do k=1,kmax
      write(*,*)"generating data for run",k," of ",kmax
      call my_clock(stime)
      tarf=1.0
!$OMP PARALLEL DO PRIVATE(twod,idiag,j)
      do i=1,nrays
        twod=>tarf(:,:,i)
        do idiag=1,msize
          twod(idiag,idiag)=10.0
        enddo
      enddo
       bs=1.0_b8
      call my_clock(etime)
      write(*,'(" generating time=",f12.3," threads=",i3)'),real(etime-stime,b8),maxthreads

!      write(*,*)tarf
      write(*,*)"starting inverts"

      call my_clock(stime)

!$OMP PARALLEL DO PRIVATE(twod)
      do i=1,nrays
        twod=>tarf(:,:,i)
!        write(*,*)twod
        call my_clock(cnt1(i))
!papi stuff start
        call PAPIf_start_counters(events, eventnum, retval)
        if ( retval .NE. PAPI_OK ) then
          write(*,*)"papi failed starting counters"
        stop
        end if
!papi stuff end
!          CALL DGESV( N, NRHS, twod, LDA, IPIVs(:,i), Bs(:,i), LDB, INFOs(i) )
          call invert(twod,N)
          call backsub(twod,Bs(:,i),cs,n)
!papi stuff start
        call PAPIf_stop_counters(values, eventnum, retval)
        do ijk=1,eventnum
          call PAPIf_event_code_to_name (events(ijk), name, retval)
          write(*,*)trim(name),values(ijk)
        enddo 
!papi stuff end
        call my_clock(cnt2(i))
        write(*,'(i5,i5,3(f12.3))')i,infos(i),cnt2(i),cnt1(i),real(cnt2(i)-cnt1(i),b8)
      enddo
      call my_clock(etime)
      write(*,'(" invert time=",f12.3)'),real(etime-stime,b8)
      enddo
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
module maxsize
        integer nmax
        parameter  (nmax=10000)
end module
    subroutine backsub(a,b,c,m)
        use numz
        use maxsize
        implicit none
        integer m,n,i,k
        real(b8) a(m,m),b(m),c(m)
        n=m
        do  i=1,m
          c(i)=0.0_b8
          do  k=1,n
            c(i)=c(i)+a(i,k)*b(k)
          enddo
        enddo
        return
    end subroutine
    subroutine invert (matrix,size)
    use numz
    use maxsize
    implicit none
    integer switch,k, jj, kp1, i, j, l, krow, irow,size
    dimension switch(nmax,2)
    real(b8) matrix(size,size)
    real(b8) pivot, temp
    do 100 k = 1,size
    jj = k
        if (k .ne. size) then
        kp1 = k + 1
        pivot = (matrix(k, k))
        do 1 i = kp1,size
        temp = (matrix(i, k))
        if (abs(pivot) .lt. abs(temp)) then
        pivot = temp
        jj = i
        endif
 1  continue
        endif
    switch(k, 1) = k
    switch(k, 2) = jj
    if (jj .ne. k) then
        do 2  j = 1 ,size 
    temp = matrix(jj, j)
    matrix(jj, j) = matrix(k, j)
    matrix(k, j) = temp
 2  continue
    endif
    do 3 j = 1,size
    if (j .ne. k)matrix(k, j) = matrix(k, j) / matrix(k, k)
 3  continue
    matrix(k, k) = 1.0 / matrix(k, k)
    do 4 i = 1,size
    if (i.ne.k) then
    do 40 j = 1,size
    if(j.ne.k)matrix(i,j)=matrix(i,j)-matrix(k,j)*matrix(i,k)
 40 continue
    endif
 4  continue
    do 5 i = 1, size
    if (i .ne. k)matrix(i, k) = -matrix(i, k) * matrix(k, k)
 5  continue
 100    continue
    do 6 l = 1,size
    k = size - l + 1
    krow = switch(k, 1)
    irow = switch(k, 2)
    if (krow .ne. irow) then
    do 60 i = 1,size
    temp = matrix(i, krow)
    matrix(i, krow) = matrix(i, irow)
    matrix(i, irow) = temp
 60 continue
    endif
 6  continue
    return
    end

