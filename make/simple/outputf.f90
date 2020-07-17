!*********************
subroutine write_grid(psi,i1,i2,j1,j2)
! input is the grid and the indices for the interior cells
    use numz
    implicit none
    integer,intent(in):: i1,i2,j1,j2
    real(b8),dimension(i1-1:i2+1,j1-1:j2+1):: psi
    integer i,j
    integer istart,iend,jstart,jend
    integer rl
! each processor writes its section of the grid
    istart=i1-1
    iend=i2+1
    jstart=j1-1
    jend=j2+1
    rl=max(80,15*((jend-jstart)+3)+2)
    open(23,file="out_serial",recl=rl)
!    write(23,101)istart,iend,jstart,jend
!101 format(6x," (",i3," <= i <= ",i3,") , ", &
!              " (",i3," <= j <= ",i3,")")
    write(23,'(2i6)')iend-istart+1,jend-jstart+1
    
    do i=istart,iend
       do j=jstart,jend
           write(23,'(g14.7)',advance="no")psi(i,j)
           if(j .ne. jend)write(23,'(" ")',advance="no")
       enddo
       write(23,*)
    enddo
    close(23)
end subroutine write_grid 
