module stuff
 contains
    subroutine subdomain( x,  iam, ipoints) 
        real x(:)
        integer iam
        integer ipoints
        integer ibot,itop,i
        integer sum
        ibot=(iam)*ipoints+1
        itop=ibot+ipoints-1
        do i=ibot,itop
            x(i)=iam
        enddo
        sum=0
        do i=ibot,itop
            sum=sum+x(i)
        enddo
    !$omp critical
        write(*,*)" iam= ",iam," doing ",ibot,itop,sum/ipoints
    !$omp end critical
    end subroutine
    
    subroutine pdomain( x,  iam, ipoints) 
        real x(:)
        integer iam,ipoints
        integer ibot,itop,i
        real  y
        ibot=(iam)*ipoints+1
        itop=ibot+ipoints-1
        write(*,*)" section= ",iam,"is from ",ibot," to ",itop
        y=x(ibot)
        do i=ibot,itop
            if(y .ne. x(i))y=x(i)
        enddo
        if(y .eq. x(ibot)) then
            write(*,*)" and contains",y
        else
            write(*,*)" failed"
        endif
    end subroutine
end module

program mymain
    use stuff
    integer omp_get_thread_num,omp_get_num_threads
    integer i,iam,np,npoints,ipoints
    real, allocatable :: x(:)
!   x=0
!$omp parallel shared(x,npoints,np) default(none) private(iam,ipoints)
        npoints=2*3*4*5*7
        iam = omp_get_thread_num()
        np = omp_get_num_threads()
!$omp single
            if(allocated(x))write(*,*)"single fails"
            allocate(x(npoints))
!$omp end single
!$omp barrier
        ipoints = npoints/np
        write(*,*)ipoints,iam
        call subdomain(x,iam,ipoints)
!$omp end parallel 
    write(*,*)"outside of the parallel region"
    do i=0,np-1
       ipoints = npoints/np
       call pdomain(x,i,ipoints)
    enddo
end program

