program test
   USE IFPORT
   character (len=MAX_HOSTNAM_LENGTH + 1) :: myname
   ierr=HOSTNAM(myname)
   read(*,*)x,y
   write(*,*)"on ",trim(myname),x*y
end program
