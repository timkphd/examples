!***********************************************************
!  This is a simple hello world program but each processor 
!  writes out its rank and total number of processors 
!  in the current MPI run to a file in /state/partition1
!***********************************************************
      program hello
      use ifport  ! ## needed for GETENV called below ##
      include "mpif.h"
      character (len=MPI_MAX_PROCESSOR_NAME):: nodename
      character (len=20) :: myname
      character (len=40) :: basedir,fname
      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
! get the name of the node on which i am running
      call MPI_Get_processor_name(nodename,nlen,ierr)
! get my username
      CALL GETENV ("LOGNAME",myname)
!  for every mpi task...
!  create a unique file name based on a base directory 
!  name, a username, "f_", and the mpi process id
      basedir="/state/partition1/"
      write(fname,'(a,a,"/f_",i5.5)'),trim(basedir),trim(myname),myid
! echo the full path to the file for each mpi task
      write(*,*)"opening file ",trim(fname)
! open the file
      open(10,file=fname)
! write the mpi process id to the file along with the node name
      write(10,'("Hello from",i4," on ",a)')myid,trim(nodename)
      close(10)
      call MPI_FINALIZE(ierr)
      stop
      end