module aptr
        REAL, POINTER, DIMENSION(:) :: VECTOR => NULL()
        !real, allocatable,target :: array(:)
end module
subroutine dummy(i)
        use aptr
        !save
        real, allocatable,target :: x_ray(:)
        write(*,*)
        write(*,*)"in dummy vector associated", ASSOCIATED(vector)
!        write(*,*)allocated(x_ray)
        allocate(x_ray(i))
        do j=1,i
        x_ray(j)=j
        enddo
        write(*,*)"vector associated", ASSOCIATED(vector), &
                  " vector points to x_ray",ASSOCIATED(vector,x_ray)
        vector=>x_ray
        write(*,*)"vector associated", ASSOCIATED(vector), &
                  " vector points to x_ray",ASSOCIATED(vector,x_ray)
        write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
        write(*,*)
end subroutine
program xyz
        use aptr
        write(*,*)"in main before first call to dummy"
        if(associated(vector)) then
                write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
        call dummy(5)
        write(*,*)"back in main after first call to dummy"
        if(associated(vector)) then
                write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
        call dummy(4)
        write(*,*)"back in main after second call to dummy"
        if(ASSOCIATED(vector)) then
                write(*,*)"sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
end

