program ompf
    integer OMP_GET_THREAD_NUM,OMP_GET_NUM_THREADS
    logical wt(0:3)
!$OMP parallel
        myt=omp_get_thread_num()
        write(*,*)"myt= ",myt," of ",OMP_GET_NUM_THREADS()
!$OMP end parallel
!$OMP parallel
!$OMP critical
        myt=omp_get_thread_num()
        write(*,*)"inside critical myt= ",myt
!$OMP end critical
!$OMP end parallel
    x=0.0
!$OMP parallel do
    do n=1,8
       if(n .eq. 1)then
          call my_wait(x)
       endif
!$OMP critical
       write(*,*)n,omp_get_thread_num()
!$OMP end critical
    enddo
    write (*,*)"*********"
    x=10.0
!$OMP parallel do
    do n=1,8
       if(n .eq. 1)then
          call my_wait(x)
       endif
!$OMP critical
       write(*,*)n,omp_get_thread_num()
!$OMP end critical
    enddo
end
subroutine my_wait(x)
    real x
    integer ct1,ct2,cr,cm,cend
    if(x .le. 0.0)return
    call system_clock(ct1,cr,cm)
    cend=ct1+nint(x*float(cr))
    do
      call system_clock(ct2)
      if(ct2 .lt. ct1)ct2=ct1+cm
      if(ct2 .ge. cend)return
    enddo
end subroutine

