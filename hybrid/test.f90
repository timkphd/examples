module numz
  integer, parameter :: b8=selected_real_kind(14)
end module
program stommel
    use numz
    implicit none
    real(b8), allocatable:: psi(:,:)         ! our calculation grid
    real(b8), allocatable:: new_psi(:,:)     ! temp grid
    real(b8) :: diff
    integer nx,ny,ierr,len,stat,i
    character (len=7) :: aline
! the subroutine get_command_argument is part of the Fortran 2003
! standard.  it is accepted by most Fortran compilers as an 
! extension.  here, it returns the first command line argument as
! a string "aline" if it is present.  if the program is not given
! any command line arguments then stat indicates an error.  
!
! if we have a command line argument then we read from it into the 
! integer ierr.  ierr is used to force one of our error conditions.
    call get_command_argument(1, aline, len, stat)
    if(stat .eq. 0)then
      read(aline,*)ierr
    else
      ierr=0
    endif
! set the grid size
    nx=300
    ny=300
! allocate the grid to size nx * ny plus the boundary cells
    allocate(psi(0:nx+1,0:ny+1))
    allocate(new_psi(0:nx+1,0:ny+1))
! set the values of the grid to 1
    psi=1.0
! psi(0,0) we set to zero so that we can force a
! divide by 0.0 later
    psi(0,0)=0.0
! do a jacobian iteration
    call do_jacobi(psi,new_psi,diff,1,nx,1,ny,ierr)
    write(*,"(f12.1)")diff
end program stommel
!*********************
subroutine do_jacobi(psi,new_psi,diff,i1,i2,j1,j2,ierr)
    use numz
    implicit none
    integer,intent(in) :: i1,i2,j1,j2,ierr
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: new_psi
    real(b8) diff
    real(b8), parameter:: a1=1.0,a2=1.0,a3=1.0,a4=1.0,a5=1.0
    integer i,j
    diff=0.0
    do j=j1,j2
        do i=i1,i2
            new_psi(i,j)=a1*psi(i+1,j) + a2*psi(i-1,j) + &
                         a3*psi(i,j+1) + a4*psi(i,j-1) - &
                         a5*(i+j)
            diff=diff+abs(new_psi(i,j)-psi(i,j))
         enddo
     enddo
! error 1 -- arithmetic error divide by zero 
     if(ierr .eq. 1)then
       psi(1,1)=1.0/psi(0,0)
       write(*,*)psi(0,0),psi(1,1)
     endif
! error 2 -- array access out of bounds
     if(ierr .eq. 2)then
       psi(30000,30000)=1.0
     endif
! error 3 -- arithmetic error value out of bounds.  we
!            do this inside of the subroutine asinerror
!            to show another level in our call tree.
     if(ierr .eq. 3)then
       call asinerror(3.0_b8)
     endif
     psi(i1:i2,j1:j2)=new_psi(i1:i2,j1:j2)
end subroutine do_jacobi
!*********************
subroutine asinerror(x)
    use numz
    implicit none
    real(b8) x,y
! error 3 -- arithmetic error value out of bounds
    y=asin(x)
    write(*,*)"asin(",x,") returned ",y
end subroutine

