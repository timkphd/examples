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
