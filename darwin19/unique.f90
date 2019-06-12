function unique(name,i)
    use numz
    use mympi
    character (len=*) name
    integer , optional, intent(in) :: i
    integer myid, mpi_err
    integer the_len
!    character (len=3) id
    character (len=20) unique
    character (len=80) temp
    if(.not.present(i))then
        call MPI_COMM_RANK( TIMS_COMM_WORLD, myid, mpi_err )
    else
        myid=i
    endif
    if(myid .gt. 99)then
!      write(id,"(i3)")myid
      write(temp,"(a,i3)")trim(name),myid
    else
        if(myid .gt. 9)then
!            write(id,"('0',i2)")myid
            write(temp,"(a,'0',i2)")trim(name),myid
        else
!            write(id,"('00',i1)")myid
            write(temp,"(a,'00',i1)")trim(name),myid
        endif
    endif
!    unique=trim(name//id)
    the_len=len_trim(temp)
    if(the_len .gt. 20)the_len=20
    unique=temp(1:the_len)
    return
end function unique
