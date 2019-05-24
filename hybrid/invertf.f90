module uname
contains 
function unique(name,myid)
    character (len=*) name
    character (len=20) unique
    character (len=80) temp
    integer myid
    write(temp,"(a,i5.5)")trim(name),myid
    unique=temp
    return
end function unique
end module
      module mympi
        include "mpif.h"
      end module
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

subroutine invert (matrix,size)
    implicit none
    real(b8) matrix(:,:)
    integer size
    integer switch,k, jj, kp1, i, j, l, krow, irow,nmax
    parameter (nmax=1000)
    dimension switch(nmax,2)
    real(b8) pivot,temp
    do  k = 1,size
        jj = k
        if (k .ne. size) then
            kp1 = k + 1
            pivot = (matrix(k, k))
            do i = kp1,size
                temp = (matrix(i, k))
                if ( abs(pivot) .lt.  abs(temp)) then
                    pivot = temp
                    jj = i
                endif
            enddo
        endif
        switch(k, 1) = k
        switch(k, 2) = jj
        if (jj .ne. k) then
            do  j = 1 ,size 
                temp = matrix(jj, j)
                matrix(jj, j) = matrix(k, j)
                matrix(k, j) = temp
            enddo
        endif
        do j = 1,size
            if (j .ne. k)matrix(k, j) = matrix(k, j) / matrix(k, k)
        enddo
        matrix(k, k) = 1.0_b8 / matrix(k, k)
        do  i = 1,size
            if (i.ne.k) then
                do  j = 1,size
                    if(j.ne.k)matrix(i,j)=matrix(i,j)-matrix(k,j)*matrix(i,k)
                enddo
            endif
        enddo
        do i = 1, size
            if (i .ne. k)matrix(i, k) = -matrix(i, k) * matrix(k, k)
        enddo
    enddo 
    do  l = 1,size
        k = size - l + 1
        krow = switch(k, 1)
        irow = switch(k, 2)
        if (krow .ne. irow) then
            do  i = 1,size
                temp = matrix(i, krow)
                matrix(i, krow) = matrix(i, irow)
                matrix(i, irow) = temp
            enddo
        endif
    enddo
end subroutine

subroutine mset(m,  n,  in)
    real(b8) :: m(:,:)
    integer n,in
    integer i,j
    do i=1,n
        do j=1,n
            if( i .eq. j)then
                m(i,j)=in
            else
                m(i,j)=i+j
            endif
        enddo
    enddo
end subroutine

function mcheck(m,  n,  in)
    real(b8) :: m(:,:)
    real(b8) mcheck,x
    integer n,in
    integer i,j
    x=0
    do i=1,n
        do j=1,n
            if( i .eq. j)then
                x=x+abs(m(i,j)-in)
            else
                x=x+abs(m(i,J)-(i+j))
            endif
        enddo
    enddo
    mcheck=x
end function
end module ccm_numz

program tover
    use ccm_numz
    use ISO_FORTRAN_ENV
    use uname
    use mympi
    character (len=MPI_MAX_PROCESSOR_NAME):: name
    real(b8),allocatable,target :: m1(:,:),m2(:,:),m3(:,:),m4(:,:)
    real(b8), pointer :: twod(:,:)
    real(b8) dt(4)
    integer n
    integer out_old
    real(b8) t0_start;
    real(b8) t1_start,t1_end,e1;
    real(b8) t2_start,t2_end,e2;
    real(b8) t3_start,t3_end,e3;
    real(b8) t4_start,t4_end,e4;
    myid=0
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_Get_processor_name(name,nlen,ierr)
      write(*,'("Fort says Hello from",i4," on ",a)')myid,trim(name)
    n=250
    allocate(m1(n,n),m2(n,n),m3(n,n),m4(n,n))
    call mset(m1,n,1)
    call mset(m2,n,2)
    call mset(m3,n,3)
    call mset(m4,n,4)
! redirect stdout
! OUTPUT_UNIT is from ISO_FORTRAN_ENV
    out_old=OUTPUT_UNIT
    close(out_old)
    open(file=unique("out_file",myid),unit=out_old)
!
    t0_start=ccm_time()
!$omp parallel sections

!$omp section
    t1_start=ccm_time()
    call invert(m1,n)
    call invert(m1,n)
    t1_end=ccm_time()
    e1=mcheck(m1,n,1)
    t1_start=t1_start-t0_start
    t1_end=t1_end-t0_start

!$omp section
    t2_start=ccm_time()
    call invert(m2,n)
    call invert(m2,n)
    t2_end=ccm_time()
    e2=mcheck(m2,n,2)
    t2_start=t2_start-t0_start
    t2_end=t2_end-t0_start
    
!$omp section
    t3_start=ccm_time()
    call invert(m3,n)
    call invert(m3,n)
    t3_end=ccm_time()
    e3=mcheck(m3,n,3)
    t3_start=t3_start-t0_start
    t3_end=t3_end-t0_start
    
!$omp section
    t4_start=ccm_time()
    call invert(m4,n)
    call invert(m4,n)
    t4_end=ccm_time()
    e4=mcheck(m4,n,4)
    t4_start=t4_start-t0_start
    t4_end=t4_end-t0_start

!$omp end parallel sections

 write(*,1)1,t1_start,t1_end,e1
 write(*,1)2,t2_start,t2_end,e2
 write(*,1)3,t3_start,t3_end,e3
 write(*,1)4,t4_start,t4_end,e4
 1 format("section ",i4," start time= ",g10.5," end time= ",g10.5," error=",g10.5)
 !$OMP PARALLEL DO PRIVATE(twod)
      do i=1,4
      if(i .eq. 1) twod=>m1
      if(i .eq. 2) twod=>m2
      if(i .eq. 3) twod=>m3
      if(i .eq. 4) twod=>m4
      dt(i)=ccm_time()
      call invert(twod,n)
      call invert(twod,n)
      dt(i)=ccm_time()- dt(i)
      enddo    
      write(*,*)dt      
      call MPI_FINALIZE(ierr)
 end program
