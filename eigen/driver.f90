program atest
   use mytype
   use qsort_c_module
   implicit none
   integer :: numnz,msize
   integer :: k 
   integer , parameter :: maxnz=100000
   integer , allocatable:: row_ptr(:)
   type(ent), allocatable:: vals(:)
! Read the number of nonzeros and the size of the matrix
   read(*,*)numnz,msize
! Allocate our vector to store the data triplets.  In
! the end this will also contain col_ind and values
! in the proper order.
! NOTE: numnz <= maxnz
   allocate(vals(maxnz))
! Read our data.  In a real program the data could be
! generated on the fly in any order.
   do k=1,numnz
        read(*,*)vals(k)%i,vals(k)%j,vals(k)%val
   enddo
! On return from QsortC vals%j contains the col_ind
! and vals%val contains the values.  Note we pass in
! only the section of the array that contains data.
   call QsortC(vals(1:numnz))
! By convention row_ptr is one bigger than the
! size of the matrix and the last entry is equal
! to numnz+1.
   allocate(row_ptr(msize+1))
! Fill row_ptr
   call getrow(vals,row_ptr,numnz)
! Write out the row_ptr
   write(*,*)row_ptr
   write(*,*)
! Write out the col_ind
   write(*,*)vals(1:numnz)%j
   write(*,*)
! Write out the values
   write(*,*)vals(1:numnz)%val
 end program  
