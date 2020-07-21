!version: serial with no mpi
! solves the 2d Stommel Model of Ocean Circulation  
! using a Five-point stencil and Jacobi iteration
!
! gamma*((d(d(psi)/dx)/dx) + (d(d(psi)/dy)/dy))
! +beta(d(psi)/dx)=-alpha*sin(pi*y/(2*ly))
!
module numz
! module defines the basic real type and pi
    integer, parameter:: b8 = selected_real_kind(14)
    real(b8), parameter :: pi = 3.141592653589793239_b8
end module
!*********************
module input
! module contains the inputs 
    use numz
    integer nx,ny             ! number of interior points for our grid (50 50)
    real(b8) lx,ly            ! physical size of our grid (2000 2000)
    real(b8) alpha,beta,gamma ! parameters of the calculation (1.0e-9 2.25e-11 3.0e-6)
    integer steps             ! number of Jacobi iteration steps (60)
end module
!*********************
module constants
! this module contains the invariants (constants) of the
! calculation.  these values are determined in the main
! routine and used in the do_jacobi Jacobi iteration subroutine
! a6 is used in the force function
    use numz
    real(b8) dx,dy,a1,a2,a3,a4,a5,a6
    real(b8), allocatable:: for(:,:)     ! our force grid
end module
!*********************
module face
! this module contains the interface for the two subroutines
! that modify the grid.  an interface is a good idea in this
! case because we are passing allocatable arrays
    interface bc
        subroutine bc (psi,i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1:i2,j1:j2):: psi
        end subroutine
    end interface
    interface do_jacobi
        subroutine do_jacobi (psi,new_psi,diff,i1,i2,j1,j2)
! does a single Jacobi iteration step
! input is the grid and the indices for the interior cells
! new_psi is temp storage for the the updated grid
! output is the updated grid in psi and diff which is
! the sum of the differences between the old and new grids
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
            real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: new_psi
            real(b8) diff
        end subroutine
    end interface
! interface for the forcing function
    interface force
        function force(y)
            use numz
            real(b8) force,y
        end function force
    end interface   
    interface do_force
        subroutine do_force (i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
        end subroutine
    end interface
! interface for routine to write the grid
    interface write_grid
        subroutine write_grid (psi,i1,i2,j1,j2)
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1:i2,j1:j2):: psi
        end subroutine
    end interface
end module