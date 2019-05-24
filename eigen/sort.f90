! Program to take a matrix in the form of a list
! of triplets of the from (i1,j1,x1),(i2,j2,x2)...
! and write the matrix in Compressed Row Storage
! format.
! See: http://netlib.org/linalg/html_templates/node91.html
!      contains our example data set and information on the
!      CRS format
! See: http://www.fortran.com/qsort_c.f95
!      source for the qsort routine given below.  We just 
!      changed the data type from real to "ent"
! Tim Kaiser
! Dec 

module mytype
    type :: ent
        integer :: i,j
        real*8 :: val
    end type
    interface operator ( <= )
        module procedure lteq
    end interface
    interface operator ( >= )
        module procedure gteq
    end interface
    contains
        function lteq(a,b)
            type(ent) :: a,b
            intent(in) :: a,b
            logical lteq
            if(a%i < b%i)then
                lteq = .true. ; return
            endif
            if(a%i > b%i)then
                lteq =  .false. ; return
            endif
            if(a%j <= b%j)then
                lteq =   .true. ; return
            endif
            lteq =  .false. ; return
        end function lteq

        function gteq(a,b)
            type(ent) :: a,b
            intent(in) :: a,b
            logical gteq
            if(a%i > b%i)then
                gteq= .true. ; return
            endif
            if(a%i < b%i)then
                gteq= .false. ; return
            endif
            if(a%j >= b%j)then
                gteq= .true. ; return
            endif
            gteq= .false. ; return
        end function gteq
end module

module qsort_c_module

use mytype 
implicit none

public :: QsortC
private :: Partition

contains

recursive subroutine QsortC(A)
  type(ent), intent(in out), dimension(:) :: A
  integer :: iq

  if(size(A) > 1) then
     call Partition(A, iq)
     call QsortC(A(:iq-1))
     call QsortC(A(iq:))
  endif
end subroutine QsortC

subroutine Partition(A, marker)
  type(ent), intent(in out), dimension(:) :: A
  integer, intent(out) :: marker
  integer :: i, j
  type(ent) :: temp
  type(ent) :: x      ! pivot point
  x = A(1)
  i= 0
  j= size(A) + 1

  do
     j = j-1
     do
        if (A(j) <= x) exit
        j = j-1
     end do
     i = i+1
     do
        if (A(i) >= x) exit
        i = i+1
     end do
     if (i < j) then
        ! exchange A(i) and A(j)
        temp = A(i)
        A(i) = A(j)
        A(j) = temp
     elseif (i == j) then
        marker = i+1
        return
     else
        marker = i
        return
     endif
  end do

end subroutine Partition


    subroutine getrow(vals,row_ptr,numnz)
        use mytype
        implicit none
        type(ent):: vals(:)
        integer row_ptr(:)
        integer numnz
        integer row,rc,k
        row=1
        rc=1
        row_ptr(1)=rc
        do k=1,numnz
!        write(*,*)vals(k)%i,vals(k)%j,vals(k)%val
            if(row .ne. vals(k)%i)then
                row=vals(k)%i
                rc=rc+1
                row_ptr(rc)=k
            endif
        enddo
        rc=rc+1
        row_ptr(rc)=k
    end subroutine 
end module qsort_c_module
