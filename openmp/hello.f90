program hybrid
    implicit none
    integer myid,ierr
    integer mylen,core
    integer, external :: findmycpu
    CHARACTER(len=255) :: myname
    integer OMP_GET_MAX_THREADS,OMP_GET_THREAD_NUM
    Call Get_environment_variable("SLURMD_NODENAME",myname)
    if(len_trim(myname) .eq. 0)then
      Call Get_environment_variable("HOSTNAME",myname)
    endif
    myid=0
!$OMP PARALLEL
!$OMP CRITICAL
  core=findmycpu() 
  write(unit=*,fmt="(i4,a,a)",advance="no")myid," running on ",trim(myname)
  write(unit=*,fmt="(a,i2,a,i2,a,i8)")" thread= ",OMP_GET_THREAD_NUM()," of ",OMP_GET_MAX_THREADS()," on core",core
!$OMP END CRITICAL
!$OMP END PARALLEL
end program

