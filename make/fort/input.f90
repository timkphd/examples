!/*-----------------------------------------------------------------------------
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
end subroutine get_snapshot