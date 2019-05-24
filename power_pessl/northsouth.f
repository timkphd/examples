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
      module northsouth
!
!
!
        use pdata
        implicit none
!
!     everything private by default
!
      private 
      public :: dsendnorth,drcvsouth,dsendsouth,drcvnorth
      public :: csendnorth,crcvsouth,csendsouth,crcvnorth
      public :: ssendnorth,srcvsouth,ssendsouth,srcvnorth
      public :: zsendnorth,zrcvsouth,zsendsouth,zrcvnorth

!
! private data to be used with the intenal routines
!
      integer :: number_of_rows, block
      integer :: north_proc, south_proc, number_of_blocks
      integer :: prow_owning_last_block, last_block, start_block,end_block

!  source code for the generic routines:
!     sendnorthborder, sendsouthborder, rcvnorthborder, rcvsouthborder
!
!
!  This module contains routines to send and receive the upper and lower
!  most rows of each local block to the processor logically directly above 
!  or below the current process. The routines are broken into sends and
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
!   sendnorth executed on processor (0,0) will create a
!   send array containing two rows as follows:
!     row 1: the top rows of blocks C1 and C3
!     row 2: the top rows of blocks E1 and E3
!   this matrix will be then sent to  processor (1,0)
!
!   sendnorth executed on processor (1,1) will create a
!   send array containing three rows as follows:
!     row 1: the top rows of blocks B2 and B4
!     row 2: the top rows of blocks D2 and D4
!     row 3: a row of zeros 
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
!    subroutine rcveastborder(a,desca,send_buffer)
!    subroutine rcvwestborder(a,desca,send_buffer)
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


      subroutine dsendnorth(a,desca,send_buffer)
      real(long_t), intent(in)     :: a(:,:)
      real(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)     :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!
      
!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return 

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows - 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      
!
!  calculate the row processor containing last global block
!
      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of blocks on local portion of the 
!  distibuted matrix on the processor above the current processor
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+north_proc,nprows))/nprows


!
! check to make sure the send buffer size is large enough
!
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
!  for each row block on the processor above us, copy
!  the top row into the send buffer. If the, block is
!  the bottom block of the global matrix, copy zeros
!
      do block = 1, last_block
      if( northmost(myrow,desca) ) then  
        if( .not. south_most_block(block,myrow,desca)) then
          if( .not. south_most_block(block,north_proc,desca)) then
            send_buffer(block,1:size(a,2))=a(block*desca(MB_)+1,:)
          else
            send_buffer(block,1:size(a,2))=0
          endif
        endif
      else 
        if( .not. south_most_block(block,north_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_)+1,:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! send the send buffer to the processor above the current processor
!
      call dgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               north_proc,mycol)


!
! return
!
      return
      end subroutine dsendnorth


      subroutine drcvsouth(a,desca,rcv_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing top rows of south processor
!


!
!  calculate the total number of blocks in on current processor
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)

      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows

!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(M_)+desca(MB_) -1)/desca(MB_)) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a(block*desca(MB_)+1,:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is south of me
!
      south_proc = mod(1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!

      call dgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               south_proc,mycol)


      return
      end subroutine drcvsouth


      subroutine dsendsouth(a,desca,send_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!

!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return



!
!  determine where my rows is and which row is south of me
!
      south_proc = mod( 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
!
!  calculate the row processor containing last global block
!

      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of block on the processor north of us
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+south_proc,nprows))/nprows


!
! check to make sure the send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), last_block
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
! loop over all of the block on the south processor and
! put the bottom row into the send buffer. If the south
! processor contains the top row, put zero in its place
!
      do block = 1, last_block
      if( southmost(myrow,desca) ) then  
        if( .not. north_most_block(block,south_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      else 
        if( .not. south_most_block(block,myrow,desca)) then
          send_buffer(block,1:size(a,2))=a(block*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! finally send to the south processor
!

      call dgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               south_proc,mycol)


      return
      end subroutine dsendsouth


      subroutine drcvnorth(a,desca,rcv_buffer)
      
      real(long_t), intent(in)  :: a(:,:)
      real(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing bottom rows of north processor
!




!
! calculate the number of local blocks of a on the current processor
!

      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows


!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!

      
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       write(*,*) 'last_block is', last_block
       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a((block-1)*desca(MB_),:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows -1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!



      call dgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               north_proc,mycol)


      return
      end subroutine drcvnorth


      subroutine ssendnorth(a,desca,send_buffer)
      real(short_t), intent(in)     :: a(:,:)
      real(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)     :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!
      
!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return 

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows - 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      
!
!  calculate the row processor containing last global block
!
      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of blocks on local portion of the 
!  distibuted matrix on the processor above the current processor
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+north_proc,nprows))/nprows


!
! check to make sure the send buffer size is large enough
!
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
!  for each row block on the processor above us, copy
!  the top row into the send buffer. If the, block is
!  the bottom block of the global matrix, copy zeros
!
      do block = 1, last_block
      if( northmost(myrow,desca) ) then  
        if( .not. south_most_block(block,myrow,desca)) then
          if( .not. south_most_block(block,north_proc,desca)) then
            send_buffer(block,1:size(a,2))=a(block*desca(MB_)+1,:)
          else
            send_buffer(block,1:size(a,2))=0
          endif
        endif
      else 
        if( .not. south_most_block(block,north_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_)+1,:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! send the send buffer to the processor above the current processor
!
      call sgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               north_proc,mycol)


!
! return
!
      return
      end subroutine ssendnorth


      subroutine srcvsouth(a,desca,rcv_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing top rows of south processor
!


!
!  calculate the total number of blocks in on current processor
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)

      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows

!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(M_)+desca(MB_) -1)/desca(MB_)) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a(block*desca(MB_)+1,:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is south of me
!
      south_proc = mod(1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!

      call sgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               south_proc,mycol)


      return
      end subroutine srcvsouth


      subroutine ssendsouth(a,desca,send_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!

!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return



!
!  determine where my rows is and which row is south of me
!
      south_proc = mod( 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
!
!  calculate the row processor containing last global block
!

      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of block on the processor north of us
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+south_proc,nprows))/nprows


!
! check to make sure the send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), last_block
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
! loop over all of the block on the south processor and
! put the bottom row into the send buffer. If the south
! processor contains the top row, put zero in its place
!
      do block = 1, last_block
      if( southmost(myrow,desca) ) then  
        if( .not. north_most_block(block,south_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      else 
        if( .not. south_most_block(block,myrow,desca)) then
          send_buffer(block,1:size(a,2))=a(block*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! finally send to the south processor
!

      call sgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               south_proc,mycol)


      return
      end subroutine ssendsouth


      subroutine srcvnorth(a,desca,rcv_buffer)
      
      real(short_t), intent(in)  :: a(:,:)
      real(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing bottom rows of north processor
!




!
! calculate the number of local blocks of a on the current processor
!

      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows


!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!

      
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       write(*,*) 'last_block is', last_block
       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a((block-1)*desca(MB_),:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows -1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!



      call sgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               north_proc,mycol)


      return
      end subroutine srcvnorth



      subroutine csendnorth(a,desca,send_buffer)
      complex(short_t), intent(in)     :: a(:,:)
      complex(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)     :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!
      
!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return 

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows - 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      
!
!  calculate the row processor containing last global block
!
      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of blocks on local portion of the 
!  distibuted matrix on the processor above the current processor
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+north_proc,nprows))/nprows


!
! check to make sure the send buffer size is large enough
!
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
!  for each row block on the processor above us, copy
!  the top row into the send buffer. If the, block is
!  the bottom block of the global matrix, copy zeros
!
      do block = 1, last_block
      if( northmost(myrow,desca) ) then  
        if( .not. south_most_block(block,myrow,desca)) then
          if( .not. south_most_block(block,north_proc,desca)) then
            send_buffer(block,1:size(a,2))=a(block*desca(MB_)+1,:)
          else
            send_buffer(block,1:size(a,2))=0
          endif
        endif
      else 
        if( .not. south_most_block(block,north_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_)+1,:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! send the send buffer to the processor above the current processor
!
      call cgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               north_proc,mycol)


!
! return
!
      return
      end subroutine csendnorth


      subroutine crcvsouth(a,desca,rcv_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing top rows of south processor
!


!
!  calculate the total number of blocks in on current processor
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)

      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows

!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(M_)+desca(MB_) -1)/desca(MB_)) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a(block*desca(MB_)+1,:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is south of me
!
      south_proc = mod(1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!

      call cgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               south_proc,mycol)


      return
      end subroutine crcvsouth


      subroutine csendsouth(a,desca,send_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!

!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return



!
!  determine where my rows is and which row is south of me
!
      south_proc = mod( 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
!
!  calculate the row processor containing last global block
!

      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of block on the processor north of us
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+south_proc,nprows))/nprows


!
! check to make sure the send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), last_block
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
! loop over all of the block on the south processor and
! put the bottom row into the send buffer. If the south
! processor contains the top row, put zero in its place
!
      do block = 1, last_block
      if( southmost(myrow,desca) ) then  
        if( .not. north_most_block(block,south_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      else 
        if( .not. south_most_block(block,myrow,desca)) then
          send_buffer(block,1:size(a,2))=a(block*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! finally send to the south processor
!

      call cgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               south_proc,mycol)


      return
      end subroutine csendsouth


      subroutine crcvnorth(a,desca,rcv_buffer)
      
      complex(short_t), intent(in)  :: a(:,:)
      complex(short_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing bottom rows of north processor
!




!
! calculate the number of local blocks of a on the current processor
!

      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows


!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!

      
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       write(*,*) 'last_block is', last_block
       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a((block-1)*desca(MB_),:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows -1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!



      call cgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               north_proc,mycol)


      return
      end subroutine crcvnorth


      subroutine zsendnorth(a,desca,send_buffer)
      complex(long_t), intent(in)     :: a(:,:)
      complex(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)     :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!
      
!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return 

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows - 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      
!
!  calculate the row processor containing last global block
!
      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of blocks on local portion of the 
!  distibuted matrix on the processor above the current processor
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+north_proc,nprows))/nprows


!
! check to make sure the send buffer size is large enough
!
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
!  for each row block on the processor above us, copy
!  the top row into the send buffer. If the, block is
!  the bottom block of the global matrix, copy zeros
!
      do block = 1, last_block
      if( northmost(myrow,desca) ) then  
        if( .not. south_most_block(block,myrow,desca)) then
          if( .not. south_most_block(block,north_proc,desca)) then
            send_buffer(block,1:size(a,2))=a(block*desca(MB_)+1,:)
          else
            send_buffer(block,1:size(a,2))=0
          endif
        endif
      else 
        if( .not. south_most_block(block,north_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_)+1,:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! send the send buffer to the processor above the current processor
!
      call zgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               north_proc,mycol)


!
! return
!
      return
      end subroutine zsendnorth


      subroutine zrcvsouth(a,desca,rcv_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing top rows of south processor
!


!
!  calculate the total number of blocks in on current processor
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)

      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows

!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       do block = 1, last_block
        if( block .eq. (desca(M_)+desca(MB_) -1)/desca(MB_)) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a(block*desca(MB_)+1,:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is south of me
!
      south_proc = mod(1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!

      call zgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               south_proc,mycol)


      return
      end subroutine zrcvsouth


      subroutine zsendsouth(a,desca,send_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(inout)  :: send_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      send_buffer :: matrix used to hold top rows of blocks within a
!

!
! check if we only have one row, if so, all the data is
! already on the current processor and we can do a quick return
!
      if (nprows .eq. 1)  return



!
!  determine where my rows is and which row is south of me
!
      south_proc = mod( 1 + myrow, nprows)

!
!  calculate the total number of row blocks in the global matrix
!
      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
!
!  calculate the row processor containing last global block
!

      prow_owning_last_block =                                             &
     &      mod(number_of_blocks-1+desca(RSRC_),nprows)

!
!  calculate the number of block on the processor north of us
!
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+south_proc,nprows))/nprows


!
! check to make sure the send buffer is big enough
!
 
      if( size(send_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in send_buffer'
        write(*,*) size(send_buffer,1), last_block
        call blacs_abort(icontext,1)
      endif

      if( size(send_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in sendbuffer'
        call blacs_abort(icontext,1)
      endif

!
! loop over all of the block on the south processor and
! put the bottom row into the send buffer. If the south
! processor contains the top row, put zero in its place
!
      do block = 1, last_block
      if( southmost(myrow,desca) ) then  
        if( .not. north_most_block(block,south_proc,desca)) then
          send_buffer(block,1:size(a,2))=a((block-1)*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      else 
        if( .not. south_most_block(block,myrow,desca)) then
          send_buffer(block,1:size(a,2))=a(block*desca(MB_),:)
        else
          send_buffer(block,1:size(a,2))=0
        endif
      endif
      enddo

!
! finally send to the south processor
!

      call zgesd2d(icontext,last_block,size(a,2),                            &
     &             send_buffer,size(send_buffer,1),                          &
     &               south_proc,mycol)


      return
      end subroutine zsendsouth


      subroutine zrcvnorth(a,desca,rcv_buffer)
      
      complex(long_t), intent(in)  :: a(:,:)
      complex(long_t), intent(out) :: rcv_buffer(:,:)
      integer,      intent(in)  :: desca(:)
!
!    arguments :
!      a           :: local portion of distributed array
!      desca       :: array descriptor corresponding to a
!      rcv_buffer  :: return matrix containing bottom rows of north processor
!




!
! calculate the number of local blocks of a on the current processor
!

      number_of_blocks = (desca(M_)+desca(MB_) -1)/desca(MB_)
      last_block = (number_of_blocks + nprows -1 -                         &
     &      mod(nprows-desca(RSRC_)+myrow,nprows))/nprows


!
!  make sure that the receive buffer is big enough
!

      if( size(rcv_buffer,1) .lt. last_block) then
        write(*,*) ' not enough rows in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

      if( size(rcv_buffer,2) .lt. size(a,2)) then
        write(*,*) ' not enough columns in rcv_buffer'
        call blacs_abort(icontext,1)
      endif

!
!  if the number of processor rows is 1, we only need to copy
!

      
      if (nprows .eq. 1)   then  ! copy from other portions of the array

       write(*,*) 'last_block is', last_block
       do block = 1, last_block
        if( block .eq. 1) then
          rcv_buffer(block,1:size(a,2)) = 0
        else
          rcv_buffer(block,1:size(a,2)) = a((block-1)*desca(MB_),:)
        endif
       enddo

      return
      endif

!
!  determine where my rows is and which row is north of me
!
      north_proc = mod(nprows -1 + myrow, nprows)


!
!  if there is more than one processor row, receive the border rows
!  from the processor to the south of us.
!



      call zgerv2d(icontext,last_block,size(a,2),                           &
     &             rcv_buffer,size(rcv_buffer,1),                            &
     &               north_proc,mycol)


      return
      end subroutine zrcvnorth

        logical function north_most_block(block,proc,desc)
          implicit none
          integer, intent(in) :: block, proc
          integer, intent(in) :: desc(:)
          north_most_block = .false.
          if ( block .eq.1 .and. proc .eq. desc(RSRC_))                      &
     &         north_most_block = .true.
          return
        end function north_most_block

        logical function south_most_block(block,proc,desc)
          implicit none
          integer, intent(in) :: block, proc
         integer, intent(in) :: desc(:)
          south_most_block = .false.
          if (block .eq.(number_of_blocks+nprows-1)/nprows                    &
     &      .and. proc .eq. prow_owning_last_block)                           &
     &          south_most_block = .true.
        return
        end function south_most_block

        logical function northmost(proc,desc)
          implicit none
          integer, intent(in) :: proc
          integer, intent(in) :: desc(:)
          northmost = .false.
          if( desc(RSRC_) .eq. proc) northmost = .true.
          return
        end function northmost

        logical function southmost(proc,desc)
         implicit none
         integer, intent(in) :: proc
         integer, intent(in) :: desc(:)
         southmost = .false.
         if(mod(desc(RSRC_)-1+nprows,nprows).eq.proc)southmost=.true.
         return
        end function southmost
      end module northsouth

