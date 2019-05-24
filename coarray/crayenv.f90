module myenv
  integer,parameter :: max_name_length=15
  contains
    subroutine myhostname(nname)
    integer junam, ierror, ilen
    character(len=max_name_length) :: nname
    call pxfstructcreate('utsname',junam,ierror)
    call pxfuname(junam,ierror)
    ilen=0
    call pxfstrget(junam,'nodename',nname,ilen,ierror)
    call pxfstructfree(junam,ierror)
  end subroutine
end module

