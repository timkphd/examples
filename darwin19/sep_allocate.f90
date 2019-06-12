module splay_stuff
 !   integer, parameter :: bs=4
    integer :: bs
    logical dowrite
	type abc
!		integer high,low
		integer,allocatable ::  bytes(:)
	end type abc
	interface operator(<=)
        module procedure less_equal
    end interface
	interface operator(==)
        module procedure equal
    end interface
	interface operator(/=)
        module procedure not_eql
    end interface
    contains
    function equal(first,second)
    	logical equal
        type(abc), intent(in):: first,second
        equal=.true.
        do i=1,bs
          if (first%bytes(i) .ne. second%bytes(i))then
           	equal=.false.
           	return
           endif
        enddo
   end function equal
    
    function not_eql(first,second)
    	logical not_eql
        type(abc), intent(in):: first,second
        not_eql=.false.
        do i=1,bs
          if (first%bytes(i) .ne. second%bytes(i))then
           	not_eql=.true.
           	return
           endif
        enddo
    end function not_eql
    

	function less_equal(first,second)
		implicit none
		logical less_equal
        type(abc), intent(in):: first,second
! work on values one word at a time 
! as integers
! high order bits first       
        integer f0,f1,f2,f3
        integer w0,w1,w2,w3
        integer f(bs),s(bs)
        integer iword,jbits,bstart
        
        f=first%bytes
        s=second%bytes
        do iword=1,bs
				f3=f(iword)
				w3=s(iword)
				if(f3 .lt. w3)then
					less_equal=.true.
				return
				elseif(f3 .gt. w3)then
					less_equal=.false.
					return
				endif
        enddo
		less_equal=.true.        
    end function less_equal
end module

module tree_data
	use splay_stuff
	type tree
		type(abc) :: key
		real :: item
		type(tree), pointer :: parent, left, right
	end type tree
end module tree_data

module mytime
	use numz
contains
function gtime()
     real(b8) gtime
    integer count,cr,cm
    call SYSTEM_CLOCK(count,cr,cm)
    gtime=real(count,b8)/real(cr,b8)
end function gtime
end module mytime

module tree_junk
	interface
		subroutine insert(key, item, root)
			use tree_data
			real, intent(in) :: item
			type(abc),intent(in):: key
			type(tree),  pointer :: root
		end subroutine insert
		subroutine splay (p)
			use tree_data
			type(tree), pointer :: p
		end subroutine splay
!		subroutine deletemin (root,  item)
		subroutine deletemin (root)
			use tree_data
			type(tree), pointer :: root
!			integer, intent (inout) :: item
!			type(abc), intent (inout) :: item
		end subroutine deletemin
		recursive subroutine inorder (root)
			use tree_data
			type(tree), pointer :: root
		end subroutine inorder
		subroutine inorder2(root)
			use tree_data
			type(tree), pointer :: root
		end subroutine inorder2
		subroutine findval(root,rjk,path)
			use tree_data
			type(tree), pointer :: root
			real rjk
			type(abc) :: path
		end subroutine findval
		recursive function rf (root)  result (count)
			use tree_data
			type(tree), pointer :: root
			integer count
		end function rf
		function find (key,root)
			use tree_data
			type(tree), pointer :: root
			type(abc),  intent(in) :: key
			logical find
		end function find
		subroutine delete (root,  item)
			use tree_data
			type(tree), pointer :: root
			type(abc), intent (inout) :: item
		end subroutine delete
		recursive subroutine wipe(root)
			use tree_data
			type(tree), pointer :: root
		end subroutine wipe
	end interface
end module tree_junk


!subroutine deletemin (root,  xtem)
subroutine deletemin (root)
	use tree_data
	use tree_junk, only : splay
	implicit none
	type(tree), pointer :: root
!	integer, intent (inout) :: xtem
!	type(abc), intent (inout) :: xtem
	type(tree), pointer :: p

		IF (.not. associated(root)) THEN
!			item = -1
		ELSE
! desired item is leftmost  find it
			p => root
			DO WHILE (associated(p%left))
				p => p%left
			ENDDO
!			xtem = p%item
! then splay it
			call splay(p)
! the resulting tree has no left subtree, so easy to delete the root
			root => p%right
			deallocate(p%key%bytes)
			deallocate(p)
			nullify(p)
			IF (associated(root)) &
				nullify(root%parent)
		ENDIF
END subroutine deletemin

subroutine insert (key, item, root)
	use tree_data
	use tree_junk, only : splay
	implicit none
	real, intent(in) :: item
	type(abc),intent(in):: key
	type(tree),  pointer :: root
	type(tree), pointer :: p, current, next
		allocate(p)
		allocate(p%key%bytes(bs))
		nullify(p%left)
		nullify(p%right)
		nullify(p%parent)
		p%key%bytes = key%bytes
		p%item = item
		IF (.not. associated(root)) THEN
				root => p
		ELSE
! run standard binary search to find where to insert the new node
				next => root
				DO
					current => next
					IF (key .le. current%key) THEN
						next => current%left
!						IF(associated(next))THEN
!							write(*,*)'next is left:  ',next%key
!						ELSE
!							write(*,*)'next is nil'
!						ENDIF
					ELSE
						next => current%right
!						IF(associated(next))THEN
!							write(*,*)'next is right:  ',next%key
!						ELSE
!							write(*,*)'next is nil'
!						ENDIF
					ENDIF
					IF(.not. associated(next)) &
						EXIT
				ENDDO
				p%parent => current
				IF (key .le. current%key) THEN
					current%left => p
				ELSE
					current%right => p
				ENDIF
! now splay the new node
				call splay(p)
				root => p
		ENDIF
END subroutine insert

!########
function find (key,root)
	use tree_data
	use tree_junk, only : splay
	implicit none
	type(tree), pointer :: root
	type(abc),  intent(in) :: key
	logical find
	type(tree), pointer :: current, next
! run standard binary search to find the node
		if(.not. associated(root))then
		    find=.false.
		    return
		endif
		next => root
		DO
			current => next
!			write(*,*)key ,current%key
			IF (key .ne. current%key) THEN
					IF (key .le. current%key) THEN
						    next => current%left
!						    write(*,*)"going left"
					ELSE
						    next => current%right
!						    write(*,*)"going right"
					ENDIF
			ENDIF
			IF((.not. associated(next )) .or. (key .eq. current%key)) &
				EXIT
		ENDDO
		IF (.not. associated(next) )THEN
			find=.false.
			call splay(current)
			root=>current
		ELSE
! now splay the new node
			call splay(current)
			root => current
			find=.true.
		ENDIF
END function find


subroutine splay (p)
	use tree_data
	type(tree), pointer :: p
	type(tree), pointer :: parent, grand
	DO WHILE(associated(p%parent))
		parent => p%parent
		IF (associated (parent%left , p ))THEN 
			IF (.not.associated(parent%parent)) THEN
				nullify(p%parent)
				parent%parent => p
				parent%left => p%right
				IF (associated (parent%left)) &
					parent%left%parent=>parent
				p%right => parent
			ELSE
				grand => parent%parent
				p%parent => grand%parent
				IF (associated(grand%parent)) THEN
					IF (associated(grand%parent%left , grand)) THEN
						grand%parent%left => p
					ELSE
						grand%parent%right => p
					ENDIF
				ENDIF
				parent%parent => p
				parent%left => p%right
				IF (associated(parent%left)) &
					parent%left%parent => parent
				p%right => parent
				IF (associated(grand%left , parent)) THEN
					grand%parent => parent
					grand%left => parent%right
					IF (associated(grand%left)) &
						grand%left%parent => grand
					parent%right => grand
				ELSE
					grand%parent => p
					grand%right => p%left
					IF (associated(grand%right)) &
						grand%right%parent => grand
					p%left => grand
				ENDIF
			ENDIF
		ELSE 
			IF (.not. associated(parent%parent)) THEN
				nullify(p%parent)
				parent%parent => p
				parent%right => p%left
				IF (associated(parent%right)) &
					parent%right%parent => parent 
				p%left => parent
			ELSE
				grand => parent%parent
				p%parent => grand%parent
				IF (associated(grand%parent)) THEN
					IF (associated(grand%parent%left , grand)) THEN
						grand%parent%left => p
					ELSE
						grand%parent%right => p
					ENDIF
				ENDIF
				parent%parent => p
				parent%right => p%left
				IF (associated(parent%right)) &
					parent%right%parent => parent 
				p%left => parent
				IF (associated(grand%right , parent)) THEN
					grand%parent => parent
					grand%right => parent%left
					IF (associated(grand%right)) &
						grand%right%parent => grand 
					parent%left => grand
				ELSE
					grand%parent => p
					grand%left => p%right
					IF (associated(grand%left)) &
						grand%left%parent => grand 
					p%right => grand
				ENDIF
			ENDIF
		ENDIF
	ENDDO
END subroutine splay

recursive subroutine inorder (root)
!	use numz
	use tree_data
	type(tree), pointer :: root
		IF(associated(root))THEN
!			write(*,*)"left"
			call inorder(root%left)
			if(dowrite)write(*,"(f20.8/(16i3))")root%item,root%key%bytes(:)
!			write(*,*)"right"
			call inorder(root%right)
!			write(*,*)"up"
		ENDIF
end subroutine inorder

subroutine inorder2(root)
! http://www.geeksforgeeks.org/inorder-tree-traversal-without-recursion/
! http://www.geeksforgeeks.org/inorder-tree-traversal-without-recursion-and-without-stack/
  use tree_data
  type(tree), pointer :: root
  type(tree), pointer :: current,pre
  if(.not.(associated(root)))then
     return
  endif
  current => root
do while(associated(current))                 
    if(.not. associated(current%left) )then
       if(dowrite)write(*,"(f20.8/(16i3))")current%item,current%key%bytes
      current => current%right 
    else 
!      /* Find the inorder predecessor of current */
      pre => current%left
     do while(associated(pre%right) .and.  (.not. associated(pre%right,current)))
        pre => pre%right
     end do
!      /* Make current as right child of its inorder predecessor */
      if(.not.(associated(pre%right)))then
        pre%right => current
        current => current%left
!      /* Revert the changes made in if part to restore the original 
!        tree i.e., fix the right child of predecssor */   
      else
!        if(allocated(pre%right%key%bytes))deallocate(pre%right%key%bytes)
		nullify(pre%right)
        if(dowrite)write(*,"(f20.8/(16i3))")current%item,current%key%bytes
        current => current%right      
! /* End of if condition pre->right == NULL */
      end if 
! /* End of if condition current%left == NULL*/
     end if
! /* End of while */
  end do
end subroutine inorder2

subroutine findval(root,rjk,path)
! http://www.geeksforgeeks.org/inorder-tree-traversal-without-recursion/
! http://www.geeksforgeeks.org/inorder-tree-traversal-without-recursion-and-without-stack/
  use tree_data
  real rjk
  real :: tol=1.0d-6
  type(tree), pointer :: root
  type(tree), pointer :: current,pre
  type(abc) :: path
  if(.not.(associated(root)))then
     return
  endif
  current => root
do while(associated(current))                 
    if(.not. associated(current%left) )then
!      if(rjk .eq.current%item)then
       if(abs(rjk-current%item) .lt. tol)then
       path%bytes=current%key%bytes
       endif
      current => current%right 
    else 
!      /* Find the inorder predecessor of current */
      pre => current%left
     do while(associated(pre%right) .and.  (.not. associated(pre%right,current)))
        pre => pre%right
     end do
!      /* Make current as right child of its inorder predecessor */
      if(.not.(associated(pre%right)))then
        pre%right => current
        current => current%left
!      /* Revert the changes made in if part to restore the original 
!        tree i.e., fix the right child of predecssor */   
      else
!        if(allocated(pre%right%key%bytes))deallocate(pre%right%key%bytes)
        nullify(pre%right)
!      if(rjk .eq.current%item)then
       if(abs(rjk-current%item) .lt. tol)then
       path%bytes=current%key%bytes
       endif
        current => current%right      
! /* End of if condition pre->right == NULL */
      end if 
! /* End of if condition current%left == NULL*/
     end if
! /* End of while */
  end do
end subroutine findval




subroutine delete (root,  key)
!	use numz
	use tree_data
	use tree_junk, only : splay,find,deletemin,inorder
	implicit none
	type(tree), pointer :: root
	type(abc), intent (inout) :: key
	type(tree), pointer :: left,rite,temp
	logical exists
	exists=find(key,root)
	if(.not. exists)then
	    write(*,*)'does not exist'
	    return
	endif
	if(.not. associated(root%left))then
	    if(.not. associated(root%right))then
	    	if(allocated(root%key%bytes))deallocate(root%key%bytes)
	    	deallocate(root)
	        nullify(root)
	        write(*,*)'empty tree'
	        return
	    endif
!	    call deletemin(root,key)
	    call deletemin(root)
	    return
	endif
	if(.not. associated(root%right))then
		temp=>root%left
		if(allocated(root%key%bytes))deallocate(root%key%bytes)
		deallocate(root)
		nullify(root)
		root=>temp
		if(allocated(root%parent%key%bytes))deallocate(root%parent%key%bytes)
		nullify(root%parent)
	    return
	endif
	left=>root%left
	rite=>root%right
	if(allocated(root%key%bytes))deallocate(root%key%bytes)
	deallocate(root)
	nullify(root)
	if(allocated(left%parent%key%bytes))deallocate(left%parent%key%bytes)
	if(allocated(rite%parent%key%bytes))deallocate(rite%parent%key%bytes)
	nullify(left%parent)
	nullify(rite%parent)
	root=>left
	exists=find(key,root)
!	write(*,*)"left"
!	call inorder(left)
!	write(*,*)"rite"
!	call inorder(rite)
!	write(*,*)'root item ',root%item,'  root key ',root%key
!	write(*,*)associated(root%left),associated(root%right)
!	write(*,*)'rite item ',rite%item,'  rite key ',rite%key
!	write(*,*)associated(rite%left),associated(rite%right)
	rite%parent=>root
	root%right=>rite
END subroutine delete

recursive function rf (root) result(count)
	use tree_data
	type(tree), pointer :: root
	integer count
	count=0
	if(associated(root))then
		count=1+ rf(root%right) +  rf(root%left)
	endif
end function rf

recursive subroutine lf (root)
!	use numz
	use tree_data
	type(tree), pointer :: root
	    write(*,*)root%item,root%key%bytes
		IF(associated(root%left))then
			call lf(root%left)
		else
			write(*,*)"leaf"
		endif
		IF(associated(root%right))then
			call lf(root%right)
		else
			write(*,*)"leaf"
		endif
end subroutine lf

module splayvars
        use tree_data
        use tree_junk
		use mytime
        integer, parameter:: i8 = selected_int_kind(14)
        integer mysize,bits
        real(b8) st1,st2
        real aran
        real rjk
        type(tree), pointer :: root
!        integer :: i,command,j
        integer :: i,command
        type(abc) :: key,path
        logical exists
end module



!warning the random number generater has a period of 1024 calls
integer function iran(iseed)
        integer, intent(in), optional :: iseed
        integer bonk(1)
        save jseed

!        if(present(iseed)) &
!                jseed=iseed
!        jseed=mod((jseed*9+5),1024)
        iran=jseed
		if(present(iseed)) &
		    bonk=iseed
!        call RANDOM_SEED(bonk)
        call RANDOM_NUMBER(x)
        iran=4*x
END function iran



recursive subroutine wipe(root)
	use tree_data
	implicit none
	type(tree), pointer :: root
		if(allocated(root%key%bytes))deallocate(root%key%bytes)
		if(associated(root%left))call wipe(root%left)
		if(associated(root%right))call wipe(root%right)
		deallocate(root)
		nullify(root)
end subroutine wipe
