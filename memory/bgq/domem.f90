module tracking 
  use iso_Fortran_env
  contains
! Function to return the stack usage.
! The value "base is not used but is
! here to be compatable with another
! version of the function.
    function stack_count_usage(base)
    integer(int64) stack_count_usage 
    integer(int64) base
    real(real64)hu,su,ha,sa
    call memory_info(hu,su,ha,sa)
    stack_count_usage=int(su,int64)
    end function
end module

module wrap
  contains
! A recursive routine to fill up the
! stack.  Note: it is in general not
! a good idea to print from within
! a recursive routine.  It is actually
! against standard to do it from a
! recursive function.
recursive subroutine sumit(n,x,base)
        use tracking
        integer n
        real x
        integer(int64) base
        real  :: sblock(10000)
        sblock=1
        x=sum(sblock)+x
        write(*,'("stack inside",i8,1x,i2)')stack_count_usage(base),n
        n=n+1
        if(n < 10 )then
          call sumit(n,x,base)
          write(*,'("   unwinding",i8,1x,i2)')stack_count_usage(base),n
        endif
end 


end module
program test_mem
    use iso_Fortran_env
    use iso_C_binding
    use wrap
    integer(int64)i,k,j
!    integer(int32)x
    integer(c_int)x
    integer(int32),allocatable:: z(:)
    integer(int64) base
    real(real64)hu,su,ha,sa 
    real c
    integer n
    inquire(iolength=j)x
    write(*,*)j,c_Sizeof(x)
! Print compiler information
! just because we can.
    write(*,*)compiler_options()
    write(*,*)compiler_version()
! Print our header
    write(*,'(31x,"heap used", &
&              4x,"stack used",&
&              4x,"heap avail",&
&              3x,"stack avail")')
! Just keep allocating/deallocating
! larger blocks of memory until we
! run out of space.

    do i=10,44
    if(i > 27)then
      k=(i-27)*(2**28)
    else
      k=2**i
    endif
    allocate(z(k),stat=ierr)
    if(ierr > 0)then
      write(*,*)"allocation error",c_Sizeof(x)*k
!      stop
       exit
    endif
! We want to runt this loop in parallel
! just because it is faster.
!#omp parallel
    do j=1,k
      z(j)=1
    enddo
! Note that values returned from memory_info
! are 8 byte reals (strange)
    call memory_info(hu,su,ha,sa)
    write(*,'("check ",i4,i16,4(1x,en13.3))')i,c_Sizeof(x)*k,hu,su,ha,sa
    deallocate(z)
    enddo
    c=0.0
    base=0
    n=0
! If there is an extra argument on the 
! command line we call the recursive
! routine with the first argument a
! constant.  Why?  This crashes when
! we use gfortran and we get a nice
! core file.
    if (command_argument_count() .gt. 0)then
      call sumit(0,c,base)
    else
      call sumit(n,c,base)
    endif
    write(*,*)c
    stop
end program


