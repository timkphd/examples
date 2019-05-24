    program dofft
! Fortran example.
! Compile line:
! ifort -mkl $MKLROOT/include/mkl_dfti.f90  -O3 tfft.f90 -o tfft
! 1D complex to complex, and real to conjugate-even
    Use MKL_DFTI
    integer count0,count1,count2,count3,count4, COUNT_RATE, COUNT_MAX
!    integer,parameter::mysize=32,mysize2=34
!    integer,parameter::mysize=13200000,mysize2=13200002
    integer,parameter::mysize=35,mysize2=mysize+2
    Complex :: X(mysize)
    Real :: Y(mysize2)
    Real :: rp,cp
    integer ic
    type(DFTI_DESCRIPTOR), POINTER :: My_Desc1_Handle, My_Desc2_Handle
    Integer :: Status
!...put input data into X(1),...,X(mysize); Y(1),...,Y(mysize)
    call SYSTEM_CLOCK(COUNT0, COUNT_RATE, COUNT_MAX)
    do i=1,mysize
      x(i)=i*i
      y(i)=i*i
    end do
    call SYSTEM_CLOCK(COUNT1) 
! Perform a complex to complex transform
    Status = DftiCreateDescriptor( My_Desc1_Handle, DFTI_SINGLE, DFTI_COMPLEX, 1, mysize )
    Status = DftiCommitDescriptor( My_Desc1_Handle )
    Status = DftiComputeForward( My_Desc1_Handle, X )
    Status = DftiFreeDescriptor(My_Desc1_Handle)
    call SYSTEM_CLOCK(COUNT2) 
    write(*,*)"! result is given by {X(1),X(2),...,X(mysize)}",mysize
    jline=1
    do i=1,min(64,mysize)
        write(*,*)jline,x(i)
        jline=jline+1
    end do
! Perform a real to complex conjugate-even transform
    call SYSTEM_CLOCK(COUNT3) 
    Status = DftiCreateDescriptor(My_Desc2_Handle, DFTI_SINGLE, DFTI_REAL, 1, mysize)
    Status = DftiCommitDescriptor(My_Desc2_Handle)
    Status = DftiComputeForward(My_Desc2_Handle, Y)
    Status = DftiFreeDescriptor(My_Desc2_Handle)
    write(*,*)"! result is given in CCS format.",mysize
    call SYSTEM_CLOCK(COUNT4) 
    ic=0
    jline=1
    do i=1,min(64,mysize2)
    	if(ic == 0)then
    	  rp=y(i)
    	  ic=1
    	else
    	  cp=y(i)
          write(*,*)jline,rp,cp,sqrt(rp*rp+cp*cp)
          ic=0
          jline=jline+1
        endif
    end do
    write(*,*)y
    write(*,*)
    write(*,*)"create time      ",real(count1-count0)/real(count_rate)
    write(*,*)"complex fft time ",real(count2-count1)/real(count_rate)
    write(*,*)"real fft time    ",real(count4-count3)/real(count_rate)
    write(*,*)COUNT0, COUNT_RATE, COUNT_MAX
    end program

