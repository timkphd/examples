      module fmpi
!DEC$ NOFREEFORM
      include "mpif.h"
!DEC$ FREEFORM
      end module
!*********************************************
!  This is a simple hello world program. Each processor 
!  prints out its rank and total number of processors 
!  in the current MPI run. 
!****************************************************************
      program hello
      use fmpi
      !USE ISO_C_BINDING, ONLY:  c_char,C_NULL_CHAR,C_INT,C_double
      USE ISO_C_BINDING
      double precision the_time
      integer i_got,id_sink,strlen
      integer argc
      character(len=256)src,dest
      character(kind=c_char) :: c_src(256),c_dest(256)
         interface 
          subroutine sinkfile(the_time,i_got,id_sink,c_src,c_dest) BIND(C, NAME='sinkfile_')
          USE ISO_C_BINDING
          character(kind=c_char) :: c_src(256),c_dest(256)
          integer(kind=C_INT) :: i_got,id_sink
          real(kind=C_DOUBLE) :: the_time
        end subroutine sinkfile
    end interface

      c_src=C_NULL_CHAR
      c_dest=C_NULL_CHAR

      call MPI_INIT( ierr )
      call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      argc=COMMAND_ARGUMENT_COUNT()

      if (argc .gt. 0)then
          CALL GET_COMMAND_ARGUMENT(1,src)
      else
          write(src,"(a)")"source"
      endif
      if (argc .gt. 1)then
          CALL GET_COMMAND_ARGUMENT(2,dest)
      else
          write(src,"(a)")"dest"
      endif

      write (*,*) "Hello from ",myid," of ",numprocs,trim(src),trim(dest)
      do i=1,len_trim(src)
         c_src(i:i)=src(i:i)
      enddo
      do i=1,len_trim(dest)
         c_dest(i:i)=dest(i:i)
      enddo
!    
! this currently crashes in bcast of c_dest
      call sinkfile(the_time,i_got,id_sink,c_src,c_dest)
      write(*,'(" for proc ",i5," time= ",f10.2," for ",i10," bytes")') &
                             id_sink,     the_time,     i_got  
!
      call MPI_FINALIZE(ierr)
      stop
      end
