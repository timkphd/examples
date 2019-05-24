! Program gets the num_images and this_image 
! and puts them in local variables nimg and me.
!
! It then puts "me" into the local version of the
! integer coarray, myint.
!
! It then puts "me" into the local version of a 
! character coarray, mystr, by using a write.
!
! Then we have each image write its number and the 
! character string version of its number to verify 
! correctness at this point.
! 
! We have image 1 write the image numbers stored in
! the integer coarray myint.  This works correctly.
!
! Finally image 1 tries to write the image numbers
! stored in the character coarray, mystr, and seg.
! faults.
! ...
! forrtl: severe (174): SIGSEGV, segmentation fault occurred
! Image            PC                Routine  Line     Source             
! libmpi_mt.so.4   00002B3C0EA1FFA0  Unknown  Unknown  Unknown


! Compile line and version information:
! ifort -coarray=shared bug.f90 -o bug.intel
!
! ifort -V
! Intel(R) Fortran Intel(R) 64 Compiler XE for applications 
! running on Intel(R) 64, Version 12.0.0.084 Build 20101006

! This program works correctly using the g95 and Cray compilers.

program pass_char
    implicit none
    integer me,nimg,i
    integer :: myint[*]
    character(len=8) :: mystr[*]
    nimg = num_images()
    me = this_image()
    myint=me
    write(mystr,"(i4)")me
    sync all
    write(*,'("each writes its own image id as int and str",i4,a4)')me,mystr
    sync all
    if ( me == 1) then
     do i=1,nimg
       write(*,'("1 writes its for all (as int)",i4,i4)')i,myint[i]
     enddo
     endif
    if ( me == 1) then
     do i=1,nimg
       write(*,'("1 writes its for all (as str)",i4,a4)')i,mystr[i]
     enddo
    endif
end


