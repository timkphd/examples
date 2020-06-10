program info
  implicit none
  integer ierr,mypid,getpid
  character(len=128) :: name,fname
! get the process id
  mypid=getpid()
! get the node name
  ierr=hostnm(name)
! make a filename based on the two
  write(fname,'(a,"_",i8.8)')trim(name),mypid
! open and write to the file
  open(12,file=fname)
  write(12,*)"Fortran says hello from",mypid," on ",trim(name)
end program

