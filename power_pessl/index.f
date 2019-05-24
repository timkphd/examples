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
      module index
      use pdata
      private 
!
!  everything private by default
!
      implicit none
      integer              :: numroc
      external                numroc

!
!  This module contains useful index routines. Two subroutines will
!  return the local and global index mappings. The others will return
!  the number of row and column blocks contained in a matrix and the
!  block size of the last row and blocks for a distributed matrix
!  formats of the routines are given with the subroutines
!
!

!  Subroutines called:
!    numroc   from  pessl library

      public g2l, l2g, number_row_blocks, number_col_blocks
      public last_row_block_size, last_col_block_size
  
       contains


      subroutine g2l(desc,il,jl)
      integer, intent(in)  :: desc(:)
      integer, intent(out) :: il(:), jl(:)
!
!      This function returns the local indices corresponding to the
!      global indices on the processor where it is called
!
!        Subroutine arguments:
!
!        desc :: integer array, input, required
!           The array descriptor for the array to
!           which the indices correspond.
!
!        il  ::  integer array, output, required
!        jl  ::  integer array, output, required
!
!            The index (il(i), jl(j)) in the local array, corresponds to
!            the index (i,j) in the global array. If the global array
!            element is not on the current processor, il(i)  or jl(j) will
!            be set to -1.
!
      integer i, global_rblock_count, global_cblock_count, ib
      integer ib_local
 
!
! set all local element to -1
!
      il = -1
      jl = -1

!
! return if not initialized
!
      if( .not. initialized) return


!
! test to make sure we have arrays are large enough
!
      if( size(il,1) .lt. desc(M_) ) then
        write(*,*) 'idxg2l: Global index array il too small'
        write(*,*) 'sizes: ',size(il,1),desc(M_)
        call blacs_abort(icontext,1)
      endif

      if( size(jl,1) .lt. desc(N_) ) then
        write(*,*) 'idxg2l: Global index array jl too small'
        write(*,*) 'sizes: ',size(jl,1),desc(N_)
        call blacs_abort(icontext,1)
      endif



!
!  calculate the total number of column blocks
!
      global_cblock_count = icd(desc(N_),desc(NB_))
      ib_local = 0
!
! loop over the full column blocks
!
      do ib = 1, global_cblock_count-1
        if( mod((desc(CSRC_)+ib-1),npcols) .eq. mycol) then
!
!  if the block is on myrow, fill in local indices in jl
!  This could be easily modified to return both, column processor and 
!  local index
!
          do i = 1, desc(NB_)
            jl((ib-1)*desc(NB_)+i) = ib_local*desc(NB_) +i
          enddo
          ib_local = ib_local+1
        endif
      enddo
          
!
! finally do left over piece
!
      if(mod(desc(CSRC_)+global_cblock_count-1,npcols) .eq. mycol) then
        do i = 1, icr(desc(N_) ,desc(NB_)) + desc(NB_)
          jl((global_cblock_count-1)*desc(NB_)+i) = ib_local*desc(NB_)+i
        enddo
      endif
        

!
!  calculate the total number of row blocks
!
      global_rblock_count = icd(desc(M_),desc(MB_))
      ib_local = 0
!
! loop over the full row blocks
!
      do ib = 1, global_rblock_count-1
        if( mod( (desc(RSRC_)+ib-1),nprows) .eq. myrow) then
!
!  if the block is on myrow, fill in local indices in il
!  This could be easily modified to return both, row processor and 
!  local index
!
          do i = 1, desc(MB_)
            il((ib-1)*desc(MB_)+i) = ib_local*desc(MB_) +i
          enddo
          ib_local = ib_local+1
        endif
      enddo
          
!
! finally do left over piece
!
      if(mod(desc(RSRC_)+global_rblock_count-1,nprows) .eq. myrow)  then
        do i = 1, icr(desc(M_),desc(MB_)) + desc(MB_)
          il((global_rblock_count-1)*desc(MB_)+i) = ib_local*desc(MB_)+i
        enddo
      endif
      return
      end subroutine g2l

      integer function number_row_blocks(desc,prow)
       integer,intent(in)            :: desc(:)
       integer, optional, intent(in) :: prow
!
!      This subroutine returns the number of local row
!      blocks contained on the local part of a distributed matrix
!
!        Subroutine arguments:
!
!        desc :: integer array, input, required
!           The array descriptor for the array to
!           which the number of blocks applies
!
!        prow :: integer, input, optional
!           The processor row containing the local array. Defaults to
!           the current row processor
!
       integer :: rows

       if( .not. initialized ) then
         number_row_blocks = -1
         return
       endif

       if( present(prow)) then
        rows = numroc(desc(M_),desc(MB_),prow,desc(RSRC_),nprows)
       else
        rows = numroc(desc(M_),desc(MB_),myrow,desc(RSRC_),nprows)
       endif
       number_row_blocks = icd(rows,desc(MB_))
       return
      end function number_row_blocks





      integer function number_col_blocks(desc,pcol)
       integer,intent(in)           :: desc(:)
       integer,intent(in), optional :: pcol
!
!      This subroutine returns the number of local column
!      blocks contained on the local part of a distributed matrix
!
!        Subroutine arguments:
!
!        desc :: integer array, input, required
!           The array descriptor for the array to
!           which the number of blocks applies
!
!        pcol :: integer, input, optional
!           The processor column containing the local array. Defaults to
!           the current column processor
!
       integer :: cols

       if( .not. initialized ) then
         number_col_blocks = -1
         return
       endif

       if( present(pcol)) then
        cols = numroc(desc(N_),desc(NB_),pcol,desc(CSRC_),npcols)
       else
        cols = numroc(desc(N_),desc(NB_),mycol,desc(CSRC_),npcols)
       endif
       number_col_blocks = icd(cols,desc(NB_))
       return
      end function number_col_blocks



      integer function last_row_block_size(desc,prow)
        integer,           intent(in) :: desc(:)
        integer, optional, intent(in) :: prow
        integer             :: rows
!
!     This subroutine returns the size of the last row block for
!     the local portion of a distributed array.  All other blocks
!     have the size desc(3). Since last block will in general be
!     incomplete, its size will be between 1 and desc(3).
!
!        Subroutine arguments:
!
!        desc :: integer array, input, required
!           The array descriptor for the array to
!           which the last block size applies.
!
!        prow :: integer, input, optional
!           The processor row containing the local array. Defaults to
!           the current row processor.
!


!
!  return if not initialized
!
        if( .not. initialized ) then
          last_row_block_size = -1
          return
        endif

!
! calculate total number of local rows
!
        if(present(prow)) then
         rows = numroc(desc(M_),desc(MB_),prow,desc(RSRC_),nprows)
        else
         rows = numroc(desc(M_),desc(MB_),myrow,desc(RSRC_),nprows)
        endif
!
! return the remainder when divided by the row block size
! or a full block size if evenly divisible.
!
        last_row_block_size = mod( rows-1,desc(MB_)) + 1
        return
      end function last_row_block_size




      integer function last_col_block_size(desc,pcol)
        integer,           intent(in) :: desc(:)
        integer, optional, intent(in) :: pcol
        integer                       :: cols
!
!     This subroutine returns the size of the last column block for
!     the local portion of a distributed array.  All other blocks
!     have the size desc(4). Since last block will in general be
!     incomplete, its size will be between 1 and desc(4).
!
!        Subroutine arguments:
!
!        desc :: integer array, input, required
!           The array descriptor for the array to
!           which the last block size applies.
!
!        pcol :: integer, input, optional
!           The processor column containing the local array. Defaults to
!           the current column processor
!


!
!  return if not initialized
!
        if( .not. initialized ) then
          last_col_block_size = -1
          return
        endif

!
!  calculate total number of columns
!
        if(present(pcol)) then
         cols = numroc(desc(N_),desc(NB_),pcol,desc(CSRC_),npcols)
        else
         cols = numroc(desc(N_),desc(NB_),mycol,desc(CSRC_),npcols)
        endif
!
! return the remainder when divided by the column block size
! or a full block size if evenly divisible.
!
        last_col_block_size = mod( cols-1,desc(NB_)) + 1
      end function last_col_block_size


!
!  two private utilitity functions 
!
      integer function icd(ij,ik)
        integer ij,ik
        icd = ((ij)+(ik)-1)/(ik)
      end function icd


      integer function icr(ij,ik)
        integer ij,ik
        icr = (ij) - (ik)*icd((ij),(ik))
      end function icr




      subroutine l2g(desc,ig,jg)
      integer, intent(in)  :: desc(:)
      integer, intent(out) :: ig(:), jg(:)
!
!      This function returns the global indices corresponding to the
!      local indices on the processor where it is called.
!
!        Subroutine arguments:
!
!        desc :: integer array, input, required
!           The array descriptor for the array to
!           which the indices correspond.
!
!        ig  ::  integer array, output, required
!        jg  ::  integer array, output, required
!
!            The index (i,j) in the local array, corresponds to
!            the index (ig(i),jg(j)) in the global array.
!

      integer              :: i, nrows, ncols, start_block
      integer              :: iblock, lasti, nblocks

!
! set the global indices to -1
!
      ig = -1
      jg = -1
!
! return if not initialized
!
      if( .not. initialized) return


!
! determine how many rows and columns we have
!
      nrows = numroc(desc(M_),desc(MB_),myrow,desc(RSRC_),nprows)
      ncols = numroc(desc(N_),desc(NB_),mycol,desc(CSRC_),npcols)

!
! verify the index arrays are big enough
!
      if( size(ig,1) .lt. nrows ) then
        write(*,*) 'l2g: Local index array ig too small'
        write(*,*) 'sizes: ',size(ig,1), nrows
        call blacs_abort(icontext,1)
      endif

      if( size(jg,1) .lt. ncols ) then
        write(*,*) 'l2g: Local index array jg too small'
        write(*,*) 'sizes: ',size(jg,1), ncols
        call blacs_abort(icontext,1)
      endif

!
!  start_block is the global row block corresponding to row block 0
!  on the local processor
!
      start_block = desc(RSRC_) + mod(desc(RSRC_)+nprows-myrow,nprows)

!
!  nblocks is total number of local blocks
!
      nblocks  = number_row_blocks(desc,myrow)
      
!
! loop over all local blocks
!
      do iblock = 0, nblocks -1
        lasti= min(desc(MB_), desc(M_)-(start_block+iblock)*desc(MB_))
!
! within each row block calculate the corresponding global indices
!
        do i = 1, lasti
          ig(i) = ( start_block + iblock) * desc(MB_) + i
        enddo
      enddo
     
!
!  start_block is the global column block corresponding to column block 0
!  on the local processor
!
      start_block = desc(CSRC_) + mod(desc(CSRC_)+npcols-mycol,npcols)
!
!  nblocks is total number of column blocks on local processor
!
      nblocks  = number_col_blocks(desc,myrow)
      
!
!  loop over each local column block
!
      do iblock = 0, nblocks -1
        lasti = min(desc(NB_), desc(N_)-(start_block+iblock)*desc(NB_))
!
! within each column block calculate the corresponding global indices
!
        do i = 1, lasti
          jg(i) = ( start_block + iblock) * desc(NB_) + i
        enddo
      enddo
      return
      end subroutine l2g

      end module index

