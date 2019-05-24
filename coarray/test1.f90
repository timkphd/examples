      module numz
! module defines the basic real type and pi
          integer, parameter:: b8 = selected_real_kind(14)
      end module
program testit
    use myenv
    use numz
    integer nimg,me
    real(b8),allocatable,target :: psi(:)[:]
    real(b8),pointer :: lsi(:)
    integer bonk[2,*]
    nimg = num_images()
    me = this_image()
    if( me == 1)then
       allocate(psi(10)[*])
    else
       allocate(psi(20)[*])
    endif
    psi=me
    critical
     if( me == 1)then
! prints garbage for psi(11:20)
        write(*,*)psi(1:20)[2]
     else
        write(*,*)psi(1:10)[1]
     endif
    end critical
    lsi(-4:5)=>psi(1:10)
    critical
     write(*,*)lsi(-4:5)
    end critical  
    bonk=me
    sync all
    if(me .eq. 1)then
    do i=1,2
      do j=1,2
        write(*,*)i,j,bonk[i,j]
      enddo
    enddo  
    endif
end program
