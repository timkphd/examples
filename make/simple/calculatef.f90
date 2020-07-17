!*********************
subroutine bc(psi,i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
    use numz
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    psi(i1-1,:)=0.0_b8
    psi(i2+1,:)=0.0_b8
    psi(:,j1-1)=0.0_b8
    psi(:,j2+1)=0.0_b8
end subroutine bc
!*********************
subroutine do_jacobi(psi,new_psi,diff,i1,i2,j1,j2)
! does a single Jacobi iteration step
! input is the grid and the indices for the interior cells
! new_psi is temp storage for the the updated grid
! output is the updated grid in psi and diff which is
! the sum of the differences between the old and new grids
    use numz
    use constants
    implicit none
    integer,intent(in) :: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: new_psi
    real(b8) diff
    integer i,j
    real(b8) y
    diff=0.0_b8
    do j=j1,j2
        do i=i1,i2
!            y=j*dy
            new_psi(i,j)=a1*psi(i+1,j) + a2*psi(i-1,j) + &
                         a3*psi(i,j+1) + a4*psi(i,j-1) - &
                         a5*for(i,j)
!                         a5*force(y)
            diff=diff+abs(new_psi(i,j)-psi(i,j))
         enddo
     enddo
    psi(i1:i2,j1:j2)=new_psi(i1:i2,j1:j2)
end subroutine do_jacobi
!*********************
function force(y)
    use numz
    use input
    use constants
    implicit none
    real(b8) force,y
    force=-alpha*sin(y*a6)
end function force
!*********************
subroutine do_force (i1,i2,j1,j2)
! sets the force conditions
! input is the grid and the indices for the interior cells
    use numz
    use constants, only:for,dy
    use face, only : force
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8) y
    integer i,j
    do i=i1,i2
        do j=j1,j2
            y=j*dy
            for(i,j)=force(y)
        enddo
    enddo
end subroutine