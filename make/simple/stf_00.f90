
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
    real(b8) t1,t2,walltime
    integer i,j,i1,i2,j1,j2
    integer iout
! get the input.  see above for typical values
    read(*,*)nx,ny
    read(*,*)lx,ly
    read(*,*)alpha,beta,gamma
    read(*,*)steps
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
    write(*,'("run time =",f10.2)')t2-t1
! write out the final grid
    call write_grid(psi,i1,i2,j1,j2)
end program stommel



    

