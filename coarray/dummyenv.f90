module myenv
  integer,parameter :: max_name_length=15
  contains
  subroutine myhostname(nname)
    character(len=max_name_length) :: nname
    nname="dummyhost"
  end subroutine
end module

  
