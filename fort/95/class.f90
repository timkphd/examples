!A class example showing passing different types to a subroutine
module bonk
    contains 
    subroutine sumit(p)
        real(kind(0.)), pointer :: r4(:,:),r3(:,:,:)
        complex(kind(0d0)), pointer :: r8(:,:)
        class(*), target :: p(:,:)
        select type (p)
            type is (real(kind(0.)))
                r4=>p
                write(*,'(f10.2)') p
                write(*,*)
                write(*,'(f10.2)') r4
            type is (complex(kind(0d0)))
                r8=>p
                write(*,'(2f10.2)') r8
                allocate(r3(2,4,4))
                do j=1,4
                    do i=1,4
                    r3(1,i,j)=dble(r8(i,j))
                    r3(2,i,j)=dimag(r8(i,j))
                    !write(*,'(2f10.2)') r3(:,i,j)
                    enddo
                enddo
                write(*,*)
                write(*,'(2f10.2)')r3
                deallocate(r3)
        end select
    end subroutine
end module

program test_ptr
    use bonk
    implicit none
    integer i,j,k
    real(kind(0.)), target :: r4(4,4)
    complex(kind(0d0)), target :: r8(4,4)
    class(*), pointer :: p(:,:)

    ! some assignments, etc.
    k=0
    do j=1,4
        do i=1,4
            k=k+1
            r4(i,j)=k
            r8(i,j)=cmplx(k,-k)
        enddo
    enddo
    read(*,*)i
    do while (i > 0)                 
        if (i == 4) then
            p => r4
        else
            p => r8
        end if
    call sumit(p)
    read(*,*)i
    end do
end program
