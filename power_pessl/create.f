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
      module create
        use  pdata
        implicit none

      private
!
!  everything private by default
!
!
!  This module contains the generic routines for creating a distributed
!  array. The generic format for the call is
!
!        subroutine array_create(array,desc,m,n,block_type,mblock,nblock,
!                               row_source, col_source)
!
!   This subroutine dynamically allocates space for the local portion
!   of a distributed matrix and also initializes the corresponding
!   array descriptor. Only the first four arguments are required, with the
!   rest being optional.
!
!        Subroutine arguments:
!
!          array :: output, required, fortran 90 pointer to array
!            The pointer for this array (real or complex) must be
!            unallocated upon entry and will be initialized to contain
!            the exact number of local rows and columns required for
!            the local portion of a distributed matrix.
!
!          desc :: output, required, integer array
!            An array containing at least 8 elements is initialized to
!            correspond to the distributed matrix.
!
!          m    :: input, required, integer
!            The number of rows in the global matrix.
!
!          n    :: input, required, integer
!            The number of columns in the global matrix.
!
!          block_type :: integer, input, optional
!            Array type, currently either block cyclic or block are
!            supported and will default to block cyclic. The
!            putilities module includes the following parameters:
!               CREATE_BLOCK = 1
!               CREATE_CYCLIC = 2
!
!          mblock, nblock :: integer, input optional
!            For block cyclic distributions these are the row and
!            column block sizes, defaults to 70 for each one.
!
!          row_source, col_source :: integer, input optional
!            The column and row process number of the first block
!            of the distributed array. Defaults to 0,0.
!

!       Subroutines called:
!          blacs_pinfo  from the blacs library


      public :: create_c_array, create_z_array
      public :: create_s_array, create_d_array
      contains

!****************************************************************************!
!*                                                                          *!
!*   Module routine create_c_array                                          *!
!*                                                                          *!
!*   Purpose: Initialize blacs and calculate a block size                   *!
!*                                                                          *!
!****************************************************************************!
        subroutine create_c_array(array,desc,m,n,block_type,                  &
     &                        mblock,nblock,row_source,col_source)

   
        complex(short_t), pointer :: array(:,:)
        integer, intent(out) :: desc(:)
        integer, intent(in)  :: m,n
        integer, intent(in), optional :: block_type, mblock, nblock
        integer, intent(out), optional :: row_source, col_source


        integer :: info_save, nb, mb, rsrc, csrc, type
        integer :: ldarray, sdarray, stat
        integer, parameter :: bs_default = 40
        integer numroc
        external numroc
         


        if ( .not. initialized ) then ! return because it is not initialized
          call blacs_pinfo(mynode,numprocs)
          if( mynode.eq.0) then
            write(*,*) 'create_c_array: not initialized'
          endif
          return
        endif
 
        type=CREATE_CYCLIC
        if(present(block_type)) type = block_type

        if ( present(row_source) ) then
          if ( row_source .lt. 0 .or. row_source .ge. nprows) then
            write(*,*) 'row source out of bounds ', row_source, nprows
            call blacs_abort(icontext,1)
          else
            rsrc = row_source
          endif
        else
          rsrc = 0
        endif

        if ( present(col_source) ) then
          if ( col_source .lt. 0 .or. col_source .ge. npcols) then
            write(*,*) 'column source out of bounds ',col_source,npcols
            call blacs_abort(icontext,1)
          else
            csrc = col_source
          endif
        else
          csrc = 0
        endif



        !
        !  if type is block, fit the matrix as best as possible in
        !                    the array grid
        
        if( type == CREATE_BLOCK) then
           mb = max(1,( m + nprows -1 )/ nprows)
           nb = max(1,( n + npcols -1 )/ npcols)
           ldarray = max(1,numroc( m, mb, myrow, 0, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, 0, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_c_array"
             endif
             call blacs_abort(icontext,1)
           endif

           
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = 0
           desc(CSRC_) = 0
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else if( type == CREATE_CYCLIC) then
           mb = bs_default
           if( present(mblock)) mb = mblock
           nb = bs_default
           if( present(nblock)) nb = nblock
           ldarray = max(1,numroc( m, mb, myrow, 0, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, 0, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_c_array"
             endif
             call blacs_abort(icontext,1)
           endif

           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = 0
           desc(CSRC_) = 0
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else
          if( mynode .eq. 0) then
             write(*,*)'Invalid type in create_c_array: ', type
             write(*,*)'Choose : CREATE_CYCLIC(',CREATE_CYCLIC,                &
     &                 ') or CREATE_BLOCK(',CREATE_BLOCK,')'
             call blacs_abort(icontext,1)
          endif
        endif

        end subroutine create_c_array
!****************************************************************************!
!*                                                                          *!
!*   Module routine create_z_array                                          *!
!*                                                                          *!
!*   Purpose: Initialize blacs and calculate a block size                   *!
!*                                                                          *!
!****************************************************************************!
        subroutine create_z_array(array,desc,m,n,block_type,                  &
     &                        mblock,nblock,row_source,col_source,info)

   
        complex(long_t), pointer :: array(:,:)
        integer, intent(out) :: desc(:)
        integer, intent(in)  :: m,n
        integer, intent(in), optional :: block_type, mblock, nblock
        integer, intent(out), optional :: row_source, col_source, info


        integer :: info_save, nb, mb, rsrc, csrc, type
        integer :: ldarray, sdarray, stat
        integer, parameter :: bs_default = 40
        integer numroc
        external numroc
         


        if ( .not. initialized ) then ! return because it is not initialized
          call blacs_pinfo(mynode,numprocs)
          if( mynode.eq.0) then
            write(*,*) 'create_z_array: not initialized'
          endif
          return
        endif

 
        type=CREATE_CYCLIC
        if(present(block_type)) type = block_type


        if ( present(row_source) ) then
          if ( row_source .lt. 0 .or. row_source .ge. nprows) then
            write(*,*) 'row source out of bounds ', row_source, nprows
            call blacs_abort(icontext,1)
          else
            rsrc = row_source
          endif
        else
          rsrc = 0
        endif

        if ( present(col_source) ) then
          if ( col_source .lt. 0 .or. col_source .ge. npcols) then
            write(*,*) 'column source out of bounds ',col_source,npcols
            call blacs_abort(icontext,1)
          else
            csrc = col_source
          endif
        else
          csrc = 0
        endif




        !
        !  if type is block, fit the matrix as best as possible in
        !                    the array grid
        
        if( type == CREATE_BLOCK) then
           mb = max(1,( m + nprows -1 )/ nprows)
           nb = max(1,( n + npcols -1 )/ npcols)
           ldarray = max(1,numroc( m, mb, myrow, 0, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, 0, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_z_array"
             endif
             call blacs_abort(icontext,1)
           endif
           
           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = 0
           desc(CSRC_) = 0
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else if( type == CREATE_CYCLIC) then
           mb = bs_default
           if( present(mblock)) mb = mblock
           nb = bs_default
           if( present(nblock)) nb = nblock
           ldarray = max(1,numroc( m, mb, myrow, 0, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, 0, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_z_array"
             endif
             call blacs_abort(icontext,1)
           endif

           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = 0
           desc(CSRC_) = 0
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else
          if( mynode .eq. 0) then
             write(*,*)'Invalid type in create_z_array: ', type
             write(*,*)'Choose : CREATE_CYCLIC(',CREATE_CYCLIC,                &
     &                 ') or CREATE_BLOCK(',CREATE_BLOCK,')'
             call blacs_abort(icontext,1)
          endif
        endif

        end subroutine create_z_array
!****************************************************************************!
!*                                                                          *!
!*   Module routine create_s_array                                          *!
!*                                                                          *!
!*   Purpose: Initialize blacs and calculate a block size                   *!
!*                                                                          *!
!****************************************************************************!
        subroutine create_s_array(array,desc,m,n,block_type,                  &
     &                        mblock,nblock,row_source,col_source,info)

   
        real(short_t), pointer :: array(:,:)
        integer, intent(out) :: desc(:)
        integer, intent(in)  :: m,n
        integer, intent(in), optional :: block_type, mblock, nblock
        integer, intent(out), optional :: row_source, col_source, info


        integer :: info_save, nb, mb, rsrc, csrc, type
        integer :: ldarray, sdarray, stat
        integer, parameter :: bs_default = 40
        integer numroc
        external numroc
         



        if ( .not. initialized ) then ! return because it is not initialized
          call blacs_pinfo(mynode,numprocs)
          if( mynode.eq.0) then
            write(*,*) 'create_s_array: not initialized'
          endif
          return
        endif

 
        type=CREATE_CYCLIC
        if(present(block_type)) type = block_type


        if ( present(row_source) ) then
          if ( row_source .lt. 0 .or. row_source .ge. nprows) then
            write(*,*) 'row source out of bounds ', row_source, nprows
            call blacs_abort(icontext,1)
          else
            rsrc = row_source
          endif
        else
          rsrc = 0
        endif

        if ( present(col_source) ) then
          if ( col_source .lt. 0 .or. col_source .ge. npcols) then
            write(*,*) 'column source out of bounds ',col_source,npcols
            call blacs_abort(icontext,1)
          else
            csrc = col_source
          endif
        else
          csrc = 0
        endif



        !
        !  if type is block, fit the matrix as best as possible in
        !                    the array grid
        
        if( type == CREATE_BLOCK) then
           mb = max(1,( m + nprows -1 )/ nprows)
           nb = max(1,( n + npcols -1 )/ npcols)
           ldarray = max(1,numroc( m, mb, myrow, 0, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, 0, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_s_array"
             endif
             call blacs_abort(icontext,1)
           endif

           
           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = 0
           desc(CSRC_) = 0
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else if( type == CREATE_CYCLIC) then
           mb = bs_default
           if( present(mblock)) mb = mblock
           nb = bs_default
           if( present(nblock)) nb = nblock
           ldarray = max(1,numroc( m, mb, myrow, 0, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, 0, npcols ))

           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_s_array"
             endif
             call blacs_abort(icontext,1)
           endif

           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = 0
           desc(CSRC_) = 0
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else
          if( mynode .eq. 0) then
             write(*,*)'Invalid type in create_s_array: ', type
             write(*,*)'Choose : CREATE_CYCLIC(',CREATE_CYCLIC,                &
     &                 ') or CREATE_BLOCK(',CREATE_BLOCK,')'
             call blacs_abort(icontext,1)
          endif
        endif

        end subroutine create_s_array

!****************************************************************************!
!*                                                                          *!
!*   Module routine create_d_array                                          *!
!*                                                                          *!
!*   Purpose: Initialize blacs and calculate a block size                   *!
!*                                                                          *!
!****************************************************************************!
        subroutine create_d_array(array,desc,m,n,block_type,                  &
     &                        mblock,nblock,row_source,col_source,info)

   
        real(long_t), pointer :: array(:,:)
        integer, intent(out) :: desc(:)
        integer, intent(in)  :: m,n
        integer, intent(in), optional :: block_type, mblock, nblock
        integer, intent(out), optional :: row_source, col_source, info


        integer :: info_save, nb, mb, rsrc, csrc, type
        integer :: ldarray, sdarray, stat
        integer, parameter :: bs_default = 40
        integer numroc
        external numroc
         
        if ( .not. initialized ) then ! return because it is not initialized
          call blacs_pinfo(mynode,numprocs)
          if( mynode.eq.0) then
            write(*,*) 'create_c_array: not initialized'
          endif
          return
        endif

 
        type=CREATE_CYCLIC
        if(present(block_type)) type = block_type


        if ( present(row_source) ) then
          if ( row_source .lt. 0 .or. row_source .ge. nprows) then
            write(*,*) 'row source out of bounds ', row_source, nprows
            call blacs_abort(icontext,1)
          else
            rsrc = row_source
          endif
        else
          rsrc = 0
        endif

        if ( present(col_source) ) then
          if ( col_source .lt. 0 .or. col_source .ge. npcols) then
            write(*,*) 'column source out of bounds ',col_source,npcols
            call blacs_abort(icontext,1)
          else
            csrc = col_source
          endif
        else
          csrc = 0
        endif


        !
        !  if type is block, fit the matrix as best as possible in
        !                    the array grid
        
        if( type == CREATE_BLOCK) then
           mb = max(1,( m + nprows -1 )/ nprows)
           nb = max(1,( n + npcols -1 )/ npcols)
           ldarray = max(1,numroc( m, mb, myrow, rsrc, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, csrc, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_d_array"
             endif
             call blacs_abort(icontext,1)
           endif

           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = rsrc
           desc(CSRC_) = csrc
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else if( type == CREATE_CYCLIC) then
           mb = bs_default
           if( present(mblock)) mb = mblock
           nb = bs_default
           if( present(nblock)) nb = nblock
           ldarray = max(1,numroc( m, mb, myrow, rsrc, nprows ))
           sdarray = max(1,numroc( n, nb, mycol, csrc, npcols ))
           allocate (array(ldarray,sdarray),stat=stat)

           if( stat /= 0 ) then ! allocation failed
             if( mynode .eq.0) then
               write(*,*) "allocation failure in create_d_array"
             endif
             call blacs_abort(icontext,1)
           endif

           desc(DTYPE_) = TWO_D_TYPE
           desc(M_) = m
           desc(N_) = n
           desc(MB_) = mb
           desc(NB_) = nb
           desc(RSRC_) = rsrc
           desc(CSRC_) = csrc
           desc(CTXT_) = icontext
           desc(LLD_) = ldarray

        else
          if( mynode .eq. 0) then
             write(*,*)'Invalid type in create_d_array: ', type
             write(*,*)'Choose : CREATE_CYCLIC(',CREATE_CYCLIC,                &
     &                 ') or CREATE_BLOCK(',CREATE_BLOCK,')'
             call blacs_abort(icontext,1)
          endif
        endif
        return

        end subroutine create_d_array

      end module create
