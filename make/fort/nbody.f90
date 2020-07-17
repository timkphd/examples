module dim
      integer, parameter:: ndim=3
end module dim
module numz
! module defines the basic real types
      integer, parameter:: b8 = selected_real_kind(14)
      integer, parameter:: b16 = selected_real_kind(14)
      integer, parameter :: cin=5
      integer, parameter :: cout=6
      integer, parameter :: cerr=0
      character(len=11):: form1="(1x,e22.15)"
end module

module face
interface 
    subroutine get_acc_jerk_pot_coll(mass, pos, &
                                     vel,  acc, &
                                     jerk,  n, epot, &
                                     coll_time)
    use numz
    implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:),  acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) epot
    real(b8) coll_time
    end subroutine
    
    subroutine evolve_step(mass,  pos,  vel, &
                  acc,  jerk, n, t, &
                  dt,  epot, coll_time)
	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:),  acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) t,dt
    real(b8) epot
    real(b8) coll_time
    end subroutine
    
    subroutine predict_step(pos,vel, acc, jerk,n,dt)
	use numz
	use dim
	implicit none
    real(b8) pos(0:,0:)
    real(b8) vel(0:,0:)
    real(b8) acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) dt
    end subroutine
    
    subroutine correct_step(pos,vel, acc, jerk, &
                  old_pos, old_vel, old_acc, old_jerk, &
                  n,dt)
	use numz
	use dim
	implicit none
    real(b8) pos(0:,0:),vel(0:,0:),acc(0:,0:),jerk(0:,0:)
    real(b8) old_pos(0:,0:),old_vel(0:,0:),old_acc(0:,0:),old_jerk(0:,0:)
    integer  n
    real(b8) dt
    end subroutine
    
    subroutine put_snapshot(mass, pos, vel, n, t)
 	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:)
    integer  n
    real(b8) t
    end subroutine            
                  
    subroutine write_diagnostics(mass, pos, &
                       vel, acc, &
                       jerk, n, t, epot, &
                       nsteps, einit,init_flag, &
                       x_flag)
	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:),  acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) t
    real(b8) epot
    integer nsteps
    real(b8) einit
    logical init_flag,x_flag
    end subroutine
    
    subroutine read_options(flag, dt_param, dt_dia, dt_out, dt_tot, i_flag,x_flag)
	use numz
	use dim
	implicit none
    logical flag
    real(b8) dt_param,dt_dia,dt_out,dt_tot
    logical i_flag,x_flag
    end subroutine

    subroutine get_snapshot(mass,  pos,  vel, n)
	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:)
    integer n
    end subroutine

    subroutine evolve(mass, pos, vel, &
                  n,  t, dt_param, dt_dia, dt_out, &
                  dt_tot,  init_out,  x_flag)
	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:)
    integer  n
    real(b8) t, dt_param, dt_dia, dt_out, dt_tot
    logical init_out,x_flag
    end subroutine


     
end interface
end module face

!/*-----------------------------------------------------------------------------
! *  get_acc_jerk_pot_coll  --  calculates accelerations and jerks, and as side
! *                             effects also calculates potential energy and
! *                             the time scale coll_time for significant changes
! *                             in local configurations to occur.
! *                                                  __                     __
! *                                                 |          -->  -->       |
! *               M                           M     |           r  . v        |
! *   -->          j    -->       -->          j    | -->        ji   ji -->  |
! *    a   ==  --------  r    ;    j   ==  -------- |  v   - 3 ---------  r   |
! *     ji     |-->  |3   ji        ji     |-->  |3 |   ji      |-->  |2   ji |
! *            | r   |                     | r   |  |           | r   |       |
! *            |  ji |                     |  ji |  |__         |  ji |     __|
! *                             
! *  note: it would be cleaner to calculate potential energy and collision time
! *        in a separate function.  However, the current function is by far the
! *        most time consuming part of the whole program, with a double loop
! *        over all particles that is executed every time step.  Splitting off
! *        some of the work to another function would significantly increase
! *        the total computer time (by an amount close to a factor two).
! *
! *  We determine the values of all four quantities of interest by walking
! *  through the system in a double {i,j} loop.  The first three, acceleration,
! *  jerk, and potential energy, are calculated by adding successive terms;
! *  the last, the estimate for the collision time, is found by determining the 
! *  minimum value over all particle pairs and over the two choices of collision
! *  time, position/velocity and sqrt(position/acceleration), where position and
! *  velocity indicate their relative values between the two particles, while
! *  acceleration indicates their pairwise acceleration.  At the start, the
! *  first three quantities are set to zero, to prepare for accumulation, while
! *  the last one is set to a very large number, to prepare for minimization.
! *       The integration loops only over half of the pairs, with j > i, since
! *  the contributions to the acceleration and jerk of particle j on particle i
! *  is the same as those of particle i on particle j, apart from a minus sign
! *  and a different mass factor.
! *-----------------------------------------------------------------------------
! */

subroutine get_acc_jerk_pot_coll(mass, pos, &
                                 vel,  acc, &
                                 jerk, n, epot, &
                                 coll_time)
    use numz
    use dim
    implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:),  acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) epot
    real(b8) coll_time
    real(b8) rji(0:ndim-1) 
    real(b8) vji(0:ndim-1) 
    real r2,v2,rv_r2,r,r3,da(0:2),dj(0:2),da2
    real(b8) coll_time_q ! collision time to 4th power
    real(b8) coll_est_q ! collision time scale estimate to 4th power (quartic)
    real(b8), parameter :: vln =1.0e300_b8
    real(b16) mij
    integer i,k,j
    
    acc=0.0_b8
    jerk=0.0_b8
    epot=0.0_b8
    coll_time_q = vln      ! collision time to 4th power
    do i=0,n-1
      do j=i+1, n-1                              !! rji() is the vector from
!            real rji(NDIM)                        !! particle i to particle j
!            real vji(NDIM)                        !! vji() = d rji() / d t
            do k=0, ndim-1
                rji(k) = pos(j,k) - pos(i,k)
                vji(k) = vel(j,k) - vel(i,k)
            enddo 
            r2 = 0.0_b8                           !! | rji |^2
            v2 = 0.0_b8                           !! | vji |^2
            rv_r2 = 0.0_b8                        !! ( rij . vij ) / | rji |^2
            do k=0, ndim-1
                r2=r2+ rji(k) * rji(k)
                v2=v2+ vji(k) * vji(k)
                rv_r2= rv_r2+ rji(k) * vji(k)
            enddo
            rv_r2 = rv_r2 / r2
            r = sqrt(r2)                     !! | rji |
            r3 = r * r2                      !! | rji |^3

!! add the {i,j} contribution to the total potential energy for the system:

            epot = epot - mass(i) * mass(j) / r

!! add the {j (i)} contribution to the {i (j)} values of acceleration and jerk:

!           real da(3)                            !! main terms in pairwise
!           real dj(3)                            !! acceleration and jerk
            do k=0, ndim-1
                da(k) = rji(k) / r3                           !! see equations
                dj(k) = (vji(k) - 3 * rv_r2 * rji(k)) / r3    !! in the header
            enddo
            do k=0, ndim-1
                acc(i,k) = acc(i,k) + mass(j) * da(k)                 !! using symmetry
                acc(j,k) = acc(j,k) - mass(i) * da(k)                 !! find pairwise
                jerk(i,k) = jerk(i,k) + mass(j) * dj(k)               !! acceleration
                jerk(j,k) = jerk(j,k) - mass(i) * dj(k)               !! and jerk
            enddo

!! first collision time estimate, based on unaccelerated linear motion:

            coll_est_q = (r2*r2) / (v2*v2)
            if (coll_time_q .gt. coll_est_q) coll_time_q = coll_est_q

!! second collision time estimate, based on free fall:

            da2 = 0.0_b8                                  !! da2 becomes the 
            do k=0, ndim-1                              !! square of the 
                da2= da2+ da(k) * da(k) 
            enddo                                         !! pair-wise accel-
            mij = mass(i) + mass(j)                       !! eration between
            da2=da2* mij * mij                            !! particles i and j

            coll_est_q = r2/da2
            if (coll_time_q .gt. coll_est_q) coll_time_q = coll_est_q
        enddo                                     
    enddo                                              !! from q for quartic back
    coll_time = sqrt(sqrt(coll_time_q))                !! to linear collision time
end subroutine get_acc_jerk_pot_coll                                             
                                        
subroutine evolve_step(mass,  pos,  vel, &
                  acc,  jerk, n, t, &
                  dt,  epot, coll_time)
	use numz
	use dim
	use face, only:predict_step,get_acc_jerk_pot_coll,correct_step
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:),  acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) t,dt
    real(b8) epot
    real(b8) coll_time
	
	real(b8),allocatable:: old_pos(:,:),old_vel(:,:),old_acc(:,:),old_jerk(:,:)
	allocate( old_pos(0:n-1,0:ndim-1) )
	allocate( old_vel(0:n-1,0:ndim-1) )
	allocate( old_acc(0:n-1,0:ndim-1) )
	allocate( old_jerk(0:n-1,0:ndim-1) )
	old_pos=pos
	old_vel=vel
	old_acc=acc
	old_jerk=jerk
	
	call predict_step(pos, vel, acc, jerk, n, dt)
	call get_acc_jerk_pot_coll(mass, pos, vel, acc, jerk, n, epot, coll_time)
	call correct_step(pos, vel, acc, jerk, old_pos, old_vel, old_acc, old_jerk, n, dt)
	t = t +dt
	
	deallocate( old_pos     )
	deallocate( old_vel     )
	deallocate( old_acc     )
	deallocate( old_jerk     )
end subroutine  evolve_step

!/*-----------------------------------------------------------------------------
! *  predict_step  --  takes the first approximation of one Hermite integration
! *                    step, advancing the positions and velocities through a
! *                    Taylor series development up to the order of the jerks.
! *-----------------------------------------------------------------------------
! */

subroutine predict_step(pos,vel, acc, jerk,n,dt)
	use numz
	use dim
	implicit none
    real(b8) pos(0:,0:)
    real(b8) vel(0:,0:)
    real(b8) acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) dt
    
    real(b8) dt2,dt3
    integer i,k
    dt2=dt*dt
    dt3=dt2*dt
    dt2=dt2/2.0_b8
    dt3=dt3/6.0_b8
    do i=0,n-1
      do k=0,ndim-1

            pos(i,k) = pos(i,k) + vel(i,k)*dt + acc(i,k)*dt2 &
                                                 + jerk(i,k)*dt3
            vel(i,k) = vel(i,k) + acc(i,k)*dt + jerk(i,k)*dt2
      enddo
    enddo
end subroutine predict_step
!/*-----------------------------------------------------------------------------
! *  correct_step  --  takes one iteration to improve the new values of position
! *                    and velocities, effectively by using a higher-order
! *                    Taylor series constructed from the terms up to jerk at
! *                    the beginning and the end of the time step.
! *-----------------------------------------------------------------------------
! */

subroutine correct_step(pos,vel, acc, jerk, &
                  old_pos, old_vel, old_acc, old_jerk, &
                  n,dt)
	use numz
	use dim
	implicit none
    real(b8) pos(0:,0:),vel(0:,0:),acc(0:,0:),jerk(0:,0:)
    real(b8) old_pos(0:,0:),old_vel(0:,0:),old_acc(0:,0:),old_jerk(0:,0:)
    integer  n
    real(b8) dt
    
    integer i,k
    
    do i=0,n-1
      do k=0,ndim-1
            vel(i,k) = old_vel(i,k) + (old_acc(i,k) + acc(i,k))*dt/2 &
                                      + (old_jerk(i,k) - jerk(i,k))*dt*dt/12
            pos(i,k) = old_pos(i,k) + (old_vel(i,k) + vel(i,k))*dt/2 &
                                      + (old_acc(i,k) - acc(i,k))*dt*dt/12
      enddo
    enddo
end subroutine correct_step
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

!/*-----------------------------------------------------------------------------
! *  put_snapshot  --  writes a single snapshot on the output stream cout.
! *
! *  note: unlike get_snapshot(), put_snapshot handles particle number and time
! *-----------------------------------------------------------------------------
! */
!    
subroutine put_snapshot(mass, pos, vel, n, t)
 	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:)
    integer  n
    real(b8) t
    integer i,k

                               ! form1 = full double precision

    write(*,*)n                         ! N, total particle number
    write(*,form1) t                                  ! current time
    do i=0,n-1
      write(*,form1,advance="no")mass(i)              ! mass of particle i
      do k=0,ndim-1
            write(*,form1,advance="no") pos(i,k)      ! position of particle i
      enddo
      do k=0,ndim-1
            write(*,form1,advance="no") vel(i,k)      ! velocity of particle i
      enddo
     write(*,*)
    enddo 

end subroutine put_snapshot
    
!/*-----------------------------------------------------------------------------
! *  write_diagnostics  --  writes diagnostics on the error stream cerr:
! *                         current time; number of integration steps so far;
! *                         kinetic, potential, and total energy; absolute and
! *                         relative energy errors since the start of the run.
! *                         If x_flag (x for eXtra data) is true, all internal
! *                         data are dumped for each particle (mass, position,
! *                         velocity, acceleration, and jerk).
! *
! *  note: the kinetic energy is calculated here, while the potential energy is
! *        calculated in the function get_acc_jerk_pot_coll().
! *-----------------------------------------------------------------------------
! */
!
    subroutine write_diagnostics(mass, pos, &
                       vel, acc, &
                       jerk, n, t, epot, &
                       nsteps, einit,init_flag, &
                       x_flag)
	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:),  acc(0:,0:)
    real(b8) jerk(0:,0:)
    integer  n
    real(b8) t
    real(b8) epot
    integer nsteps
    real(b8) einit
    logical init_flag,x_flag
    real(b8) ekin                        ! kinetic energy of the n-body system
    real(b8) etot                        
    integer i,k
    ekin = 0.0_b8                      
                           ! form1 =full double precision
    
    do i=0,n-1
       do k=0,ndim-1
            ekin = ekin+ 0.5 * mass(i) * vel(i,k) * vel(i,k)
       enddo
    enddo
    etot = ekin + epot             ! total energy of the n-body system

    if (init_flag) then                       ! at first pass, pass the initial
        einit = etot                    ! energy back to the calling function
    endif
    write(cerr,*)"at time t = " ,t, " , after " ,nsteps," steps"
    write(cerr,*)"E_kin = " ,ekin, "E_pot = " ,epot," , E_tot = ",etot
    write(cerr,*)"absolute energy error: E_tot - E_init = ",etot - einit
    write(cerr,*)"relative energy error: (E_tot - E_init) / E_init = ", &
                 (etot - einit) / einit

    if (x_flag)then
         write(cerr,*)"for debugging purposes, here is",&
                      " the internal data representation:\n"
        do i=0,n-1
            write(cerr,*)"   internal data for particle ", i+1 ," : "
            write(cerr,form1,advance="no")mass(i)
            do k=0,ndim-1
              write(*,form1,advance="no") pos(i,k) 
            enddo           
            do k=0,ndim-1
              write(*,form1,advance="no") vel(i,k) 
            enddo           
            do k=0,ndim-1
              write(*,form1,advance="no") acc(i,k) 
            enddo           
            do k=0,ndim-1
              write(*,form1,advance="no") jerk(i,k) 
            enddo           
            write(cerr,*)
        enddo
    endif
end subroutine write_diagnostics!/*-----------------------------------------------------------------------------
! *  read_options  --  reads the command line options, and implements them.
! *
! *  note: when the help option -h is invoked, the return value is set to false,
! *        to prevent further execution of the main program; similarly, if an
! *        unknown option is used, the return value is set to false.
! *-----------------------------------------------------------------------------
! */
subroutine read_options(flag, dt_param, dt_dia, dt_out, dt_tot, i_flag,x_flag)
	use numz
	use dim
	implicit none
    logical flag
    real(b8) dt_param,dt_dia,dt_out,dt_tot
    logical i_flag,x_flag
    namelist /options/ dt_param,dt_dia,dt_out,dt_tot,i_flag,x_flag
    integer istat,jstat
    flag=.true.
    open(unit=19,file="options.in",status="old",iostat=istat)
    if(istat .eq. 0) then
      read(19,nml=options,iostat=jstat)
      close(19)
      if(jstat .ne. 0)flag=.false.
      return
    endif
    write(cerr,nml=options)
end subroutine read_options

!/*-----------------------------------------------------------------------------
! *  get_snapshot  --  reads a single snapshot from the input stream cin.
! *
! *  note: in this implementation, only the particle data are read in, and it
! *        is left to the main program to first read particle number and time
! *-----------------------------------------------------------------------------
! */
!
subroutine get_snapshot(mass,  pos,  vel, n)
	use numz
	use dim
	implicit none
    real(b8) mass(0:), pos(0:,0:)
    real(b8) vel(0:,0:)
    integer n
    integer i,k
    write(*,*)lbound(mass),ubound(mass)
    do i=0,n-1
      read(*,*)mass(i),(pos(i,k),k=0,ndim-1),(vel(i,k),k=0,ndim-1)
    enddo
end subroutine get_snapshot!              ! Time-stamp: <2002-01-18 21:51:36 piet>
!             !================================================================
!            !                                                                |
!           !           /__----__                         ........            |
!          !       .           \                     ....:        :.          |
!         !       :                 _\|/_         ..:                         |
!        !       :                   /|\         :                     _\|/_  |
!       !  ___   ___                  _____                      ___    /|\   |
!      !  /     |   \    /\ \     / |   |   \  / |        /\    |   \         |
!     !  |   __ |___/   /  \ \   /  |   |    \/  |       /  \   |___/         |
!    !   |    | |  \   /____\ \ /   |   |    /   |      /____\  |   \     \/  |
!   !     \___| |   \ /      \ V    |   |   /    |____ /      \ |___/     |   |
!  !                                                                      /   |
! !              :                       _/|     :..                    |/    |
!!                :..               ____/           :....          ..         |
!/*   o   !          :.    _\|/_     /                   :........:           |
! *  O  `!\                 /|\                                               |
! *  |     /\                                                                  |
! *=============================================================================
! *
! *  nbody_sh1.C:  an N-body integrator with a shared but variable time step
! *                (the same for all particles but changing in time), using
! *                the Hermite integration scheme.
! *                        
! *                ref.: Hut, P., Makino, J. & McMillan, S., 1995,
! *                      Astrophysical Journal Letters 443, L93-L96.
! *                
! *  note: in this first version, all functions are included in one file,
! *        without any use of a special library or header files.
! *_____________________________________________________________________________
! *
! *  usage: nbody_sh1 [-h (for help)] [-d step_size_control_parameter]
! *                   [-e diagnostics_interval] [-o output_interval]
! *                   [-t total_duration] [-i (start output at t = 0)]
! *                   [-x (extra debugging diagnostics)]
! * 
! *         "step_size_control_parameter" is a coefficient determining the
! *            the size of the shared but variable time step for all particles
! *
! *         "diagnostics_interval" is the time between output of diagnostics,
! *            in the form of kinetic, potential, and total energy with the
! *            -x option, a dump of the internal particle data is made as well
! * 
! *         "output_interval" is the time between successive snapshot outputs
! *
! *         "total_duration" is the integration time, until the program stops
! *
! *         Input and output are written from the standard i/o streams.  Since
! *         all options have sensible defaults, the simplest way to run the code
! *         is by only specifying the i/o files for the N-body snapshots:
! *
! *            nbody_sh1 < data.in > data.out
! *
! *         The diagnostics information will then appear on the screen.
! *         To capture the diagnostics information in a file, capture the
! *         standard error stream as follows:
! *
! *            (nbody_sh1 < data.in > data.out) >& data.err
! *
! *  Note: if any of the times specified in the -e, -o, or -t options are not an
! *        an integer multiple of "step", output will occur slightly later than
! *        predicted, after a full time step has been taken.  And even if they
! *        are integer multiples, round-off error may induce one extra step.
! *_____________________________________________________________________________
! *
! *  External data format:
! *
! *     The program expects input of a single snapshot of an N-body system,
! *     in the following format: the number of particles in the snapshot n
! *     the time t mass mi, position ri and velocity vi for each particle i,
! *     with position and velocity given through their three Cartesian
! *     coordinates, divided over separate lines as follows:
! *
! *                      n
! *                      t
! *                      m1 r1_x r1_y r1_z v1_x v1_y v1_z
! *                      m2 r2_x r2_y r2_z v2_x v2_y v2_z
! *                      ...
! *                      mn rn_x rn_y rn_z vn_x vn_y vn_z
! *
! *     Output of each snapshot is written according to the same format.
! *
! *  Internal data format:
! *
! *     The data for an N-body system is stored internally as a 1-dimensional
! *     array for the masses, and 2-dimensional arrays for the positions,
! *     velocities, accelerations and jerks of all particles.
! *_____________________________________________________________________________
! *
! *    version 1:  Jan 2002   Piet Hut, Jun Makino
! *_____________________________________________________________________________
! */
!

!/*-----------------------------------------------------------------------------
! *  main  --  reads option values, reads a snapshot, and launches the
! *            integrator
! *-----------------------------------------------------------------------------
! */

program ell
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

	dt_param = 0.03    
	dt_dia = 1         
	dt_out = 1         
	dt_tot = 10        
	init_out = .false.   
					  
	x_flag = .false.     

    call read_options(read_flag, dt_param, dt_dia, dt_out, &
                      dt_tot, init_out, x_flag)
                             ! halt criterion detected by read_options()
    if (read_flag .eq. .false.)stop

                           
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
