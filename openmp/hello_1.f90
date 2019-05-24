program hybrid
    implicit none
    integer OMP_GET_MAX_THREADS,OMP_GET_THREAD_NUM
!$OMP PARALLEL
!$OMP CRITICAL
  write(unit=*,fmt="(a,i2,a,i2i)")" thread= ",OMP_GET_THREAD_NUM()," of ",OMP_GET_MAX_THREADS()
!$OMP END CRITICAL
!$OMP END PARALLEL
end program

