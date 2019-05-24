module numz
! module defines the basic real type
          integer, parameter:: b8 = selected_real_kind(14)
end module
module Fortran_Sleep
   use, intrinsic :: iso_c_binding, only: c_int
   implicit none
   interface
      !  should be unsigned int ... not available in Fortran
      !  OK until highest bit gets set.
      function FortSleep (seconds)  bind ( C, name="sleep" )
          import
          integer (c_int) :: FortSleep
          integer (c_int), intent (in), VALUE :: seconds
      end function FortSleep
   end interface
   contains
        subroutine rsleep(x) 
        use numz
        real(b8) x
        integer co,cr,cm,cf,over
        call system_clock(co,cr,cm)
        over=0
        cf=co+int(real(cr,b8)*x)
        if(cf .gt. cm) over=cm
 waist: do
          call system_clock(co)
          co=co+over
          if ( co .ge. cf) exit
        enddo waist
        end subroutine rsleep
end module Fortran_Sleep
program parallel
    use numz
    use Fortran_Sleep
    implicit none
    integer :: my_id,i
    real(b8) :: myval,total,message
    logical notready,ready
    character(len=80) :: argv,fname
    fname="message"
    call get_command_argument(1,argv)
    read(argv,*)my_id
    write(*,*)my_id," starting program"
    if (my_id == 1)then
!      call rsleep(2.0_b8)
      i=fortsleep(2)
      myval=cos(10.0_b8)
      open(unit=12,file=fname,status="new")
      write(12,*)myval
      close(12)
    endif
    if (my_id == 0)then
       myval=sin(10.0_b8)
       notready=.true.
 wait: do while (notready)
         inquire(file=fname,exist=ready)
         if(ready)then
           notready=.false.
!          call sleep(3.0_b8)
           i=fortsleep(3)
           open(unit=12,file=fname,status="old")
           read(12,*)message
           close(12)
           total=myval**2+message**2
         else
!           call sleep(5.0_b8)
           i=fortsleep(5)
         endif
       end do wait
       write(*,*)"sin(10)**2+cos(10)**2=",total
    endif
    write(*,*)"done with program"
end program parallel
