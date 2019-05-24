program compute_pi
    use myenv
    double precision :: psum,x,w
    integer me,nimg,i
    double precision :: pi[*] ! only use pi[1]
    double precision :: part[*] 
    integer :: n[*] ! only use n[1]
    character(len=max_name_length) :: nodename[*]
    nimg = num_images()
    me = this_image()
    call  myhostname (nodename)
!    write(*,*)me,nodename
    sync all
    pi = 0.d0
    if (me==1) then
        write(6,*) 'Enter number of intervals'
        read(*,*)n
        write(6,*) 'number of intervals = ',n
    endif
    sync all  
    w = 1.d0/n[1]; psum = 0.d0
    do i= me,(n[1]),nimg
        x = w * (i - 0.5d0); psum = psum +4.d0/(1.d0+x*x)
    enddo
    part[me]=psum
    critical
!        write(*,*)"me=",me
        pi[1] = pi[1] + (w * psum)
    end critical
    sync all  
    if (me==1) then
            write(6,*) 'computed pi =',pi
            write(6,*) 'images =',nimg
    endif
    sync all
    if ( me == 1) then
     do i=1,nimg
       write(*,*)i,nodename[i]
     enddo
     endif
end

