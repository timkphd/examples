program test
integer omp_get_thread_num,OMP_GET_NUM_THREADS
!$OMP parallel private (myt)
        myt=omp_get_thread_num() 
        write(*,*)"thread= ",myt," of ",OMP_GET_NUM_THREADS() 
!$OMP end parallel 
end program
