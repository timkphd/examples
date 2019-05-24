!  cc_r -c bind.c
!  mpxlf90_r -O3 -qsmp=noauto:omp -qsource t_sort.f bind.o -o psort
module galapagos
    type thefit
      sequence
      real val
      integer index,proc
    end type thefit
end module

module mpi
      include 'mpif.h'
      integer numnodes,myid,my_root,ierr
end module

module uname
    contains
    function unique(name)
    use mpi
    character (len=*) name
    character (len=20) unique
    character (len=80) temp
    if(myid .gt. 99)then
      write(temp,"(a,i3)")trim(name),myid
    else
        if(myid .gt. 9)then
            write(temp,"(a,'0',i2)")trim(name),myid
        else
            write(temp,"(a,'00',i1)")trim(name),myid
        endif
    endif
    unique=temp
    return
end function unique
end module uname

module sort_mod
! recursive merge sort taken from pascal routine in
! moret & shapiro's book

contains

  subroutine Sort(ain, n)
    use galapagos
    integer n
    type(thefit), target:: ain(n)
    type(thefit), pointer :: work(:)
    type(thefit), pointer :: a(:)
    common /bonk_it/ a,work
!$OMP THREADPRIVATE (/bonk_it/)
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
    common /bonk_it/ a,work
!$OMP THREADPRIVATE (/bonk_it/)
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
    integer s,n,m
    integer i,  j, k, t, u
    type(thefit), pointer :: work(:)
    type(thefit), pointer :: a(:)
    common /bonk_it/ a,work
!$OMP THREADPRIVATE (/bonk_it/)
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



module my_collective
  contains
    ! MY_MERGE a global merge routine
    ! MY_MERGE takes as input a sorted list of values from each
    ! processor
    ! it outputs on the root a sorted list of values which is a 
    ! merged list from each processor
    ! when a processor recieves a list from another processor it 
    ! merges its list with the new one before sending the list on
    ! this routine is a fortran 90 implimentation of a gather
    ! routine plus the merge step
    subroutine MY_MERGE(input,n,output,m,root,THETAG,THECOM,MPI_FIT)
      use galapagos
      use mpi
      use sort_mod
      implicit none
      integer, intent(in) :: n
      type(thefit), intent(inout) :: input(n)
      type(thefit), intent (inout):: output(*)
      integer, intent (inout):: m
      integer, intent(in) :: root
      integer THETAG,THECOM,MPI_FIT,NTAG
      integer iout
    
      type(thefit) , allocatable:: rec(:),temp(:),temp2(:)
      type(thefit) , allocatable :: data(:)
      integer p,active,rank,count,i,ijk
      integer status(MPI_STATUS_SIZE)
      call MPI_COMM_RANK( THECOM, rank, ierr )
      call MPI_COMM_SIZE( THECOM, p, ierr )
      iout=rank+100
      NTAG=(THETAG+1)
      active=1
      do while (2*active < p)
        active=active*2
      enddo
      if(rank .ge. active)then
! send(input,rank-active)
      write(iout,*)"at 200 send ",rank-active
      call MPI_SEND(input,n,MPI_FIT,rank-active,THETAG,THECOM,ierr)
        return
      endif
      allocate(data(n))
      data=input
      m=n
      if(rank + active  < p)then
! rec(new_data,rank+active)
        call MPI_PROBE(rank+active,THETAG,THECOM,status,ierr)
        call MPI_get_count(status,MPI_FIT,count,ierr)
        allocate(rec(count))
        write(iout,*)"at 211 recv ",rank+active
        call MPI_RECV(rec,count,MPI_FIT,rank+active,THETAG,THECOM,status,ierr)
! data=data+new_data
        allocate(temp(n+count))
        call merge2(input,n,rec,count,temp)
        if(allocated(data))deallocate(data)
        allocate(data(n+count))
        data=temp
        m=n+count
      endif
    do while (active > 1)
        active=active/2
        if(rank .ge. active) then
! send(data,rank-active)
            write(iout,*)"at 225 send ",rank-active
            call MPI_SEND(data,m,MPI_FIT,rank-active,THETAG,THECOM,ierr)
            if(allocated(data))deallocate(data)
            if(allocated(rec))deallocate(rec)
            if(allocated(temp))deallocate(temp)
            if(allocated(temp2))deallocate(temp2)
            return
        else
! recv(new_data,rank+active)
            call MPI_PROBE(rank+active,THETAG,THECOM,status,ierr)
            call MPI_get_count(status,MPI_FIT,count,ierr)
            if(allocated(rec))deallocate(rec)
            allocate(rec(count))
            write(iout,*)"at 238 recv ",rank+active
            call MPI_RECV(rec,count,MPI_FIT,rank+active,THETAG,THECOM,status,ierr)
! data=data+new_data
            if(allocated(temp2))deallocate(temp2)
            allocate(temp2(m+count))
            call merge2(data,m,rec,count,temp2)
            deallocate(data);allocate(data(m+count))
            data=temp2
            m=m+count    
        endif
    enddo
    if(rank .eq. root)then
        do i=1,m
            output(i)=data(i)
        enddo
    endif
    if(allocated(data))deallocate(data)
    if(allocated(rec))deallocate(rec)
    if(allocated(temp))deallocate(temp)
    if(allocated(temp2))deallocate(temp2)
    return
    end subroutine MY_MERGE
end module my_collective

    subroutine doseed(myseed)
      use mpi
      integer :: my_seed  ! optional argument not changed in the routine 
      integer,allocatable :: seed(:) 
      integer the_size,j 
          call random_seed(size=the_size)      ! how big is the intrisic seed? 
          allocate(seed(the_size))             ! allocate space for seed 
          do j=1,the_size                      ! create the seed 
             seed(j)=abs(my_seed)+(j-1)+myid*10   ! abs is generic 
          enddo 
          call random_seed(put=seed)           ! assign the seed 
          deallocate(seed)                     ! deallocate space 
    end subroutine
module ran_mod   
integer, parameter:: b8 = selected_real_kind(14) 

    contains   
         function ran1(idum,r,rm1,rm2,j,ix1,ix2,ix3 )  
            implicit none
            real(b8) ran1  
!*************                 
            real(b8) r(97),rm1,rm2  
            integer j  
            integer ix1,ix2,ix3 
!            common/ran_com/ r,rm1,rm2,j,ix1,ix2,ix3
!!$OMP THREADPRIVATE (/ran_com/)             
!*************            
            integer, intent(inout), optional :: idum  
            integer, parameter :: m1=259200,ia1=7141,ic1=54773  
            integer, parameter :: m2=134456,ia2=8121,ic2=28411  
            integer, parameter :: m3=243000,ia3=4561,ic3=51349  
            save ! corrects a bug in the original routine  
            if(present(idum))then  
              if (idum<0)then  
                rm1=1.0_b8/m1  
                rm2=1.0_b8/m2  
                ix1=mod(ic1-idum,m1)  
                ix1=mod(ia1*ix1+ic1,m1)  
                ix2=mod(ix1,m2)  
                ix1=mod(ia1*ix1+ic1,m1)  
                ix3=mod(ix1,m3)  
                do j=1,97  
                    ix1=mod(ia1*ix1+ic1,m1)  
                    ix2=mod(ia2*ix2+ic2,m2)  
                    r(j)=(real(ix1,b8)+real(ix2,b8)*rm2)*rm1  
                enddo  
                idum=1  
              endif  
            endif  
            ix1=mod(ia1*ix1+ic1,m1)  
            ix2=mod(ia2*ix2+ic2,m2)  
            ix3=mod(ia3*ix3+ic3,m3)  
            j=1+(97*ix3)/m3  
            if(j>97.or.j<1)then  
                write(*,*)' error in ran1 j=',j  
                stop  
            endif  
            ran1=r(j)  
            r(j)=(real(ix1,b8)+real(ix2,b8)*rm2)*rm1  
            return  
         end function ran1  
end module

program test
    use galapagos
    use sort_mod
    use my_collective
    use mpi
    use uname
    use ran_mod
    implicit none
    integer jin  
    integer ix1,ix2,ix3  
    real(b8) r(97),rm1,rm2  
    integer :: crate 
    integer , dimension(0:4) :: scount,ecount
    real(b8) , dimension(0:4) :: rclock
    real x
    logical :: do_rite
    integer i,j,k,m,di,k1,k2,myseed,gsize,ithread
    integer OMP_GET_MAX_THREADS,OMP_GET_THREAD_NUM
    integer, allocatable :: kstart(:),kend(:)
    type(thefit),allocatable :: data(:),output1(:),output2(:),output(:)
    integer t(2),b(2),d(2),MPI_SORT
    character (len=MPI_MAX_PROCESSOR_NAME):: myname
    integer mylen
    call MPI_INIT( ierr )
    call MPI_COMM_RANK( MPI_COMM_WORLD, myid, ierr )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, ierr )
    call MPI_Get_processor_name(myname,mylen,ierr)
    write(*,*)myid,"running on",trim(myname)
    do_rite=.true.
    scount=0;ecount=0;
    my_root=0
    myseed=12345
    call doseed(myseed)
    open(16,file=unique("out"))
    if(do_rite)then
    write(unit=*,fmt=*)"OMP_GET_MAX_THREADS=",OMP_GET_MAX_THREADS()
    endif

    b(1)=1;b(2)=2
    d(1)=0;d(2)=4
    t(1)=MPI_REAL;t(2)=MPI_INTEGER
    call MPI_TYPE_STRUCT(2,b,d,t,MPI_SORT,ierr)
    call MPI_TYPE_COMMIT(MPI_SORT,ierr)
    if(myid .eq. my_root)then
        i=6402
        do_rite=.true.
!        read(*,*)i,do_rite
    endif
    call MPI_Bcast(i,1,MPI_INTEGER,0,MPI_COMM_WORLD,ierr)
    call MPI_Bcast(do_rite,1,MPI_LOGICAL,0,MPI_COMM_WORLD,ierr)
    gsize=i*numnodes
    if(myid .eq. my_root)then
        allocate(output(gsize))
        if(do_rite)then
        write(16,*)"starting list"
        endif
        do j=1,gsize
            call random_number(output(j)%val)
            output(j)%index=j
        enddo
    endif
    call MPI_Barrier(MPI_COMM_WORLD,ierr)
    call system_clock(scount(0))
    call system_clock(scount(1))
    allocate(data(i))
    call MPI_Scatter(output,i,MPI_SORT, &
                     data,  i,MPI_SORT, &
                     my_root,MPI_COMM_WORLD,ierr)
    call system_clock(ecount(1))
    if(do_rite)then
    write(16,*)"i hold:"
    endif
    do j=1,i
        data(j)%proc=myid
        if(do_rite)then
        write(16,'(f10.8,1x,i5,i5)')data(j)%val, &
                                    data(j)%proc,&
                                    data(j)%index
        endif
    enddo
    m=4
    di=(i/m)-1
    allocate(kstart(m),kend(m))
    kstart(1)=1
    kend(1)=di+1
    do j=2,m
        kstart(j)=kend(j-1)+1
        kend(j)=kstart(j)+di
    enddo
    kend(m)=i
    if(do_rite)then
    write(16,"(8i5)")kstart
    write(16,"(8i5)")kend
    endif
    call system_clock(scount(2))
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
    call system_clock(ecount(2))
    if(do_rite)then
    do k=1,m
        write(16,*)"sorted section ",k
        do j=kstart(k),kend(k)
            write(16,'(f10.8,1x,i5)')data(j)%val,data(j)%index
        enddo
    enddo
    endif
!$OMP PARALLEL SECTIONS
!$OMP SECTION
    call system_clock(scount(3))
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
    call system_clock(ecount(3))
    if(do_rite)then
    write(16,*)"merged single processor sorted list "
    do j=1,i
        write(16,'(f10.8,1x,i5)')data(j)%val,data(j)%index
    enddo
    endif
    m=0
    call system_clock(scount(4))
    call MY_MERGE(data,i,output,m,my_root,1234,MPI_COMM_WORLD,MPI_SORT)
    call system_clock(ecount(4))
    if(do_rite)then
    if(myid .eq. my_root)then
        write(16,*)"merged list from all processors"
        do j=1,m
            write(16,'(f10.8,1x,i5,i5)')output(j)%val,output(j)%proc,output(j)%index
        enddo
    endif
    endif
    call system_clock(ecount(0))
    call system_clock(count_rate=crate)
    rclock=ecount-scount
    rclock=rclock/real(crate,b8)
    write(unit=16,fmt="(""tpoints="",i10,"" nodes="",i3,1x)",advance="no")i*numnodes,numnodes
    write(unit=16,fmt="(""times="",5f8.5)")rclock
    call MPI_FINALIZE(ierr)
    
end program
