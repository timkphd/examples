      module numz
! module defines the basic real types
          integer, parameter:: b8 = selected_real_kind(14)
          integer, parameter:: b4 = selected_real_kind(3)
          integer, parameter :: in2 = selected_int_kind(1)
          integer, parameter :: in4 = selected_int_kind(6)
          integer, parameter :: in8 = selected_int_kind(12)
          
      end module
module getit
contains
function getlen(fname)
    integer getlen
    character(len=1) :: a
    character(*) :: fname
    open(unit=11,file=trim(fname),form="unformatted",status="old",access="stream")
    len=0
    do 
        read(11,end=1234)a
        len=len+1
    enddo
    1234 continue
    close(11)
    getlen=len
end function

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

program atest
    use numz
    use getit
    real(b8) x8(4)
    real(b4) x4(8)
    integer(in2) i2(16)
    integer(in4) i4(8)
    integer(in8) i8(4)
    integer wrs,k
    character (len=8)  str8
    character (len=16) str16
    character (len=1)  str1(8)  
    character (len=2) todo(10),indo
    wrs=0
    do while(wrs < 10)
        read(*,*,end=1234)indo
        if(indo .eq. "st")goto 1234
        wrs=wrs+1
        todo(wrs)=indo
    enddo
1234 continue    
    

    str8="!@#$%^&*"
    str16="abcdefghABCDEFGH"
    str1=(/"1","2","3","4","5","6","7","8"/)
    !write(*,*)str8
    !write(*,*)str16
    !write(*,*)str1

    i2=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16/)
    i4=(/10,20,30,40,50,60,70,80/)
    i8=(/100,200,300,400/)
    x8=(/10.,20.,30.,40./)
    x4=(/1.,2.,3.,4.,5.,6.,7.,8./)
    open(unit=9,file="fort.9",form="unformatted",status="replace")
    open(unit=10,file="fort.10",form="unformatted",status="replace",access="stream")

        do ifile=9,10
            do i=1,wrs
                select case(todo(i))
                    case ("i2")
                        write(ifile)i2
                    case ("i4")
                        write(ifile)i4
                    case ("i8")
                        write(ifile)i8
                    case ("r4")
                        write(ifile)x4
                    case ("r8")
                        write(ifile)x8
                    case ("c1")
                        do k=1,4
                            write(ifile)str1
                        enddo
                    case ("c8")
                        do k=1,4
                            write(ifile)str8
                        enddo
                    case ("cx")
                        do k=1,2
                            write(ifile)str16
                        enddo
                end select
            enddo
            close(ifile)
        enddo
        open(unit=9,file="fort.9",form="unformatted",status="old")
        open(unit=10,file="fort.10",form="unformatted",status="old",access="stream")
    do ifile=9,10
        do i=1,wrs
            select case(todo(i))
                case ("i2")
                    read(ifile)i2 ; write(*,*)i2
                case ("i4")
                    read(ifile)i4 ; write(*,*)i4
                case ("i8")
                    read(ifile)i8 ; write(*,*)i8
                case ("r4")
                    read(ifile)x4 ; write(*,*)x4
                case ("r8")
                    read(ifile)x8 ; write(*,*)x8
                case ("c1")
                    do k=1,4
                        read(ifile)str1
                    enddo
                    write(*,*)str1
                case ("c8")
                    do k=1,4
                        read(ifile)str8
                    enddo
                    write(*,*)str8
                case ("cx")
                    do k=1,2
                        read(ifile)str16
                    enddo
                    write(*,*)str16
            end select
        enddo
        close(ifile)
    enddo
    write(*,*)
    write(*,*)"length fort.10 =",getlen_c("fort.10")
    write(*,*)"length fort.9 =",getlen_c("fort.9")
end program
       
    
    

