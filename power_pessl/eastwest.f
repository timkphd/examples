!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1996. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
      module eastwest
!
        use pdata
        implicit none
!
!     everything private by default
!
      private 
      public :: dsendeast,drcvwest,dsendwest,drcveast
      public :: ssendeast,srcvwest,ssendwest,srcveast
      public :: csendeast,crcvwest,csendwest,crcveast
      public :: zsendeast,zrcvwest,zsendwest,zrcveast


!
! private data to be used with the intenal routines
!

      integer :: number_of_rows, block
      integer :: east_proc, west_proc, number_of_blocks
      integer :: last_block, start_block,end_block
      integer :: pcol_owning_last_block
      
!  source code for the generic routines:
!     sendeastborder, sendwestborder, rcveastborder, rcvwestborder
!
!  This module contains routines to send and receive the right and left
!  most columns of each local block to the processor logically directly right
!  or left the current process. The routines are broken into sends and
!  receives. For example if we have the global matrix on a 2x2 processor
!  grid given below
!
!               GLOBAL matrix
!  |------------------------------------------------------------|
!  |       [A1]       |   [A2]      |   [A3]      |   [A4]      |
!  |     block 0,0    | block 0,1   | block 0,2   | block 0,3   |
!  |      on 0, 0     |  on 0,1     |  on 0,0     |  on 0,1     |
!  |------------------|-------------|-------------|-------------|
!  |       [B1]       |   [B2]      |   [B3]      |   [B4]      |
!  |     block 1,0    | block 1,1   | block 1,2   | block 1,3   |
!  |      on 1,0      |  on 1,1     |  on 1,0     |  on 1,1     |
!  |------------------|-------------|-------------|-------------|
!  |       [C1]       |   [C2]      |   [C3]      |   [C4]      |
!  |     block 2, 0   | block 2,1   | block 2,2   | block 2,3   |
!  |     on 0, 0      |  on 0,1     |  on 0,0     |  on 0,1     |
!  |------------------|-------------|-------------|-------------|
!  |       [D1]       |   [D2]      |   [D3]      |   [D4]      |
!  |     block 3, 0   | block 3,1   |  block 3,2  |  block 3,3  |
!  |     on 1, 0      |  on 1,1     |  on 1,0     |  on 1,1     |
!  |------------------|-------------|-------------|-------------|
!  |       [E1]       |   [E2]      |   [E3]      |   [E4]      |
!  |     block 4, 0   | block 4,1   | block 4,2   | block 4,3   |
!  |     on 0, 0      |  on 0,1     |  on 0,0     |  on 0,1     |
!  |                  |             |             |             |
!  |------------------------------------------------------------|
!
!   sendeast executed on processor (0,0) will create a
!   send array containing two columns as follows:
!     row 1: the last columns of blocks A1, C1 and E1
!     row 2: the last columns of blocks A3, C3 and E3
!   this matrix will be then sent to  processor (0,1)
!
!   sendeast executed on processor (1,1) will create a
!   send array containing two columns as follows:
!     row 1: a column of zeros
!     row 2: the last columns of blocks B2 and D2
!
!
!   Each processor will receive a matrix matrix containing as
!   many rows as the local matrix has blocks, with the last row
!   being a row of zeros if the bottom most block contains the
!   last row of the distributed matrix.
!
!    Input arguments are as follows for send routines
!    subroutine sendeastborder(a,desca,send_buffer)
!    subroutine sendwestborder(a,desca,send_buffer)
!
!      a:     real or complex input array containing distributed matrix
!
!      desca: integer array descriptor corresponding to a
!
!      send_buffer: real or complex matrix of the same type as a
!                   must have at least as many columns as a and have at
!                   at least as many rows as the number of row block that
!                   the matrix a contains on the receiving processor
!                   This contains the sending buffer for the top rows
!
!
!    Input arguments are as follows for receive routines
!    subroutine rcveastborder(a,desca,rcv_buffer)
!    subroutine rcvwestborder(a,desca,rcv_buffer)
!
!      a:     real or complex input array containing distributed matrix
!
!      desca: integer array descriptor corresponding to a
!
!      rcv_buffer:  real or complex matrix of the same type as a
!                   must have at least as many columns as a and have at
!                   at least as many rows as the number of row block that
!                   the matrix a contains on the current processor. This
!                   will contain the border rows for each block on return
!

!       Subroutines called:
!           dgesd2d    from the blacs library
!           sgesd2d    from the blacs library
!           zgesd2d    from the blacs library
!           cgesd2d    from the blacs library
!           dgerv2d    from the blacs library
!           sgerv2d    from the blacs library
!           zgerv2d    from the blacs library
!           cgerv2d    from the blacs library




      contains


      subroutine dsendwest(a,desca,send_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with 
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

!
! check for quick return, no transfer if only a single processor column
!
      
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols - 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!
      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+west_proc,npcols))/npcols



!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!
      do block = 1, last_block
      if( westmost(mycol,desca) ) then  
        if( .not. east_most_block(block,mycol,desca)) then
          if( .not. east_most_block(block,west_proc,desca)) then
            send_buffer(1:size(a,1),block)=a(:,block*desca(NB_)+1)
          else
            send_buffer(1:size(a,1),block)=0
          endif
        endif
      else 
        if( .not. east_most_block(block,west_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_)+1)
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call dgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,west_proc)


      return
      end subroutine dsendwest


      subroutine drcveast(a,desca,rcv_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)

!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from east processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(N_)+desca(NB_) -1)/desca(NB_)) then
          rcv_buffer(1:size(a,1),block) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,block*desca(NB_)+1)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod(1 + mycol, npcols)


!
!  receive the eastern border column from the east processor
!

      call dgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,east_proc)


      return
      end subroutine drcveast



      subroutine dsendeast(a,desca,send_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

      

!
!  check for quick return
!
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod( 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+east_proc,npcols))/npcols


!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!

      do block = 1, last_block
      if( eastmost(mycol,desca) ) then  
        if( .not. west_most_block(block,east_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      else 
        if( .not. east_most_block(block,mycol,desca)) then
          send_buffer(1:size(a,1),block)=a(:,block*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call dgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,east_proc)


      return
      end subroutine dsendeast


      subroutine drcvwest(a,desca,rcv_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from west processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(1:size(a,1),1) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,(block-1)*desca(NB_))
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols -1 + mycol, npcols)


!
!  get the western border column from the western processors
!

      call dgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,west_proc)


      return
      end subroutine drcvwest


      subroutine ssendwest(a,desca,send_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with 
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

!
! check for quick return, no transfer if only a single processor column
!
      
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols - 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!
      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+west_proc,npcols))/npcols



!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!
      do block = 1, last_block
      if( westmost(mycol,desca) ) then  
        if( .not. east_most_block(block,mycol,desca)) then
          if( .not. east_most_block(block,west_proc,desca)) then
            send_buffer(1:size(a,1),block)=a(:,block*desca(NB_)+1)
          else
            send_buffer(1:size(a,1),block)=0
          endif
        endif
      else 
        if( .not. east_most_block(block,west_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_)+1)
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call sgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,west_proc)


      return
      end subroutine ssendwest


      subroutine srcveast(a,desca,rcv_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)

!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from east processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(N_)+desca(NB_) -1)/desca(NB_)) then
          rcv_buffer(1:size(a,1),block) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,block*desca(NB_)+1)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod(1 + mycol, npcols)


!
!  receive the eastern border column from the east processor
!

      call sgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,east_proc)


      return
      end subroutine srcveast



      subroutine ssendeast(a,desca,send_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

      

!
!  check for quick return
!
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod( 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+east_proc,npcols))/npcols


!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!

      do block = 1, last_block
      if( eastmost(mycol,desca) ) then  
        if( .not. west_most_block(block,east_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      else 
        if( .not. east_most_block(block,mycol,desca)) then
          send_buffer(1:size(a,1),block)=a(:,block*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call sgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,east_proc)


      return
      end subroutine ssendeast


      subroutine srcvwest(a,desca,rcv_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from west processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(1:size(a,1),1) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,(block-1)*desca(NB_))
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols -1 + mycol, npcols)


!
!  get the western border column from the western processors
!

      call sgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,west_proc)


      return
      end subroutine srcvwest

      subroutine csendwest(a,desca,send_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with 
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

!
! check for quick return, no transfer if only a single processor column
!
      
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols - 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!
      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+west_proc,npcols))/npcols



!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!
      do block = 1, last_block
      if( westmost(mycol,desca) ) then  
        if( .not. east_most_block(block,mycol,desca)) then
          if( .not. east_most_block(block,west_proc,desca)) then
            send_buffer(1:size(a,1),block)=a(:,block*desca(NB_)+1)
          else
            send_buffer(1:size(a,1),block)=0
          endif
        endif
      else 
        if( .not. east_most_block(block,west_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_)+1)
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call cgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,west_proc)


      return
      end subroutine csendwest


      subroutine crcveast(a,desca,rcv_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)

!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from east processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(N_)+desca(NB_) -1)/desca(NB_)) then
          rcv_buffer(1:size(a,1),block) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,block*desca(NB_)+1)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod(1 + mycol, npcols)


!
!  receive the eastern border column from the east processor
!

      call cgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,east_proc)


      return
      end subroutine crcveast



      subroutine csendeast(a,desca,send_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

      

!
!  check for quick return
!
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod( 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+east_proc,npcols))/npcols


!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!

      do block = 1, last_block
      if( eastmost(mycol,desca) ) then  
        if( .not. west_most_block(block,east_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      else 
        if( .not. east_most_block(block,mycol,desca)) then
          send_buffer(1:size(a,1),block)=a(:,block*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call cgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,east_proc)


      return
      end subroutine csendeast


      subroutine crcvwest(a,desca,rcv_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from west processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(1:size(a,1),1) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,(block-1)*desca(NB_))
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols -1 + mycol, npcols)


!
!  get the western border column from the western processors
!

      call cgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,west_proc)


      return
      end subroutine crcvwest
      subroutine zsendwest(a,desca,send_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with 
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

!
! check for quick return, no transfer if only a single processor column
!
      
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols - 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!
      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+west_proc,npcols))/npcols



!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!
      do block = 1, last_block
      if( westmost(mycol,desca) ) then  
        if( .not. east_most_block(block,mycol,desca)) then
          if( .not. east_most_block(block,west_proc,desca)) then
            send_buffer(1:size(a,1),block)=a(:,block*desca(NB_)+1)
          else
            send_buffer(1:size(a,1),block)=0
          endif
        endif
      else 
        if( .not. east_most_block(block,west_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_)+1)
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call zgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,west_proc)


      return
      end subroutine zsendwest


      subroutine zrcveast(a,desca,rcv_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)

!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from east processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(N_)+desca(NB_) -1)/desca(NB_)) then
          rcv_buffer(1:size(a,1),block) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,block*desca(NB_)+1)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod(1 + mycol, npcols)


!
!  receive the eastern border column from the east processor
!

      call zgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,east_proc)


      return
      end subroutine zrcveast



      subroutine zsendeast(a,desca,send_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       send_buffer: array containing a send buffer, with
!                    at least as many rows a the array a and
!                    a many columns as the number of local blocks
!                    of a on receiving processes
!

      

!
!  check for quick return
!
      if (npcols .eq. 1)  return 

!
!  determine where my rows is and which row is east of me
!
      east_proc = mod( 1 + mycol, npcols)

!
!  determine the number of blocks on the west processor and 
!  the the process owning the last block of the matrix a
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      pcol_owning_last_block =                                             &
     &      mod(number_of_blocks-1+npcols-desca(CSRC_),npcols)

      
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+east_proc,npcols))/npcols


!
!  check to see if send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in sendbuffer'
        write(*,*) 'sb',size(send_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  loop over all blocks copying the appropriate column to send buffer
!

      do block = 1, last_block
      if( eastmost(mycol,desca) ) then  
        if( .not. west_most_block(block,east_proc,desca)) then
          send_buffer(1:size(a,1),block)=a(:,(block-1)*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      else 
        if( .not. east_most_block(block,mycol,desca)) then
          send_buffer(1:size(a,1),block)=a(:,block*desca(NB_))
        else
          send_buffer(1:size(a,1),block)=0
        endif
      endif
      enddo

!
!  send the buffer to the east processor
!
      call zgesd2d(icontext,size(a,1),last_block,                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               myrow,east_proc)


      return
      end subroutine zsendeast


      subroutine zrcvwest(a,desca,rcv_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!  arguments
!       a: array contain the border columns to be sent
!       desca: array descriptor associated with a
!       rcv_buffer:  array containing the buffer with
!                    columns from west processor, returned to
!                    user.
!

!
!  calculate the number of local blocks and make sure 
!  receive buffer is big enough to hold the data
!

      number_of_blocks = (desca(N_)+desca(NB_) -1)/desca(NB_)
      last_block = (number_of_blocks + npcols -1 -                         &
     &      mod(npcols-desca(CSRC_)+mycol,npcols))/npcols


      if( size(rcv_buffer,1) .lt. size(a,1)) then
        write(*,*) ' not enough rows in rcv_buffer'
        write(*,*) size(rcv_buffer,1), size(a,1)
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. last_block) then
        write(*,*) ' not enough columns in rcv_buffer'
        write(*,*) 'rv',size(rcv_buffer,2), last_block
        call blacs_abort(icontext,1)
      endif

!
!  if we only have a single column of processor, copy the data
!
      if (npcols .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(1:size(a,1),1) = 0
        else
          rcv_buffer(1:size(a,1),block) = a(:,(block-1)*desca(NB_))
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is west of me
!
      west_proc = mod(npcols -1 + mycol, npcols)


!
!  get the western border column from the western processors
!

      call zgerv2d(icontext,size(a,1),last_block,                            &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               myrow,west_proc)


      return
      end subroutine zrcvwest

C========================

        logical function west_most_block(block,proc,desc)
          implicit none
          integer, intent(in) :: block, proc
          integer, intent(in) :: desc(:)
          west_most_block = .false.
          if ( block .eq.1 .and. proc .eq. desc(CSRC_))                      &
     &         west_most_block = .true.
          return
        end function west_most_block

        logical function east_most_block(block,proc,desc)
          implicit none
          integer, intent(in) :: block, proc
         integer, intent(in) :: desc(:)
          east_most_block = .false.
          if (block .eq.(number_of_blocks+npcols-1)/npcols                    &
     &      .and. proc .eq. pcol_owning_last_block)                           &
     &          east_most_block = .true.
        return
        end function east_most_block

        logical function westmost(proc,desc)
          implicit none
          integer, intent(in) :: proc
          integer, intent(in) :: desc(:)
          westmost = .false.
          if( desc(CSRC_) .eq. proc) westmost = .true.
          return
        end function westmost

        logical function eastmost(proc,desc)
         implicit none
         integer, intent(in) :: proc
         integer, intent(in) :: desc(:)
         eastmost = .false.
         if(mod(desc(CSRC_)-1+npcols,npcols).eq.proc)eastmost=.true.
         return
        end function eastmost
      end module eastwest

