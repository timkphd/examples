subroutine wtime(i,j)
    DOUBLE PRECISION MPI_WTIME,mytime
    mytime=MPI_WTIME()
    write(*,*)mytime
    i=mytime
    mytime=mytime-i
    j=1.0e9*mytime
end subroutine
subroutine timer(sec)
    use numz
    real(b8), intent (inout) :: sec
    real(b8) nanosec
    integer i,j
    call wtime(i,j)
    nanosec=j
    sec=i
    sec=sec+1.0e-9_b8*nanosec
    return
 end subroutine timer

program test
  DOUBLE PRECISION x
  call MPI_Init ( ierror )
  read(*,*)x
  do while (x .gt. 0)
    call timer(x)
    write(*,*)x
    read(*,*)x
  end do
  call mpi_finalize(ierror )
end program
