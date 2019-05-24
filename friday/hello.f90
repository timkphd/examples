program hybrid 
    implicit none 
    include 'mpif.h' 
    integer numnodes,myid,my_root,ierr 
    double precision mytime,getsec
    character (len=MPI_MAX_PROCESSOR_NAME):: myname 
    integer mylen 
    call MPI_INIT( ierr ) 
    call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr ) 
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, ierr ) 
    call MPI_Get_processor_name(myname,mylen,ierr) 
    mytime=getsec()
    write(unit=*,fmt="(i4,a,a,a,f10.3)")myid," running on ",trim(myname) ," at ",mytime
    call mysleep()
    mytime=getsec()
    write(unit=*,fmt="(i4,a,a,a,f10.3)")myid," stoping on ",trim(myname) ," at ",mytime
    call MPI_FINALIZE(ierr) 
end program 

subroutine mysleep()
    include 'mpif.h'
    double precision t1,t2
    t1=MPI_Wtime(ierr)+10.0d0
    do
      t2=MPI_Wtime(ierr)
      if(t2 .gt. t1)return
    enddo
end subroutine
function getsec()
    double precision getsec
    integer values(8)
    call DATE_AND_TIME(values=values)
    getsec=values(5)*3600.0d0+values(6)*60.0d0+values(7)*1.0d0+values(8)*0.001d0
end function
