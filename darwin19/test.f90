program test
   use numz
   use ran_mod
   real(b8)x
   integer iseed
   iseed=-1234
   x=ran1(iseed)
   do i=1,10
      write(*,*)i,ran1()
   enddo
end program
