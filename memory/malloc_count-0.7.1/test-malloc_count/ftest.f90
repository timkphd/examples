module tracking
    integer, parameter:: i8 = selected_int_kind(14)
end module
program xyz
    use tracking
    implicit none
    integer(i8) malloc_count_peak,malloc_count_current
    integer(i8) stack_count_usage,stack_count_clear
    integer(i8)base
    integer n
    real x
    real, allocatable :: block(:)
    base=stack_count_clear()
    write(*,'(20x,"            ",2a16)')"peak","current"
    write(*,'(20x,"      before",2i16)')malloc_count_peak(),malloc_count_current()
    allocate(block(10000000))
    block=1
    write(*,'(20x,"   allocated",2i16)')malloc_count_peak(),malloc_count_current()
    deallocate(block)
    write(*,'(20x," deallocated",2i16)')malloc_count_peak(),malloc_count_current()
    allocate(block(1000))
    write(*,'(20x," reallocated",2i16)')malloc_count_peak(),malloc_count_current()
    n=1
    x=0
    base=stack_count_clear()
    write(*,'("stack before",i8)')stack_count_usage(base)
    call sumit(n,x,base)
! note: the stack_count_usage call gives max stack size, not current
    write(*,'(" stack after",i8)')stack_count_usage(base)
    write(*,'(20x,"  after call",2i16)')malloc_count_peak(),malloc_count_current()
    write(*,*)x
    
end program
recursive subroutine sumit(n,x,base)
    use tracking
    integer(i8) malloc_count_peak,malloc_count_current
    integer(i8) stack_count_usage,stack_count_clear
    integer n
    real x
    integer(i8) base
    real  :: sblock(10000)
    sblock=1
    x=sum(sblock)+x
    write(*,'("stack inside",i8,1x,i2)')stack_count_usage(base),n
    n=n+1
    if(n < 10 )then
      call sumit(n,x,base)
      base=stack_count_clear()
      write(*,'("   unwinding",i8,1x,i2)')stack_count_usage(base),n
    endif
end 
  
