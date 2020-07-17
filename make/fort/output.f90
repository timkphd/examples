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
    etot = ekin + epot                  ! total energy of the n-body system

    if (init_flag) then                 ! at first pass, pass the initial
        einit = etot                    ! energy back to the calling function
    endif

    write(cerr,1)t,nsteps
 1  format("at time t = " ,f10.5, " , after " ,i6," steps:")
    write(cerr,2)ekin,epot,etot
 2  format("E_kin = " ,f10.5, " , E_pot = " ,f10.5," , E_tot = ",f10.5)
    write(cerr,3)etot - einit
 3  format(10x,"absolute energy error: E_tot - E_init = ",es13.5)
    write(cerr,4)(etot - einit) / einit
 4  format(10x,"relative energy error: (E_tot - E_init) / E_init = ",es13.5)


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
end subroutine write_diagnostics