!/*-----------------------------------------------------------------------------
! *  evolve  --  integrates an N-body system, for a total duration dt_tot.
! *              Snapshots are sent to the standard output stream once every
! *              time interval dt_out.  Diagnostics are sent to the standard
! *              error stream once every time interval dt_dia.
! *
! *  note: the integration time step, shared by all particles at any given time,
! *        is variable.  Before each integration step we use coll_time (short
! *        for collision time, an estimate of the time scale for any significant
! *        change in configuration to happen), multiplying it by dt_param (the
! *        accuracy parameter governing the size of dt in units of coll_time),
! *        to obtain the new time step size.
! *
! *  Before moving any particles, we start with an initial diagnostics output
! *  and snapshot output if desired.  In order to write the diagnostics, we
! *  first have to calculate the potential energy, with get_acc_jerk_pot_coll().
! *  That function also calculates accelerations, jerks, and an estimate for the
! *  collision time scale, all of which are needed before we can enter the main
! *  integration loop below.
! *       In the main loop, we take as many integration time steps as needed to
! *  reach the next output time, do the output required, and continue taking
! *  integration steps and invoking output this way until the final time is
! *  reached, which triggers a `break' to jump out of the infinite loop set up
! *  with `while(true)'.
! *-----------------------------------------------------------------------------
! */
!
subroutine evolve(mass, pos, vel, &
             n,  t, dt_param, dt_dia, dt_out, &
            dt_tot,  init_out,  x_flag)
	use numz
	use dim
	use face, only:get_acc_jerk_pot_coll,write_diagnostics &
	               ,put_snapshot,evolve_step
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:)
    integer  n
    real(b8) t, dt_param, dt_dia, dt_out, dt_tot
    logical init_out,x_flag
    
    real(b8), allocatable:: acc(:,:),jerk(:,:)
    real(b8) epot                    ! potential energy of the n-body system
    real(b8) coll_time               ! collision (close encounter) time scale
    real(b8) einit                   ! initial total energy of the system
    integer nsteps                   ! number of integration time steps completed
    real(b8) dt 
    real(b8) t_dia,t_out,t_end


    write(*,*) " Starting a Hermite integration for a " , n ,"-body system"
    write(*,*) " from time t = " , t 
    write(*,*) " with time step control parameter dt_param = " , dt_param
    write(*,*) " until time " , t + dt_tot 
    write(*,*) " with diagnostics output interval dt_dia = ", dt_dia
    write(*,*) " and snapshot output interval dt_out = ",dt_out ,"."
    
    allocate(acc(0:n-1,0:ndim-1))      ! accelerations and jerks
    allocate(jerk(0:n-1,0:ndim-1))     ! for all particles

    call get_acc_jerk_pot_coll(mass, pos, vel, acc, jerk, n, epot, coll_time)

    nsteps = 0               ! number of integration time steps completed

    call write_diagnostics(mass, pos, vel, acc, jerk, n, t, epot, &
                           nsteps, einit, .true., x_flag)
    if (init_out) then                 ! flag for initial output
        call put_snapshot(mass, pos, vel, n, t)
    endif
    t_dia = t + dt_dia           ! next time for diagnostics output
    t_out = t + dt_out           ! next time for snapshot output
    t_end = t + dt_tot           ! final time, to finish the integration

    do 
        do while (t .lt. t_dia .and. t .lt. t_out .and. t .lt. t_end)
            dt = dt_param * coll_time
            call evolve_step(mass, pos, vel, acc, jerk, n, t, dt, epot, coll_time)
            nsteps=nsteps+1
        end do
        if (t .ge. t_dia)then
            call write_diagnostics(mass, pos, vel, acc, jerk, n, t, epot, nsteps, &
                                   einit, .false., x_flag)
            t_dia = t_dia + dt_dia
        endif
        if (t .ge. t_out)then
            call put_snapshot(mass, pos, vel, n, t)
            t_out = t_out + dt_out
        endif
        if (t .ge. t_end)exit
    end do

    deallocate(acc)
    deallocate(jerk)
end subroutine evolve

