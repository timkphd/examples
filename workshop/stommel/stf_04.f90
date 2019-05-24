!version: 2d decomposition using communcator
!version: routines MPI_COMM_SPLIT
!version: processor 0 outputs the grid uses MPI_Gatherv
!version: Uses asyncronous communication with MPI_ISEND and MPI_IRECV.
! solves the 2d Stommel Model of Ocean Circulation  
! using a Five-point stencil and Jacobi iteration
!
! gamma*((d(d(psi)/dx)/dx) + (d(d(psi)/dy)/dy))
! +beta(d(psi)/dx)=-alpha*sin(pi*y/(2*ly))
!
module numz
! module defines the basic real type and pi
    integer, parameter:: b8 = selected_real_kind(14)
    real(b8), parameter :: pi = 3.141592653589793239_b8
end module
!*********************
module input
! module contains the inputs 
    use numz
    integer nx,ny             ! number of interior points for our grid (50 50)
    real(b8) lx,ly            ! physical size of our grid (2000 2000)
    real(b8) alpha,beta,gamma ! parameters of the calculation (1.0e-9 2.25e-11 3.0e-6)
    integer steps             ! number of Jacobi iteration steps (60)
end module
!*********************
module constants
! this module contains the invariants (constants) of the
! calculation.  these values are determined in the main
! routine and used in the do_jacobi Jacobi iteration subroutine
! a6 is used in the force function
    use numz
    real(b8) dx,dy,a1,a2,a3,a4,a5,a6
    real(b8), allocatable:: for(:,:)     ! our force grid
end module
!*********************
module face
! this module contains the interface for the two subroutines
! that modify the grid.  an interface is a good idea in this
! case because we are passing allocatable arrays
    interface bc
        subroutine bc (psi,i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1:i2,j1:j2):: psi
        end subroutine
    end interface
    interface do_jacobi
        subroutine do_jacobi (psi,new_psi,diff,i1,i2,j1,j2)
! does a single Jacobi iteration step
! input is the grid and the indices for the interior cells
! new_psi is temp storage for the the updated grid
! output is the updated grid in psi and diff which is
! the sum of the differences between the old and new grids
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
            real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: new_psi
            real(b8) diff
        end subroutine
    end interface
! interface for the forcing function
    interface force
        function force(y)
            use numz
            real(b8) force,y
        end function force
    end interface   
! interface for routine to write the grid
    interface write_grid
        subroutine write_grid (psi,i1,i2,j1,j2)
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1:i2,j1:j2):: psi
        end subroutine
    end interface
    interface do_transfer
        subroutine do_transfer (psi,i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
            real(b8),dimension(i1:i2,j1:j2):: psi
        end subroutine
    end interface
    interface do_force
        subroutine do_force (i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
            use numz
            integer,intent(in):: i1,i2,j1,j2
        end subroutine
    end interface
    interface unique
        function unique(name)
            character (len=*) name
            character (len=20) unique
        end function
    end interface
end module
module mympi
    use numz
    use mpi
!   include "mpif.h"
    integer numnodes,myid,mpi_err
    integer, parameter::mpi_master=0
    integer status(MPI_STATUS_SIZE)
    integer nrow,ncol
    integer myrow,mycol
    integer myid_col,myid_row,nodes_row,nodes_col
    integer ROW_COMM,COL_COMM
    integer mytop,mybot,myleft,myright
    integer stat_ray(MPI_STATUS_SIZE,8)
    integer req(8),ireq
    real(b8), allocatable::sv1(:),sv2(:),rv1(:),rv2(:)
    real(b8), allocatable::sv3(:),sv4(:),rv3(:),rv4(:)
end module
!*********************
program stommel
    use numz
    use input
    use constants
    use face
    use mympi
    implicit none
    real(b8)t1,t2
    real(b8)diff,mydiff
    real(b8)dx2,dy2,bottom
    real(b8), allocatable:: psi(:,:)     ! our calculation grid
    real(b8), allocatable:: new_psi(:,:) ! temp storage for the grid
    integer i,j,i1,i2,j1,j2
    integer iout
    real(b8) di,dj
! do the mpi init stuff
    call MPI_INIT( mpi_err )
    call MPI_COMM_SIZE( MPI_COMM_WORLD, numnodes, mpi_err )
    call MPI_COMM_RANK( MPI_COMM_WORLD, myid, mpi_err )
! find a reasonable grid topology based on the number
! of processors
  nrow=nint(sqrt(float(numnodes)))
  ncol=numnodes/nrow
  do while (nrow*ncol .ne. numnodes)
      nrow=nrow+1
      ncol=numnodes/nrow
  enddo
  if(nrow .gt. ncol)then
      i=ncol
      ncol=nrow
      nrow=i
  endif
  myrow=myid/ncol+1
  mycol=myid - (myrow-1)*ncol + 1
! make the row and col communicators
! all processors with the same row will be in the same ROW_COMM
  call MPI_COMM_SPLIT(MPI_COMM_WORLD,myrow,mycol,ROW_COMM,mpi_err)
  call MPI_COMM_RANK( ROW_COMM, myid_row, mpi_err )
  call MPI_COMM_SIZE( ROW_COMM, nodes_row, mpi_err )
! all processors with the same col will be in the same COL_COMM
  call MPI_COMM_SPLIT(MPI_COMM_WORLD,mycol,myrow,COL_COMM,mpi_err)
  call MPI_COMM_RANK( COL_COMM, myid_col, mpi_err )
  call MPI_COMM_SIZE( COL_COMM, nodes_col, mpi_err )
! find id of neighbors using the communicators created above
  mytop   = myid_col-1;if( mytop    .lt. 0         )mytop   = MPI_PROC_NULL
  mybot   = myid_col+1;if( mybot    .eq. nodes_col )mybot   = MPI_PROC_NULL
  myleft  = myid_row-1;if( myleft   .lt. 0         )myleft  = MPI_PROC_NULL
  myright = myid_row+1;if( myright  .eq. nodes_row )myright = MPI_PROC_NULL
! get the input.  see above for typical values
    if(myid .eq. mpi_master)then
        read(*,*)nx,ny
        read(*,*)lx,ly
        read(*,*)alpha,beta,gamma
        read(*,*)steps
    endif
!send the data to other processors
    call MPI_BCAST(nx,   1,MPI_INTEGER,         mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(ny,   1,MPI_INTEGER,         mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(steps,1,MPI_INTEGER,         mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(lx,   1,MPI_DOUBLE_PRECISION,mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(ly,   1,MPI_DOUBLE_PRECISION,mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(alpha,1,MPI_DOUBLE_PRECISION,mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(beta, 1,MPI_DOUBLE_PRECISION,mpi_master,MPI_COMM_WORLD,mpi_err)
    call MPI_BCAST(gamma,1,MPI_DOUBLE_PRECISION,mpi_master,MPI_COMM_WORLD,mpi_err)
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
! set the indices for the interior of the grid
! we block the grid across the processors
! for a 50 x 50 gird with 6 processors we get
! nrow=  2  ncol=  3
! myid=   0 myrow=   1 mycol=   1    (  1 <= i <=  25) ,  (  1 <= j <=  17)
! myid=   1 myrow=   1 mycol=   2    (  1 <= i <=  25) ,  ( 18 <= j <=  33)
! myid=   2 myrow=   1 mycol=   3    (  1 <= i <=  25) ,  ( 34 <= j <=  50)
! myid=   3 myrow=   2 mycol=   1    ( 26 <= i <=  50) ,  (  1 <= j <=  17)
! myid=   4 myrow=   2 mycol=   2    ( 26 <= i <=  50) ,  ( 18 <= j <=  33)
! myid=   5 myrow=   2 mycol=   3    ( 26 <= i <=  50) ,  ( 34 <= j <=  50)
    dj=real(ny,b8)/real(nodes_row,b8)
    j1=nint(1.0_b8+myid_row*dj)
    j2=nint(1.0_b8+(myid_row+1)*dj)-1
    di=real(nx,b8)/real(nodes_col,b8)
    i1=nint(1.0_b8+myid_col*di)
    i2=nint(1.0_b8+(myid_col+1)*di)-1
    if(myid == mpi_master)write(*,'("rows= ",i4," columns= ",i4)')nodes_row,nodes_col
    write(*,'("myid= ",i4," myid_row= ",i4," myid_col= ",i4)')myid,myid_row,myid_col
    write(*,101)myid,myrow,mycol,i1,i2,j1,j2
101 format("myid= ",i4," myrow= ",i4," mycol= ",i4,3x,&
           " (",i3," <= i <= ",i3,") , ",            &
           " (",i3," <= j <= ",i3,")")
! allocate the grid to (i1-1:i2+1,j1-1:j2+1) this includes boundary cells
    allocate(psi(i1-1:i2+1,j1-1:j2+1))
    allocate(new_psi(i1-1:i2+1,j1-1:j2+1))
    allocate(for(i1-1:i2+1,j1-1:j2+1))
! set initial guess for the value of the grid
    psi=1.0_b8
! set boundary conditions
    call bc(psi,i1,i2,j1,j2)
! set up the persistent requests
    call do_vector_alloc(psi,i1,i2,j1,j2)
    call do_transfer(psi,i1,i2,j1,j2)
    call do_force(i1,i2,j1,j2)
! do the jacobian iterations
    t1=MPI_Wtime()
    iout=steps/100
    if(iout == 0)iout=1
    do i=1,steps
        call do_jacobi(psi,new_psi,mydiff,i1,i2,j1,j2)
    call do_transfer(psi,i1,i2,j1,j2)
!       write(*,*)myid,i,mydiff
	call MPI_REDUCE(mydiff,diff,1,MPI_DOUBLE_PRECISION, &
	                MPI_SUM,mpi_master,MPI_COMM_WORLD,mpi_err)
	if(myid .eq. mpi_master .and. mod(i,iout) .eq. 0)write(*,'(i6,1x,g20.10)')i,diff
    enddo
    t2=MPI_Wtime()
    if(myid .eq. mpi_master)write(*,'("run time =",f10.2)')t2-t1
! write out the final grid
    call write_grid(psi,i1,i2,j1,j2)
100 continue
    call MPI_Finalize(mpi_err)
end program stommel
!*********************
subroutine bc(psi,i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
    use numz
    use mympi
    use input, only : nx,ny
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
! do the top edges
    if(i1 .eq.  1) psi(i1-1,:)=0.0_b8
! do the bottom edges
    if(i2 .eq. ny) psi(i2+1,:)=0.0_b8
! do left edges
    if(j1 .eq.  1) psi(:,j1-1)=0.0_b8
! do right edges
    if(j2 .eq. nx) psi(:,j2+1)=0.0_b8
end subroutine bc
!*********************
subroutine do_jacobi(psi,new_psi,diff,i1,i2,j1,j2)
! does a single Jacobi iteration step
! input is the grid and the indices for the interior cells
! new_psi is temp storage for the the updated grid
! output is the updated grid in psi and diff which is
! the sum of the differences between the old and new grids
    use numz
    use constants
    use face , only : force
    implicit none
    integer,intent(in) :: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: new_psi
    real(b8) diff
    integer i,j
    real(b8) y
    diff=0.0_b8
    do j=j1,j2
       do i=i1,i2
!            y=j*dy
            new_psi(i,j)=a1*psi(i+1,j) + a2*psi(i-1,j) + &
                         a3*psi(i,j+1) + a4*psi(i,j-1) - &
                         a5*for(i,j)
!                         a5*force(y)
            diff=diff+abs(new_psi(i,j)-psi(i,j))
         enddo
     enddo
    psi(i1:i2,j1:j2)=new_psi(i1:i2,j1:j2)
end subroutine do_jacobi
!*********************
function force(y)
    use numz
    use input
    use constants
    implicit none
    real(b8) force,y
    force=-alpha*sin(y*a6)
end function force
!*********************
subroutine write_grid(psi,i1,i2,j1,j2)
! input is the grid and the indices for the interior cells
    use numz
    use mympi
    use face ,only : unique
    use input
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    integer i,j,k,i0,j0,i3,j3
    integer istart,iend,jstart,jend,local_bounds(4)
    integer, allocatable :: bounds(:,:),counts(:),offsets(:)
    integer dj,mystart,myend,icol
    real(b8),allocatable :: arow(:)
    
! the master prints the whole grid a line at a time.
! for a given line, each processor checks to see if
! it holds part of that line and then sends the 
! number of cells held using the MPI_GATHER.  the
! MPI_GATHERV is then used to send the data
    istart=i1
    iend=i2
    jstart=j1
    jend=j2
    if(istart .eq. 1)istart=0
    if(jstart .eq. 1)jstart=0
    if(iend .eq. nx)iend=nx+1
    if(jend .eq. ny)jend=ny+1
    i0=0
    j0=0
    i3=nx+1
    j3=ny+1
    if(myid .eq. mpi_master)then
        open(18,file=unique("out4d_"),recl=max(80,15*((ny)+3)+2))
!        write(18,101)i0,i3,j0,j3
!101 format(6x," (",i3," <= i <= ",i3,") , ", &
!              " (",i3," <= j <= ",i3,")")


        write(18,'(2i6)')i3-i0+1,j3-j0+1
        allocate(arow(j0:j3))
        allocate(counts(0:numnodes-1))
        allocate(offsets(0:numnodes-1))
        offsets(0)=0
    endif 
    do i=i0,i3
       if(i .ge. istart .and. i .le. iend)then
           dj=jend-jstart+1
           mystart=jstart
           myend=jend
           icol=i
       else
           dj=0
           mystart=jstart
           myend=jstart
           icol=istart
       endif
       call MPI_GATHER(dj,    1,MPI_INTEGER, &
                       counts,1,MPI_INTEGER, &
                       mpi_master,MPI_COMM_WORLD,mpi_err)                       
       if(myid .eq. mpi_master)then  
!      write(*,*)"for ",i," counts = ",counts," sum = ",sum(counts)     
           do k=1,numnodes-1
	           offsets(k)=counts(k-1)+offsets(k-1)
	       enddo
       endif
       call MPI_GATHERV(psi(icol,mystart:myend),dj,MPI_DOUBLE_PRECISION, &
                        arow(0),counts,offsets,MPI_DOUBLE_PRECISION, &
                        mpi_master,MPI_COMM_WORLD,mpi_err)
       if(myid .eq. mpi_master)then
	       do j=j0,j3
	           write(18,'(g14.7)',advance="no")arow(j)
	           if(j .ne. j3)write(18,'(" ")',advance="no")
	       enddo
	       write(18,*)
       endif
    enddo
    close(18)
end subroutine write_grid
!*********************

subroutine do_vector_alloc(psi,i1,i2,j1,j2)
    use numz
    use mympi
    use input
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    integer num_x,num_y
    logical even
    num_x=i2-i1+3
    num_y=j2-j1+3
    ireq=0
    if(mytop .ne. MPI_PROC_NULL)then
       allocate(sv1(j1-1:j2+1))
!        sv1=psi(i1,:)
       allocate(rv1(j1-1:j2+1))
!        rv1=psi(i1-1,:)
     endif                        
     if(mybot .ne. MPI_PROC_NULL)then
        allocate(rv2(j1-1:j2+1))
!        rv2=psi(i2+1,:)
        allocate(sv2(j1-1:j2+1))
!       sv2=psi(i2,:)
     endif
    if(myleft .ne. MPI_PROC_NULL)then
       allocate(sv3(i1-1:i2+1))
!        sv3=psi(:,j1)
       allocate(rv3(i1-1:i2+1))
!        rv1=psi(:,j1-1)
     endif                        
     if(myright .ne. MPI_PROC_NULL)then
        allocate(rv4(i1-1:i2+1))
!        rv2=psi(:,j2+1)
        allocate(sv4(i1-1:i2+1))
!       sv2=psi(:,j2)
     endif
end subroutine do_vector_alloc
!*********************
subroutine do_transfer(psi,i1,i2,j1,j2)
! sets the boundary conditions
! input is the grid and the indices for the interior cells
    use numz
    use mympi
    use input
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    integer num_x,num_y
    num_x=i2-i1+3
    num_y=j2-j1+3
    ireq=0

    if(myleft .ne. MPI_PROC_NULL)then
! send to left
        ireq=ireq+1
        sv3=psi(:,j1)
        call MPI_ISEND(sv3,  num_x,MPI_DOUBLE_PRECISION,myleft,  &
                                      100,ROW_COMM,req(ireq),mpi_err)
! rec from left
        ireq=ireq+1
!       psi(:,j1-1)=rv3 done below
        call MPI_IRECV(rv3,num_x,MPI_DOUBLE_PRECISION,myleft,  &
                                      100,ROW_COMM,req(ireq),mpi_err)
    endif
    if(myright .ne. MPI_PROC_NULL)then
! rec from right
        ireq=ireq+1
!       psi(:,j2+1)=rv4 done below
        call MPI_IRECV(rv4,num_x,MPI_DOUBLE_PRECISION,myright, &
                                      100,ROW_COMM,req(ireq),mpi_err)
! send to right
        ireq=ireq+1
        sv4=psi(:,j2)
        call MPI_ISEND(sv4,  num_x,MPI_DOUBLE_PRECISION,myright, &
                                      100,ROW_COMM,req(ireq),mpi_err)
    endif
    if(mytop .ne. MPI_PROC_NULL)then
! send to top
        ireq=ireq+1
        sv1=psi(i1,:)
        call MPI_ISEND(sv1,num_y,MPI_DOUBLE_PRECISION,mytop,     &
                      10, COL_COMM,req(ireq),mpi_err)  
! rec from top
        ireq=ireq+1
!       psi(i1-1,:)=rv1 done below
        call MPI_IRECV(rv1,num_y,MPI_DOUBLE_PRECISION,mytop,  &
                      10,COL_COMM,req(ireq),mpi_err)  
    endif
    if(mybot .ne. MPI_PROC_NULL)then
! rec from bot
        ireq=ireq+1
!       psi(i2+1,:)=rv2 done below
        call MPI_IRECV(rv2,num_y,MPI_DOUBLE_PRECISION,mybot,  &
                      10,COL_COMM,req(ireq),mpi_err)
! send to bot
        ireq=ireq+1
        sv2=psi(i2,:)
        call MPI_ISEND(sv2,num_y,MPI_DOUBLE_PRECISION,mybot,     &
                      10, COL_COMM,req(ireq),mpi_err)
    endif
    call MPI_WAITALL(ireq,req,stat_ray,mpi_err)
    if(mytop .ne. MPI_PROC_NULL)psi(i1-1,:)=rv1
    if(mybot .ne. MPI_PROC_NULL)psi(i2+1,:)=rv2
    if(myleft .ne. MPI_PROC_NULL)psi(:,j1-1)=rv3
    if(myright .ne. MPI_PROC_NULL)psi(:,j2+1)=rv4

end subroutine do_transfer
!*********************
subroutine do_force (i1,i2,j1,j2)
! sets the force conditions
! input is the grid and the indices for the interior cells
    use numz
    use constants, only:for,dy
    use face, only : force
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8) y
    integer i,j
    do i=i1,i2
        do j=j1,j2
            y=j*dy
            for(i,j)=force(y)
        enddo
    enddo
end subroutine
!*********************
function even(i)
  integer i
  logical even
  j=i/2
  if(j*2 .eq. i)then
      even = .true.
  else
      even = .false.
  endif
  return
end function even
!*********************
function unique(name)
    use numz
    use mympi
    character (len=*) name
    character (len=20) unique
    character (len=80) temp
    if(myid .gt. 99)then
      write(temp,"(a,i3)")trim(name),myid
    else
        if(myid .gt. 9)then
            write(temp,"(a,'0',i2)")trim(name),myid
        else
            write(temp,"(a,'00',i1)")trim(name),myid
        endif
    endif
    unique=temp
    return
end function unique
!*********************





