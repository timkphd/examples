module mods
     integer dummy
end module
! this module contains information general to all 
! GA problems.  the data in this module is independent
! of the particular function we are trying to optimize
module galapagos
    use numz
    type thefit
      sequence
      real(b8) val
      integer index,proc,to,buff
    end type thefit

    real(b8)  invert_rate,mut_rate, quit_value, hawk
    real(b8), allocatable :: mute_rate_vect(:)
    real(b8), allocatable :: hawk_rate_vect(:)

    integer   pop_size, generations,gene_size,seed,local_pop
    integer   shift_rate, shift_num, global_rate,stagnate
    integer   printing, hawk_rate, hand_out
    integer, allocatable :: best(:),gene(:,:),kids(:,:),save_flags(:)
    type(thefit),allocatable :: fit(:),fit2(:)
    logical the_top,do_one
    real(b8) :: maxtime,rtime1,rtime2

    namelist /darwin_dat/ &
              pop_size, generations,stagnate ,gene_size, seed,&
              invert_rate,mut_rate, quit_value,  &
              shift_rate, shift_num, global_rate,&
              printing, hawk_rate,hand_out,the_top,do_one, &
              maxtime
    real(b8) rpar1,rpar2,rpar3,rpar4
    integer  ipar1,ipar2,ipar3,ipar4
    integer  :: max_gene=4
end module

module counts
    integer :: reused=0
    integer :: newone=0
    integer :: mygen
end module 

! interfaces for the various routines used by the main program
! some of these routines are problem specific but the interfaces 
! are genaric
module problem
   use numz

            ! Declare the interface for POSIX fsync function
            interface
              function fsync (fd) bind(c,name="fsync")
              use iso_c_binding, only: c_int
                integer(c_int), value :: fd
                integer(c_int) :: fsync
              end function fsync
            end interface

! cpu timer interface
  interface timer
    subroutine timer(sec)
    use numz
    real(b8), intent(inout) :: sec
    end subroutine timer
  end interface

! read the data given a file name
  interface desctiption
    subroutine description(fname,err)
	character (*) , intent(in) :: fname
	integer , intent(inout) :: err
	end subroutine description
  end interface

! print the data
  interface printit
    subroutine printit()
    end subroutine printit
  end interface

! do the init for a single gene
  interface init_gene
    subroutine init_gene(vector)
    use numz
	integer, dimension(:) , intent(inout) :: vector
    end subroutine init_gene
  end interface

! send the data to all processors
  interface broadcast 
    subroutine broadcast(k)
	integer  , intent(in) :: k
	end subroutine broadcast
  end interface

! return the value of the fitness function
! given an integer vector of some length
  interface fitness
    function fitness(vector)
    use numz
	integer, dimension(:) , target ,intent(in) :: vector
	real(b8) fitness
	end function fitness
  end interface
  interface results 
   subroutine results(vector)
	integer, dimension(:) , intent(in) :: vector
   end subroutine results
  end interface

! prints more detailed fitness function information  
! given an integer vector of some length
  interface output
    subroutine output(vector)
    use numz
	integer, dimension(:) , intent(in) :: vector
	end subroutine output
  end interface

end module problem

! interface for the parallel merge/sort routine
module my_collective

    interface MY_MERGE
        subroutine MY_MERGE(input,n,output,m,root,THETAG,THECOM,MPI_FIT)
            use galapagos
!            use ran_mod
            type(thefit), intent(inout) :: input(n)
            integer, intent(in) :: n
            type(thefit), intent (inout):: output(*)
            integer, intent (inout):: m
            integer, intent(in) :: root
            integer THETAG,THECOM,MPI_FIT
        end subroutine
    end interface

    interface myall2allv
        subroutine myall2allv(sendbuf,sendcounts,sdispls,&
                              recvbuf,recvcounts,rdispls,&
                              comm,ierr)
            integer sendbuf(*),recvbuf(*)
            integer sendcounts(0:*),sdispls(0:*),recvcounts(0:*),rdispls(0:*)
            integer comm,ierr
        end subroutine
    end interface

end module

    
module ran_mod
 contains 
    function ran1(idum)
! returns a uniform random number between 0 and 1
! see numerical recipes
! press,flannery,teukolsky & vetterling
! cambridge university press 1986 pp 191-2-3
    use numz
    implicit none
    real(b8)  RAN1, R, RM1, RM2
    integer, intent(inout), optional :: idum
    integer  iff, ix1, ix2, ix3, j
    dimension r(97)
        save
        integer, parameter :: m1=259200,ia1=7141,ic1=54773
        integer, parameter :: m2=134456,ia2=8121,ic2=28411
        integer, parameter :: m3=243000,ia3=4561,ic3=51349
        data iff /0/
    if(present(idum))then
    if (idum<0.or.iff.eq.0)then
        rm1=1.0_b8/m1
        rm2=1.0_b8/m2
        iff=1
        ix1=mod(ic1-idum,m1)
        ix1=mod(ia1*ix1+ic1,m1)
        ix2=mod(ix1,m2)
        ix1=mod(ia1*ix1+ic1,m1)
        ix3=mod(ix1,m3)
        do 11 j=1,97
        ix1=mod(ia1*ix1+ic1,m1)
        ix2=mod(ia2*ix2+ic2,m2)
        r(j)=(float(ix1)+float(ix2)*rm2)*rm1
 11         continue
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
    r(j)=(float(ix1)+float(ix2)*rm2)*rm1
    return
    end function ran1
    
	function gasdev()
		use numz
!		interface ran1
!			function ran1(idum)
!				use numz
!			    integer, intent(inout), optional :: idum
!			    real(b8) ran1
!			end function ran1
!		end interface
		implicit none
		real(b8) gasdev
		integer iset 
		real(b8) fac,gset,rsq,v1,v2
		save iset,gset
		data iset/0/ 
		if (iset.eq.0) then 
	 1		v1=2.*ran1()-1. 
			v2=2.*ran1()-1. 
			rsq=v1**2+v2**2
			if(rsq.ge.1..or.rsq.eq.0.)goto 1 
			fac=sqrt(-2.*log(rsq)/rsq) 
			gset=v1*fac
			gasdev=v2*fac 
			iset=1 
		else 
			gasdev=gset 
			iset=0 
		endif 
		return 
	end function gasdev
	
	function norml(mean,sigma)
		use numz
		implicit none
		real(b8) norml
	    real(b8) mean,sigma
		norml = gasdev() * sigma + mean
	end function norml

	function spread(min,max)
		use numz
		implicit none
		real(b8) spread
		real(b8) min,max
		spread=(max - min) * ran1() + min
	end function spread

end module ran_mod

! pick_to, in this module, is the routine
! which determines which processor is sent to
! when we do a global exchange.  we initialize
! the routine by telling the routine how many
! nodes we are using and the number we are sending
! to each node
! the routine by 
module pick_mod
 contains 
    function pick_to(numnodes,j_each)
    use numz
    use ran_mod
    implicit real(b8) (a-h,o-z)
    integer pick_to
    integer, intent(in), optional :: numnodes,j_each
    integer, allocatable :: tovect(:)
    real(b8), allocatable :: pvect(:)
    integer i,j,r(1),n
    save
    if(present(numnodes))then
        n=numnodes
        if(allocated(tovect))then
            deallocate(tovect)
            deallocate(pvect)
        endif
        allocate(tovect(n),pvect(n))
        tovect=j_each
        pick_to=-1
        return
    endif
    do i=1,n
        pvect(i)=ran1()*tovect(i)
    enddo
    r=maxloc(pvect)
    tovect(r(1))=tovect(r(1))-1
    j=r(1)-1
    pick_to=j
    return
    end function pick_to
end module pick_mod



! these values are used by the merge sort routine 
! given below in sort_mod
module Merge_mod_types
    use galapagos
    type(thefit),allocatable :: work(:)
    type(thefit), pointer:: a(:)
end module Merge_mod_types

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
    implicit none 
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
    implicit none 
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
    implicit none 
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
    implicit none 
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
    implicit none 
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
    implicit none 
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






! MY_MERGE a global merge routine
! MY_MERGE takes as input a sorted list of values from each
! processor
! it outputs on the root a sorted list of values which is a 
! merged list from each processor
! when a processor recieves a list from another processor it 
! merges its list with the new one before sending the list on
! this routine is a fortran 90 implimentation of the gather
! routine given in class on Feb 9 with the added merge step
subroutine MY_MERGE(input,n,output,m,root,THETAG,THECOM,MPI_FIT)
  use galapagos
!  use ran_mod
  use mympi
  implicit none
  interface merge2
    subroutine merge2(d1,n,d2,m,out)
    use galapagos
    integer n,m
    type(thefit), intent (in):: d1(n),d2(m)
    type(thefit), intent (out):: out(n+m)
    end subroutine
  end interface

  integer, intent(in) :: n
  type(thefit), intent(inout) :: input(n)
  type(thefit), intent (inout):: output(*)
  integer, intent (inout):: m
  integer, intent(in) :: root
  integer THETAG,THECOM,MPI_FIT,NTAG

  type(thefit) , allocatable:: rec(:),temp(:),temp2(:)
  type(thefit) , allocatable :: data(:)
  integer p,active,rank,ierr,count,i,ijk
  integer status(MPI_STATUS_SIZE)


  call MPI_COMM_RANK( THECOM, rank, ierr )
  call MPI_COMM_SIZE( THECOM, p, ierr )
  !write(*,*)"my_merge",rank,p,THETAG,THECOM,MPI_FIT
  write(*,*)"my_merge",rank,p
  NTAG=(THETAG+1)
  do ijk=1,n
     if(input(ijk)%proc .ne. rank)&
         write(*,*)'error in sort ',input(ijk)%proc,rank
  enddo
  active=1
  do while (2*active < p)
    active=active*2
  enddo
  if(rank .ge. active)then
! send(input,rank-active)
!  write(*,*)'send at 1 ',n,' to ',rank-active
  call MPI_SEND(n,1,MPI_INTEGER,rank-active,NTAG,&
       THECOM,ierr)
  call MPI_SEND(input,n,MPI_FIT,rank-active,THETAG,&
       THECOM,ierr)
	return
  endif
  allocate(data(n))
  data=input
  m=n
  if(rank + active  < p)then
! rec(new_data,rank+active)
!    call MPI_PROBE(rank+active,THETAG,THECOM,status,ierr)
!    call MPI_get_count(status,MPI_FIT,count,ierr)
    call MPI_RECV(count,1,MPI_INTEGER,rank+active,NTAG,&
           THECOM,status,ierr)    
    allocate(rec(count))
!    write(*,*)'rec at 1 ',count
    call MPI_RECV(rec,count,MPI_FIT,rank+active,THETAG,&
           THECOM,status,ierr)
    do ijk=1,count
     if((rec(ijk)%proc > p ) .or. (rec(ijk)%proc < 0 ))&
         write(*,*)'error in sort at 2 ',rec(ijk)%proc
    enddo

! data=data+new_data
    allocate(temp(n+count))
    !write(*,*)"merge2-1a",rank
    call merge2(input,n,rec,count,temp)
    !write(*,*)"merge2-1b",rank
    if(allocated(data))deallocate(data)
    allocate(data(n+count))
    data=temp
    m=n+count
  endif
  do while (active > 1)
    active=active/2
    if(rank .ge. active) then
! send(data,rank-active)
  call MPI_SEND(m,1,MPI_INTEGER,rank-active,NTAG,&
       THECOM,ierr)
  call MPI_SEND(data,m,MPI_FIT,rank-active,THETAG,&
       THECOM,ierr)
    if(allocated(data))deallocate(data)
    if(allocated(rec))deallocate(rec)
    if(allocated(temp))deallocate(temp)
    if(allocated(temp2))deallocate(temp2)
    return
    else
! recv(new_data,rank+active)
!    call MPI_PROBE(rank+active,THETAG,THECOM,status,ierr)
!    call MPI_get_count(status,MPI_FIT,count,ierr)
    call MPI_RECV(count,1,MPI_INTEGER,rank+active,NTAG,&
           THECOM,status,ierr)
    if(allocated(rec))deallocate(rec)
    allocate(rec(count))
    call MPI_RECV(rec,count,MPI_FIT,rank+active,THETAG,&
           THECOM,status,ierr)
    do ijk=1,count
     if((rec(ijk)%proc > p ) .or. (rec(ijk)%proc < 0 ))&
         write(*,*)'error in sort at 3 ',rec(ijk)%proc
    enddo

! data=data+new_data
    if(allocated(temp2))deallocate(temp2)
    allocate(temp2(m+count))
    write(*,*)"merge2-2a",rank
    call merge2(data,m,rec,count,temp2)
    write(*,*)"merge2-2b",rank
    deallocate(data);allocate(data(m+count))
    data=temp2
    m=m+count    
    endif
  enddo
  if(rank .eq. root)then
    do i=1,m
 if((data(i)%proc > p ) .or. (data(i)%proc < 0 ))&
         write(*,*)'error in sort at 4 ',i, data(i)%proc 
     output(i)=data(i)
 if((output(i)%proc > p ) .or. (output(i)%proc < 0 ))&
         write(*,*)'error in sort at 5 ',i, output(i)%proc 
    enddo
  endif
    if(allocated(data))deallocate(data)
    if(allocated(rec))deallocate(rec)
    if(allocated(temp))deallocate(temp)
    if(allocated(temp2))deallocate(temp2)
  return
  end

! this subroutine takes two sorted lists of type(thefit) and merges them
! input d1(n) , d2(m)
! output out(n+m)
subroutine merge2(d1,n,d2,m,out)
  use numz
  use galapagos
  use sort_mod
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
  end



subroutine timer(sec)
    use numz
    real(b8), intent (inout) :: sec
    real(b8) nanosec,MPI_Wtime
    !integer i,j
    !call wtime(i,j)
    !nanosec=j
    !sec=i
    !sec=sec+1.0e-9_b8*nanosec
    sec=MPI_Wtime()
    return
 end subroutine timer

module locate_mod
	contains 
		function locate(vect,x)
! given a sorted vector return i such that x(i) < x < x(i+1)
		    use numz
            use galapagos
		    implicit none
		    type(thefit), intent(inout) :: vect(:)
		    real(b8) x
		    integer locate
		    integer low,mid,high,n
		    n=ubound(vect,1)
		    low=0
		    high=n+1
       10   if(high-low .gt. 1)then
		        mid=(high+low)/2
		        if((vect(n)%val .gt. vect( 1)%val) .eqv. &
		           (x             .gt. vect(mid)%val))      then
		            low=mid
		        else
		            high=mid
		        endif
                goto 10
            endif
		    locate=low
		end function locate
end module





!module splay_stuff
!	type abc
!		integer high,low
!	end type abc
!	interface operator(<=)
!        module procedure less_equal
!    end interface
!	interface operator(==)
!        module procedure equal
!    end interface
!	interface operator(/=)
!        module procedure not_eql
!    end interface
!    contains
!    function equal(first,second)
!    	logical equal
!        type(abc), intent(in):: first,second
!        equal=((first%low .eq. second%low) .and. &
!              (first%high  .eq. second%high ))
!    end function equal
!    
!    function not_eql(first,second)
!    	logical not_eql
!        type(abc), intent(in):: first,second
!        not_eql=(first%low .ne. second%low) .or.  &
!                  (first%high  .ne. second%high )
!    end function not_eql
!    
!	function less_equal(first,second)
!		implicit none
!		logical less_equal
!        type(abc), intent(in):: first,second
!! work on values 16 bits at a time 
!! as 16 bit integers
!! high order bits first       
!        integer f0,f1,f2,f3
!        integer w0,w1,w2,w3
!        f3=ibits(first%high,16,16)
!        w3=ibits(second%high,16,16)
!        if(f3 .lt. w3)then
!        	less_equal=.true.
!        	return
!        elseif(f3 .gt. w3)then
!        	less_equal=.false.
!        	return
!        endif
!! f3 .eq. w3        	
!        f2=ibits(first%high,0,16)
!        w2=ibits(second%high,0,16)
!        if(f2 .lt. w2)then
!        	less_equal=.true.
!        	return
!        elseif(f2 .gt. w2)then
!        	less_equal=.false.
!        	return
!        endif
!! f2 .eq. w2        	
!        f1=ibits(first%low,16,16)
!        w1=ibits(second%low,16,16)
!        if(f1 .lt. w1)then
!        	less_equal=.true.
!        	return
!        elseif(f1 .gt. w1)then
!        	less_equal=.false.
!        	return
!        endif
!! f1 .eq. w1        	
!        f0=ibits(first%low,0,16)
!        w0=ibits(second%low,0,16)
!        if(f0 .lt. w0)then
!        	less_equal=.true.
!        	return
!        elseif(f0 .gt. w0)then
!        	less_equal=.false.
!        	return
!        endif
!! f0 .eq. w0        	
!		less_equal=.true.        
!    end function less_equal
!
!end module
!
!module tree_data
!	use splay_stuff
!	type tree
!		type(abc) :: key
!		integer :: item
!		type(tree), pointer :: parent, left, right
!	end type tree
!end module tree_data
!
!
!module tree_junk
!	interface
!		subroutine insert(key, item, root)
!			use tree_data
!			integer, intent(in) :: item
!			type(abc),intent(in):: key
!			type(tree),  pointer :: root
!		end subroutine insert
!		subroutine splay (p)
!			use tree_data
!			type(tree), pointer :: p
!		end subroutine splay
!		subroutine deletemin (root,  item)
!			use tree_data
!			type(tree), pointer :: root
!			type(abc), intent (inout) :: item
!		end subroutine deletemin
!		recursive subroutine inorder (root)
!			use tree_data
!			type(tree), pointer :: root
!		end subroutine inorder
!		recursive function rf (root)  result (count)
!			use tree_data
!			type(tree), pointer :: root
!			integer count
!		end function rf
!		function find (key,root)
!			use tree_data
!			type(tree), pointer :: root
!			type(abc),  intent(in) :: key
!			logical find
!		end function find
!		subroutine delete (root,  item)
!			use tree_data
!			type(tree), pointer :: root
!			type(abc), intent (inout) :: item
!		end subroutine delete
!		recursive subroutine wipe(root)
!			use tree_data
!			type(tree), pointer :: root
!		end subroutine wipe
!	end interface
!end module tree_junk
!
