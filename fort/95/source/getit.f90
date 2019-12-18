module getit
contains
function getlen_c(fname)
    USE ISO_C_BINDING, ONLY: c_long, c_char,C_NULL_CHAR
    use numz
    integer(in8) :: getlen_c
    interface 
        integer(c_long) function filesize(aname) BIND(C, NAME='c_filesize')
          USE ISO_C_BINDING, ONLY: c_long, c_char
          character(kind=c_char) :: aname(*)
        end function fileSize
    end interface
    character(*) :: fname
    character(128) :: tmp
    character(kind=c_char) :: string(128)
    integer strlen
    ! fill the string with nulls (strings for c must be null terminated)
    string=C_NULL_CHAR
    ! copy our input string to a c_char string
    tmp=trim(ADJUSTL(fname))
    strlen=len_trim(tmp)
    do i=1,strlen
        string(i:i)=tmp(i:i)
    enddo
    getlen_c=fileSize(string)
end function
end module
