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
            real(b8),dimension(i1:i2,j1:j2):: psi
            integer,intent(in):: i1,i2,j1,j2
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
            real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
            real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: new_psi
            real(b8) diff
            integer,intent(in):: i1,i2,j1,j2
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
            real(b8),dimension(i1:i2,j1:j2):: psi
            integer,intent(in):: i1,i2,j1,j2
        end subroutine
    end interface
end module
!*********************
program stommel
    use numz
    use input
    use constants
    use face
    implicit none
    real(b8)diff
    real(b8)dx2,dy2,bottom
    real(b8), allocatable:: psi(:,:)     ! our calculation grid
    real(b8), allocatable:: new_psi(:,:) ! temp storage for the grid
    integer i,j,i1,i2,j1,j2
    integer omp_get_max_threads
    real(b8) t1,t2,walltime
    integer n_thread,n_mpi
    integer iout
! get the input.  see above for typical values
    read(*,*)nx,ny
    read(*,*)lx,ly
    read(*,*)alpha,beta,gamma
    read(*,*)steps
    write(*,*)"threads=",omp_get_max_threads()
    n_thread=omp_get_max_threads()
    n_mpi=1
! allocate the grid to size nx * ny plus the boundary cells
    allocate(psi(0:nx+1,0:ny+1))
    allocate(new_psi(0:nx+1,0:ny+1))
    allocate(for(0:nx+1,0:ny+1))
! calculate the constants for the calculations
    dx=lx/(nx+1)
    dy=ly/(ny+1)
    dx2=dx*dx
    dy2=dy*dy
    bottom=2.0_b8*(dx2+dy2)
    a1=(dy2/bottom)+(beta*dx2*dy2)/(2.0_b8*gamma*dx*bottom)
    a2=(dy2/bottom)-(beta*dx2*dy2)/(2.0_b8*gamma*dx*bottom)
    a3=dx2/bottom
    a4=dx2/bottom
    a5=dx2*dy2/(gamma*bottom)
    a6=pi/(ly)
! set initial guess for the value of the grid
    psi=1.0_b8
! set the indices for the interior of the grid
    i1=1
    i2=nx
    j1=1
    j2=ny
! set boundary conditions
    call bc(psi,i1,i2,j1,j2)
! set the force array
    call do_force(i1,i2,j1,j2)
    new_psi=psi
! do the jacobian iterations
    iout=steps/100
    if(iout == 0)iout=1
    t1=walltime()
    do i=1,steps
        call do_jacobi(psi,new_psi,diff,i1,i2,j1,j2)
	if(mod(i,iout) .eq. 0)write(*,'(i6,1x,g20.10)')i,diff
    enddo
    t2=walltime()
    write(*,*)"run time =",t2-t1,n_mpi,n_thread
! write out the final grid
!    call write_grid(psi,i1,i2,j1,j2)
end program stommel
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
!$OMP PARALLEL
!$OMP DO SCHEDULE (STATIC) private(i) firstprivate(a1,a2,a3,a4,a5) reduction(+:diff)
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
!$OMP END  DO
!     psi(i1:i2,j1:j2)=new_psi(i1:i2,j1:j2)
!$OMP  DO SCHEDULE (STATIC) private(i)
    do j=j1,j2
        do i=i1,i2
            psi(i,j)=new_psi(i,j)
         enddo
     enddo
!$OMP END DO
!$OMP END PARALLEL
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
!*********************
subroutine write_grid(psi,i1,i2,j1,j2)
! input is the grid and the indices for the interior cells
    use numz
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    integer i,j
    integer istart,iend,jstart,jend
    integer rl
! each processor writes its section of the grid
    istart=i1-1
    iend=i2+1
    jstart=j1-1
    jend=j2+1
    rl=max(80,15*((jend-jstart)+3)+2)
    open(23,file="out_omp",recl=rl)
!    write(23,101)istart,iend,jstart,jend
!101 format(6x," (",i3," <= i <= ",i3,") , ", &
!              " (",i3," <= j <= ",i3,")")
    write(23,'(2i6)')iend-istart+1,jend-jstart+1
    
    do i=istart,iend
       do j=jstart,jend
           write(23,'(g14.7)',advance="no")psi(i,j)
           if(j .ne. jend)write(23,'(" ")',advance="no")
       enddo
       write(23,*)
    enddo
    close(23)
end subroutine write_grid


function walltime()
    use numz
    real(b8) walltime
    integer count,count_rate,count_max
    call system_clock(count,count_rate,count_max)
    walltime=real(count,b8)/real(count_rate,b8)
end function walltime
    

