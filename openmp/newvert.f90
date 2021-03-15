! some options:
! gfortran  -O3 -fopenmp newvert.f90 -o newvert
! ifort  -O3 -fopenmp newvert.f90 -o newvert
! export OMP_NUM_THREADS=4
! export OMP_SCHEDULE=dynamic 
! export OMP_SCHEDULE=static,1 
! export OMP_SCHEDULE=static,4

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
                m(i,j)=1
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
                x=x+abs(m(i,j)-1)
            endif
        enddo
    enddo
    mcheck=x
end function
end module ccm_numz

program bonk
    use ccm_numz
    implicit none
    real(b8),allocatable ::  m(:,:,:)
    real(b8),allocatable ::  t_start(:),t_end(:),e(:)
    integer n,i,nray
    real(b8) t0_start

    n=750
    nray=8
    allocate(m(n,n,nray))
    allocate(t_start(nray),t_end(nray),e(nray))
    call mset(m(:,:,1),n,10)
    call mset(m(:,:,2),n,20)
    call mset(m(:,:,3),n,30)
    call mset(m(:,:,4),n,40)
    
    t0_start=ccm_time()
!$omp parallel sections

!$omp section
    t_start(1)=ccm_time()
    call invert(m(:,:,1),n)
    call invert(m(:,:,1),n)
    t_end(1)=ccm_time()
    e(1)=mcheck(m(:,:,1),n,10)
    t_start(1)=t_start(1)-t0_start
    t_end(1)=t_end(1)-t0_start

!$omp section
    t_start(2)=ccm_time()
    call invert(m(:,:,2),n)
    call invert(m(:,:,2),n)
    t_end(2)=ccm_time()
    e(2)=mcheck(m(:,:,2),n,20)
    t_start(2)=t_start(2)-t0_start
    t_end(2)=t_end(2)-t0_start
    
!$omp section
    t_start(3)=ccm_time()
    call invert(m(:,:,3),n)
    call invert(m(:,:,3),n)
    t_end(3)=ccm_time()
    e(3)=mcheck(m(:,:,3),n,30)
    t_start(3)=t_start(3)-t0_start
    t_end(3)=t_end(3)-t0_start
    
!$omp section
    t_start(4)=ccm_time()
    call invert(m(:,:,4),n)
    call invert(m(:,:,4),n)
    t_end(4)=ccm_time()
    e(4)=mcheck(m(:,:,4),n,40)
    t_start(4)=t_start(4)-t0_start
    t_end(4)=t_end(4)-t0_start

!$omp end parallel sections
 write(*,1)1,t_start(1),t_end(1),e(1)
 write(*,1)2,t_start(2),t_end(2),e(2)
 write(*,1)3,t_start(3),t_end(3),e(3)
 write(*,1)4,t_start(4),t_end(4),e(4)
 1 format("section ",i4," start time= ",g15.5," end time= ",g15.5," error=",g15.5)
 write(*,*)
 
    do i = 1,nray
        call mset(m(:,:,i),n,i*10)
    enddo 

    t0_start=ccm_time()
!$OMP PARALLEL DO SCHEDULE (RUNTIME)
    do i = 1,nray
        t_start(i)=ccm_time()
        call invert(m(:,:,i),n)
        call invert(m(:,:,i),n)
        t_end(i)=ccm_time()
        e(i)=mcheck(m(:,:,i),n,i*10)
        t_start(i)=t_start(i)-t0_start
        t_end(i)=t_end(i)-t0_start
    enddo
!$OMP END PARALLEL DO

    do i = 1,nray
    write(*,1)i,t_start(i),t_end(i),e(i)
    enddo


end program


    