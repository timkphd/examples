module myenv
  integer,parameter :: max_name_length=15
  contains
  subroutine myhostname(nname)
!  USE IFPORT
!  character(len=MAX_HOSTNAM_LENGTH + 1) :: hostname
  character(len=max_name_length) :: hostname
  character(len=max_name_length) :: nname
  ISTAT = hostnm (hostname)
  if(len_trim(hostname) .ge. max_name_length)then
      write(*,*)"hostname too long"
     nname="hostname2long"
  else
      nname=trim(hostname)
  endif
  end subroutine
end module

  
