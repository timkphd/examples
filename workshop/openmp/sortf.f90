module galapagos
    type thefit
      sequence
      real val
      integer index
    end type thefit
end module

module sort_mod

contains

  subroutine Sort(Ain, n)
    use galapagos
    type(thefit), pointer :: work(:)
    type(thefit), pointer :: a(:)
    common /bonk/ a,work
!$OMP THREADPRIVATE (/bonk/)
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
    use galapagos
    type(thefit), pointer :: work(:)
    type(thefit), pointer :: a(:)
    common /bonk/ a,work
!$OMP THREADPRIVATE (/bonk/)
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
    use galapagos
    type(thefit), pointer :: work(:)
    type(thefit), pointer :: a(:)
    common /bonk/ a,work
!$OMP THREADPRIVATE (/bonk/)
    integer s,n,m
    integer i,  j, k, t, u
    k = 1
    t = s + n
    u = t + m
    i = s
    j = t
    if ((i < t) .and. (j < u))then
        do while ((i < t) .and. (j < u))
            if (A(i)%val .ge. A(j)%val)then
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
  
! this subroutine takes two sorted lists of type(thefit) and merges them
! input d1(n) , d2(m)
! output out(n+m)
subroutine merge2(d1,n,d2,m,out)
  use galapagos
  implicit none
    type(thefit), pointer :: work(:)
    type(thefit), pointer :: a(:)
    common /bonk/ a,work
!$OMP THREADPRIVATE (/bonk/)
  integer n,m
  type(thefit),intent (in):: d1(n),d2(m)
  type(thefit), intent (out):: out(n+m)
  integer i,j,k
  i=1
  j=1
  do k=1,n+m
    if(i.gt.n)then
      out(k)=d2(j)
      j=j+1
    elseif(j.gt.m)then
      out(k)=d1(i)
      i=i+1
    else
      if(d1(i)%val .gt. d2(j)%val)then
        out(k)=d1(i)
        i=i+1
      else
        out(k)=d2(j)
        j=j+1
      endif
    endif
   enddo
  return
  end subroutine merge2
end module sort_mod


program test
    use galapagos
    use sort_mod
    implicit none
    integer i,j,k,m,di,k1,k2
    integer OMP_GET_MAX_THREADS
    integer, allocatable :: kstart(:),kend(:)
    type(thefit),allocatable :: data(:),output1(:),output2(:)
    write(*,*)"sort in fortran"
    i=32
    allocate(data(i))

    do j=1,i
        call random_number(data(j)%val)
        data(j)%index=j
        write(*,*)data(j)%index,data(j)%val
    enddo
    write(*,*)
!   
    m=4
    di=i/m
    allocate(kstart(m),kend(m))
    kstart(1)=1
    kend(1)=di
    do j=2,m
        kstart(j)=kend(j-1)+1
        kend(j)=kstart(j)+di
    enddo
    kend(m)=i
    write(*,"(8i5)")kstart
    write(*,"(8i5)")kend
!$OMP PARALLEL SECTIONS
!$OMP SECTION
 		call sort(data(kstart(1):kend(1)), kend(1)-kstart(1)+1 )
!$OMP SECTION
		call sort(data(kstart(2):kend(2)), kend(2)-kstart(2)+1 )
!$OMP SECTION
		call sort(data(kstart(3):kend(3)), kend(3)-kstart(3)+1 )
!$OMP SECTION
		call sort(data(kstart(4):kend(4)), kend(4)-kstart(4)+1 )
!$OMP END PARALLEL SECTIONS
    do k=1,m
    	write(*,*)"start of section ",k
	    do j=kstart(k),kend(k)
	        write(*,"(i5,1x,f10.8)")data(j)%index,data(j)%val
	    enddo
    enddo
!$OMP PARALLEL SECTIONS
!$OMP SECTION
    k1=kend(2)-kstart(1)+1
    allocate(output1(k1))
    call merge2(data(kstart(1):kend(1)),kend(1)-kstart(1)+1, &
                data(kstart(2):kend(2)),kend(2)-kstart(2)+1,output1)
!$OMP SECTION
    k2=kend(4)-kstart(3)+1
    allocate(output2(k2))
    call merge2(data(kstart(3):kend(3)),kend(3)-kstart(3)+1, &
                data(kstart(4):kend(4)),kend(4)-kstart(4)+1,output2)
!$OMP END PARALLEL SECTIONS
    call merge2(output1,k1,output2,k2,data)
    
    write(*,*)"ending list "
    do j=1,i
        write(*,"(i5,1x,f10.8)")data(j)%index,data(j)%val
    enddo
end program
