    type thefit
      sequence
      real(b8) val
      integer index,proc,to,buff
    end type thefit
module sort_mod
! recursive merge sort taken from pascal routine in
! moret & shapiro's book

  interface operator (.test.)
    module procedure thetest
  end interface

  interface operator (.lt.)
    module procedure theless
  end interface

  interface operator (.gt.)
    module procedure thegreat
  end interface

contains


    function theless(a,b)
    use galapagos
    type(thefit), intent (in) :: a,b
    logical theless
    if(a%val < b%val)then
        theless=.true.
    else
        theless=.false.
    endif
    return
  end function theless

    function thegreat(a,b)
    use galapagos
    type(thefit), intent (in) :: a,b
    logical thegreat
    if(a%val > b%val)then
        thegreat=.true.
    else
        thegreat=.false.
    endif
    return
  end function thegreat


function thetest(a,b)
    use galapagos
    type(thefit), intent (in) :: a,b
    logical thetest
    if(a%val >= b%val)then
        thetest=.true.
    else
        thetest=.false.
    endif
    return
  end function thetest

  subroutine Sort(Ain, n)
    use Merge_mod_types
    integer n
    type(thefit), target:: ain(n)
    allocate(work(n))
    nullify(a)
    a=>ain
    call RecMergeSort(1,n)
    deallocate(work)
    return
  end subroutine Sort

  recursive subroutine RecMergeSort(left, right)
    use Merge_mod_types
    integer,intent(in):: left,right
    integer  middle
    if (left < right) then
        middle = (left + right) / 2
        call RecMergeSort(left,middle)
        call RecMergeSort(middle+1,right)
        call Merge(left,middle-left+1,right-middle)
    endif
    return
  end subroutine RecMergeSort

  subroutine Merge(s, n, m)
    use Merge_mod_types
    integer s,n,m
    integer i,  j, k, t, u
    k = 1
    t = s + n
    u = t + m
    i = s
    j = t
    if ((i < t) .and. (j < u))then
        do while ((i < t) .and. (j < u))
            if (A(i) .test.  A(j))then
                work(k) = A(i)
                i = i + 1
                k = k + 1
            else
                work(k) = A(j)
                j = j + 1
                k = k + 1 
            endif
         enddo
    endif
    if(i < t )then
        do while (i < t )
            work(k) = A(i)
            i = i + 1
            k = k + 1
        enddo
    endif
    if(j < u)then
        do while (j < u )
            work(k) = A(j)
            j = j + 1
            k = k + 1
        enddo
    endif
    i = s
! the next line is not in moret & shapiro's book
    k=k-1
    do j = 1 , k  
        A(i) = work(j)
        i = i + 1
    enddo
    return
  end subroutine Merge
end module sort_mod
