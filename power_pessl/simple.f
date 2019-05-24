!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    5765-C41                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1997. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
	program simple
!
!  program designed to show how to use the sample utilities
!   This program will sum two distributed arrays and compare
!   the results to the same calculation done on a single 
!   processor.
!
	use putilities

        implicit none
        real(8),pointer :: array1(:,:), array2(:,:)
        real(8),pointer :: brray1(:,:), brray2(:,:)
        real(8),pointer :: crray1(:,:), crray2(:,:)
        real(8),pointer :: esbufa(:,:), wsbufa(:,:)
        real(8),pointer :: esbufb(:,:), wsbufb(:,:)
        real(8),pointer :: erbufa(:,:), wrbufa(:,:)
        real(8),pointer :: erbufb(:,:), wrbufb(:,:)
        integer :: darray1(DESC_DIM), dbrray1(DESC_DIM)
        integer :: dcrray1(DESC_DIM)
        integer :: status
        integer, parameter :: psize=10, bsize=3
        integer :: iglr(psize), iglc(psize)
        integer :: nrows, ncols, myrow, mycol, i,j
        integer :: jlocal_first, jlocal_last, ilocal_last
        integer :: ilocal_first, ib, jb, nprocs,myproc
        integer :: row_blocks, col_blocks, eastcols, westcols

        integer numroc
        external numroc


!
!   initialize the communication
!
        call blacs_pinfo(nprocs,myproc)
        nrows=1
        ncols=myproc
        write(*,*)"Hello from ",myproc," of ",nprocs
!
! create the largest possible 1xq processor grid
!


!
! initialize the utilities
!
        call initutils(status,nrows,ncols)
        if( status .ne. 0 ) then
          write(*,*) 'Communication initialization failed'
          stop 1
        endif

!
!  create distributed arrays and corresponding descriptors
!
        call array_create(array1,darray1,psize,psize,
     &              CREATE_CYCLIC,bsize,bsize)
        call array_create(brray1,dbrray1,psize,psize,
     &              CREATE_CYCLIC,bsize,bsize)
        call array_create(crray1,dcrray1,psize,psize,
     &              CREATE_CYCLIC,bsize,bsize)

!
! get global to local index mapping
!
        call g2l(darray1,iglr,iglc)


!
! allocate corresponding local arrays
!
        allocate(array2(psize,psize))
        allocate(brray2(psize,psize))
        allocate(crray2(psize,psize))



!
!  fill the distributed and local arrays with the same data
!
        do j = 1, psize
          do i = 1, psize
            array2(i,j) = psize*(i-1) + (j-1)
            brray2(i,j) = psize*(j-1) + (i-1)
            if(iglc(j) .ne. -1 .and. iglr(i) .ne. -1) then
               array1(iglr(i),iglc(j)) = psize*(i-1) + (j-1)
               brray1(iglr(i),iglc(j)) = psize*(j-1) + (i-1)
            endif
          enddo
        enddo

!
!  fill crray2 will sums from array2 and brray2 with index offset by 1
!
        do j = 1, psize
          crray2(j,1) = brray2(j,2)
          crray2(j,psize) = array2(j,psize-1)
          do i = 2, psize-1
            crray2(j,i) =  array2(j,i-1) + brray2(j,i+1)
          enddo
        enddo

        call blacs_gridinfo(p_context(),nrows,ncols,myrow,mycol)



!loop over all column block

!
!  do the correponding distributed calculation
!
        row_blocks = number_row_blocks(dcrray1,myrow)
        col_blocks = number_col_blocks(dcrray1,mycol)
        westcols = number_col_blocks(dcrray1,mod(ncols-1+mycol,ncols))
        eastcols = number_col_blocks(dcrray1,mod(1+mycol,ncols))
        write(*,*) row_blocks, col_blocks, westcols, eastcols


 
!
! first, get nearest neighbor points of brray1 and array1
!
        allocate(wsbufb(psize,westcols))
        allocate(erbufb(psize,col_blocks))
        allocate(wrbufa(psize,col_blocks))
        allocate(esbufa(psize,eastcols))


        call sendwestborder(brray1,darray1,wsbufb)
        call sendeastborder(array1,darray1,esbufa)

        call rcveastborder(brray1,darray1,erbufb)
        call rcvwestborder(array1,darray1,wrbufa)



!
!  now do the corresponding sum for crray1 as was done for crray2
!  
!

!
! sum over each block
!
        do ib = 0, col_blocks - 1 
         ilocal_first = ib*bsize+1
         ilocal_last= bsize
         if( ib .eq. col_blocks-1) then
           ilocal_last= last_col_block_size(darray1,mycol)
         endif
         ilocal_last = ilocal_last+ib*bsize


          do jb = 0, row_blocks -1
         
           jlocal_first = jb*bsize +1
           jlocal_last =  bsize
           if( jb .eq. row_blocks-1) then
             jlocal_last= last_row_block_size(darray1,myrow)
           endif
           jlocal_last =  jb*bsize+jlocal_last
           

!
!  sum over each element in each block
!

!
!  worry first about the border points
!
           do j = jlocal_first,jlocal_last
            if( ilocal_first.eq.ilocal_last) then
              crray1(j,ilocal_first)=wrbufa(j,ib+1)
            else
              crray1(j,ilocal_first) = wrbufa(j,ib+1) +                     &
     &            brray1(j,ilocal_first+1)
              crray1(j,ilocal_last) = erbufb(j,ib+1) +                      &
     &            array1(j,ilocal_last-1)
            endif
          
!
! now sum over the interior points
!
            do i = ilocal_first+1, ilocal_last-1
             crray1(j,i) =  array1(j,i-1) + brray1(j,i+1)
            enddo
           enddo
          enddo
        enddo



!
!  gather carray1 into the local matrix brray2
!
        call gather(crray1,dcrray1,brray2,0,0)


!
!  verify that the same data is in distributed matrix crray1 as
!  is in the local matrix crray2.
!

        if( myrow .eq. 0  .and. mycol .eq. 0 ) then
           do i = 1, size(crray2,1)
             write(*,'(10f7.2)')(brray2(i,j),j=1,size(crray2,2))
           enddo
             write(*,'(10f7.2)')
           do i = 1, size(crray2,1)
             write(*,'(10f7.2)')(crray2(i,j),j=1,size(crray2,2))
           enddo
        endif
!
! stop blacs
!
        call exitutils(0)
        stop
        end

