

!/*-----------------------------------------------------------------------------
! *  main  --  reads option values, reads a snapshot, and launches the
! *            integrator
! *-----------------------------------------------------------------------------
! */

program lmac
	use numz
	use dim
	use face, only:read_options,get_snapshot,evolve
	implicit none
    logical flag

    real(b8)  dt_param        ! control parameter to determine time step size
    real(b8)  dt_dia          ! time interval between diagnostics output
    real(b8)  dt_out          ! time interval between output of snapshots
    real(b8)  dt_tot          ! duration of the integration
    logical  init_out         ! if true: snapshot output with start at t = 0
                              !          with an echo of the input snapshot
    logical  x_flag           ! if true: extra debugging diagnostics output
    logical  read_flag
    integer n
    real(b8) t
    real(b8),allocatable :: mass(:),pos(:,:),vel(:,:)

	dt_param = 0.03_b8    
	dt_dia = 1.0_b8         
	dt_out = 1.0_b8         
	dt_tot = 10.0_b8         
	init_out = .false.   
					  
	x_flag = .false.     
    read_flag=.true.
    call read_options(read_flag, dt_param, dt_dia, dt_out, &
                      dt_tot, init_out, x_flag)
                             ! halt criterion detected by read_options()
    if (read_flag .eqv. .false.)stop

                           
    read(*,*)n             ! N, number of particles in the N-body system

    read(*,*)t             ! time

    allocate(mass(0:n-1))             ! masses for all particles
    allocate(pos(0:n-1,0:NDIM-1))     ! positions for all particles
    allocate(vel(0:n-1,0:NDIM-1))     ! velocities for all particles

    call get_snapshot(mass, pos, vel, n)

    call evolve(mass, pos, vel, n, t, dt_param, dt_dia, &
                dt_out, dt_tot, init_out, x_flag)

    deallocate(mass)
    deallocate(pos)
    deallocate(vel)
end program
