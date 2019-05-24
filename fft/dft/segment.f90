    program dofft
! Fortran example.
! Compile line:
! ifort -mkl $MKLROOT/include/mkl_dfti.f90 -Wa -O3 segment.f90 -o segment
! 1D complex to complex, and real to conjugate-even
    Use MKL_DFTI
!    implicit none
    integer count0,count1,count2,count3, COUNT_RATE, COUNT_MAX
    integer :: ntotal,nbin,ndt,nb2
    integer :: is,ie,ifft
    integer :: ic,jline,outsize,i
    character (len=132) :: fname1,fname2
    logical,parameter :: doamp=.true.
    Real,allocatable :: Y(:),fullset(:),amp(:)
    real :: rp,cp
    type(DFTI_DESCRIPTOR), POINTER ::  My_Desc2_Handle
    Integer :: Status
    write(*,*)"Enter total # points, # points/bin, offset between bins"
    read(*,*)ntotal,nbin,ndt
    allocate(fullset(ntotal))
    nb2=nbin+2
    allocate(y(nb2))
    allocate(amp(nb2/2))
    if(doamp)then
      outsize=size(amp)
    else
      outsize=size(y)
    endif
    write(*,*)"Input file name:"
    read(*,*)fname1
    write(*,*)"Output file name:"
    read(*,*)fname2
    call SYSTEM_CLOCK(COUNT0, COUNT_RATE, COUNT_MAX)
    open(unit=17,file=fname1,access="stream",status="old")
    open(unit=18,file=fname2,access="stream",status="replace")
    read(17)fullset
    call SYSTEM_CLOCK(COUNT1)
    Status = DftiCreateDescriptor(My_Desc2_Handle, DFTI_SINGLE, DFTI_REAL, 1, nbin)
    Status = DftiCommitDescriptor(My_Desc2_Handle)
    is=1
    ie=(is-1)+nbin
    ifft=0
    call SYSTEM_CLOCK(COUNT2)
    do while(ie <= ntotal)
!...put input data into Y(1),...,Y(nbin)
!...we have two extra "spaces" for the midpoint of the fft
      y(1:nbin)=fullset(is:ie)
!...if we have a window it would be applied here
      Status = DftiComputeForward(My_Desc2_Handle, Y)
      ifft=ifft+1
      is=is+ndt
      ie=ie+ndt
      if(doamp)then
        ic=0
        jline=1
        do i=1,nb2
          if(ic == 0)then
    	    rp=y(i)
    	    ic=1
    	  else
            cp=y(i)
            amp(jline)=sqrt(rp*rp+cp*cp)
            ic=0
            jline=jline+1
    	  endif
        end do
        write(18)amp
      else
        write(18)Y
      endif
      write(*,*)ifft
    enddo
    call SYSTEM_CLOCK(COUNT3)
    Status = DftiFreeDescriptor(My_Desc2_Handle)
    write(*,*)
    write(*,*)"read time         ",real(count1-count0)/real(count_rate)
    write(*,*)"fft  & write time ",real(count3-count2)/real(count_rate)
    write(*,*)"output files is ",ifft," records with ",outsize," elements each"
    write(*,*)COUNT0, COUNT_RATE, COUNT_MAX
    end program

