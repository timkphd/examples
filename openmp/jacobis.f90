!AU  - Liu, Zhenying;  Chapman, Barbara; Weng, Tien-Hsiung; Hernandez, Oscar
!PY  - 2002/01/01
!SP  - 244
!EP  - 259
!SN  - 978-3-540-40435-4
!T1  - Improving the Performance of OpenMP by Array Privatization
!DO  - 10.1007/3-540-45009-2_19

module times
    double precision t1,t2,t3,t4
    ! run on nt threads
    integer, parameter :: nt=8
    integer, parameter :: onek=6000
    integer, parameter :: tfz=onek/nt
    integer, parameter :: tfo=tfz+1
    integer, parameter :: nnn=onek-1
    integer, parameter :: iter=1000
    integer, parameter :: b8=selected_real_kind(14)
    real(b8),allocatable :: A(:,:),B(:,:)
    real(b8),allocatable :: Aloc(:,:),Bloc(:,:)
!$omp threadprivate(Aloc,Bloc)

end module

subroutine org
    use times
    real(b8)  omp_get_wtime
    real(b8) c
    c=1
    allocate(A(onek,onek))
    allocate(B(onek,onek))
    CALL RANDOM_NUMBER(A)
    CALL RANDOM_NUMBER(B)
    t1=omp_get_wtime()
!$omp parallel default(shared) ,private(i,j)
    do k=1, iter 
!$omp do
        do j = 2 ,nnn
            do i = 2 , nnn
                A(i,j) = ( B(i-1,j)+B(i+1,j) + B(i,j-1)+B(i,j+1)) * c
            enddo 
        enddo
!$omp do
        do j=1, onek
            do i= 1, onek 
                B(i,j) = A(i,j)
            enddo 
        enddo
    enddo
!$omp end parallel
    t2=omp_get_wtime()
    t3=t3+(t2-t1)
end subroutine
    
subroutine mods
    use times
    implicit  none
    integer omp_get_thread_num
    integer i,j,k,start_y,end_y,id
    double precision  omp_get_wtime
!    real(b8) Aloc(onek,0:tfo),Bloc(onek,0:tfo)
!    real(b8),allocatable :: Aloc(:,:),Bloc(:,:)
!    common /bonk/ aloc,bloc 
!!$omp threadprivate(/bonk/)

    real(b8) buf_upper(onek,-1:nt+1)
    real(b8) buf_lower(onek,-1:nt+1)
    real(b8) c
!$omp parallel
    allocate(Aloc(onek,0:tfo),Bloc(onek,0:tfo))
    CALL RANDOM_NUMBER(Aloc)
    CALL RANDOM_NUMBER(bloc)
!$omp end parallel
    c=1
    t1=omp_get_wtime()
!$omp 
!$omp parallel default(shared) , private(start_y,end_y,i,j,k,id) 
    id = omp_get_thread_num()
    do k = 1, iter
        buf_upper(1:onek, id)=Bloc(1:onek,tfz)
        buf_lower(1:onek, id) = Bloc(1:onek, 1)
!$omp barrier
        Bloc(1:onek,0)=buf_upper(1:onek,id -1) 
        Bloc(1:onek,tfo)=buf_lower(1:onek,id+1)
        start_y=id*tfz+1
        end_y=(id+1)*tfz
        start_y=1
        end_y=tfo-1
        do j=start_y, end_y
            do i=2, nnn
                Aloc(i,j) = (Bloc(i-1,j) + Bloc(i+1,j)+ Bloc(i,j-1) + Bloc(i,j+1)) * c
            enddo 
        enddo
        do j=1, tfz 
            do i=1, onek
                Bloc(i,j) = Aloc(i,j) 
            enddo
        enddo 
    enddo
!$omp end parallel
    t2=omp_get_wtime()
    t4=t4+(t2-t1)
end subroutine

program wow
  use times
  integer omp_get_max_threads
  integer mt
  t3=0
  t4=0
  mt=omp_get_max_threads()
  write(*,'("OMP_NUM_THREADS=",i4," compiled to run on threads=",i4)')mt,nt
  if (nt .gt. mt)then
    write(*,'("recompile with nt=",i4,"set to mt",i4)')nt,mt
    stop
  endif
  call omp_set_num_threads(nt)
  Write(*,*)"doing org"
  call org
  Write(*,*)"doing mods"
  call mods
  write(*,*)"size=",onek," iterations=",iter
  write(*,'("original time",f10.4," modified time",f10.4," speed up",f10.4)')t3,t4,t3/t4
end program
