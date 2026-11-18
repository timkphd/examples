!This program was written to show different behaviors of
!various compilers when a allocatable array goes out of
!scope.  The f90 standard does not specify what happens
!in this case.  f95 and later specify that arrays are
!deallocated when they go out of scope.  The issue here
!is that x_ray goes out of scope but vector still points
!to it.  vector points to an invalid memory address.  
!For some compilers it looks like the program "works"
!but is clearly buggy.  
!
!The progam can be "fixed" by uncommenting the !save line.
!You can also set compilers to autosave but I would not
!recommend doing so because it lead to portability issues.
module aptr
        integer, POINTER, DIMENSION(:) :: vector 
end module
subroutine dummy(i,k)
        use aptr
        !save
        integer, allocatable,target :: x_ray(:)
        write(*,*)"in subroutine....call ",k
        write(*,*)"vector associated", ASSOCIATED(vector)
        write(*,*)"x_ray allocated ",allocated(x_ray)
        write(*,*)"vector ",vector
        !write(*,*)"x_ray  ",x_ray
        if(.not. allocated(x_ray))allocate(x_ray(i))
        x_ray=-1
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
        write(*,*)"in main before call to subroutine"
        nullify(vector)
        if(associated(vector)) then
                write(*,*)"s0 sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)"v0",vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
        call dummy(5,1)
        write(*,*)"back in main after first call to subroutine"
        if(associated(vector)) then
                write(*,*)"s1 sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)"v1",vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
        call dummy(4,2)
        write(*,*)"back in main after second call to subroutine"
        if(ASSOCIATED(vector)) then
                write(*,*)"s2 sum(vector)",sum(vector),ASSOCIATED(vector)
                write(*,*)"v2",vector
        else
                write(*,*)"vector not ASSOCIATED"
        endif
end

! echo +++++++++++++++++++++++++++++++++++++ 
! for f in "ifx" \
!   "gfortran"   \
!   "pgf95"      \
!   "amdflang"   \
!   "ifx       -noauto"                 \
!   "gfortran  -fno-automatic"          \
!   "pgf95     -Msave"                  \
!   "amdflang  -fno-automatic"          ; do 
!       echo $f      
!       $f test1.f90 
!       ./a.out       
!       echo +++++++++++++++++++++++++++++++++++++ 
! done

