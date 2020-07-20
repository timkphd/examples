program tover
    use ccm_numz
    real(b8),allocatable :: m1(:,:),m2(:,:),m3(:,:),m4(:,:)
    integer n
    real(b8) t0_start;
    real(b8) t1_start,t1_end,e1;
    real(b8) t2_start,t2_end,e2;
    real(b8) t3_start,t3_end,e3;
    real(b8) t4_start,t4_end,e4;

    n=400
    allocate(m1(n,n),m2(n,n),m3(n,n),m4(n,n))
    call mset(m1,n,10)
    call mset(m2,n,20)
    call mset(m3,n,30)
    call mset(m4,n,40)
    t0_start=ccm_time()
!$omp parallel sections

!$omp section
    t1_start=ccm_time()
    call invert(m1,n)
    call invert(m1,n)
    t1_end=ccm_time()
    e1=mcheck(m1,n,10)
    t1_start=t1_start-t0_start
    t1_end=t1_end-t0_start

!$omp section
    t2_start=ccm_time()
    call invert(m2,n)
    call invert(m2,n)
    t2_end=ccm_time()
    e2=mcheck(m2,n,20)
    t2_start=t2_start-t0_start
    t2_end=t2_end-t0_start
    
!$omp section
    t3_start=ccm_time()
    call invert(m3,n)
    call invert(m3,n)
    t3_end=ccm_time()
    e3=mcheck(m3,n,30)
    t3_start=t3_start-t0_start
    t3_end=t3_end-t0_start
    
!$omp section
    t4_start=ccm_time()
    call invert(m4,n)
    call invert(m4,n)
    t4_end=ccm_time()
    e4=mcheck(m4,n,40)
    t4_start=t4_start-t0_start
    t4_end=t4_end-t0_start

!$omp end parallel sections

 write(*,1)1,t1_start,t1_end,e1
 write(*,1)2,t2_start,t2_end,e2
 write(*,1)3,t3_start,t3_end,e3
 write(*,1)4,t4_start,t4_end,e4
 1 format("section ",i4," start time= ",g12.5," end time= ",g12.5," error=",g12.5)
 end program

    
