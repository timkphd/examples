!              ! Time-stamp: <2002-01-18 21:51:36 piet>
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
      character(len=12):: form1="(1x,es23.15)"
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

