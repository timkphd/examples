!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    5765-C41                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1997. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
	program image
        use putilities
        implicit none
!
!  This is a simple example program showing the real to complex
!  and complex to real Fourier transforms.
! 
!  It well known that a the following correlation 
!      
!   C(x,y) = FTINV(H(u,v)*G(u,v))
!
!     where H is the 2-d Fourier transform of a target image h(x,y)
!           G is the complex conjugate of the 2-d Fourier transform of 
!           a refererence image g(x,y)
!           and FTINV represents the 2d inverse Fourier transform
!   provides a measure of the similarity between the images. If the resulting
!   correlation has no peak the images have little in common. The size
!   and location of any peak in C(x,y) provides information on how similar
!   the target image is to the reference image and to any rotation or
!   scale changes of the reference image to the target image.
!
!   Subroutines call:
!      array_create   from the utilitity library
!      blacs_pinfo    from the blacs library
!      pcrft2         from pessl
!      prcft2         from pessl
!
       integer, parameter       :: xsize=1024, ysize=1024
       real(long_t), pointer    :: target_image(:,:), ref_image(:,:)
       real(long_t), pointer    :: correlation(:,:)
       complex(long_t), pointer :: target_xform(:,:), ref_xform(:,:)
       complex(long_t), pointer :: correlation_xform(:,:)
       complex(long_t), pointer :: frow1(:),frow2(:),lrow1(:),lrow2(:)
       integer                  :: ip(40)
       integer                  :: desc(DESC_DIM)  ! dummy descriptor 
       integer                  :: iam, nprocs, status, i, j

!
!  create interface block for all subroutines which follow
!
       INTERFACE

       subroutine unpack(xform,frow,lrow)
       use putilities
         complex(long_t), intent(out) :: frow(:), lrow(:)
         complex(long_t), intent(in)  :: xform(:,:)
       end subroutine unpack

       subroutine pack(xform,frow,lrow)
       use putilities
         complex(long_t), intent(in)  :: frow(:), lrow(:)
         complex(long_t), intent(out) :: xform(:,:)
       end subroutine pack

       subroutine filter(image)
       use putilities
       implicit none
       complex(long_t), intent(inout) :: image(:,:)
       end subroutine filter
   

       subroutine get_target_image(image)
       use putilities
       implicit none
       real(long_t), intent(inout) :: image(:,:)
       end subroutine get_target_image
   

       subroutine get_ref_image(image)
       use putilities
       implicit none
       real(long_t), intent(inout) :: image(:,:)
       end subroutine get_ref_image
   

       END INTERFACE


!
!  initialize system
!
       call blacs_pinfo(iam,nprocs)
       call initutils(status,npcs=nprocs)
!
!   check that the number of processors evenly divide ysize and xsize/2
!
       if ( xsize .ne. 2*nprocs*(xsize/(2*nprocs)) ) then
         if( iam.eq.0) then
           write(*,*)'2*nprocs must evenly divide xsize'
         endif
         call blacs_abort(p_context(),1)
       endif

       if ( ysize .ne. nprocs*(ysize/nprocs) ) then
         if( iam.eq.0) then
           write(*,*)'nprocs must evenly divide ysize'
         endif
         call blacs_abort(p_context(),1)
       endif

       if( status .ne. 0 ) then
         if(iam.eq.0)write(*,*) 'communication initilization failure'
         call blacs_abort(p_context(),1)
       endif

!
!  allocate data for images
!

       call array_create(target_image,desc,xsize,ysize,CREATE_BLOCK)
       call array_create(ref_image,desc,xsize,ysize,CREATE_BLOCK)
       call array_create(correlation,desc,xsize,ysize,CREATE_BLOCK)
       call array_create(target_xform,desc,ysize,xsize/2,CREATE_BLOCK)
       call array_create(ref_xform,desc,ysize,xsize/2,CREATE_BLOCK)
       call array_create(correlation_xform,desc,ysize,xsize/2,             &
     &                   CREATE_BLOCK)

!
!  get the target image
!
       call get_target_image(target_image)
!
!  use default values
!
       ip = 0
       
!
!      call 2d Fourier real to complex transform
!
       call pdrcft2(target_image,target_xform,xsize,ysize,1,1.d0,           &
     &              p_context(),ip)

       call filter(target_xform)

!
!  get the reference image
!
       call get_ref_image(ref_image)
!
!      call 2d Fourier real to complex transform
!
       call pdrcft2(ref_image,ref_xform,xsize,ysize,1,1.d0,                &
     &              p_context(),ip)

!
!      multiply the two xforms together to get the correlation xform
!

       if(iam .eq. 0 ) then
!
!  processor 0 will have the first and last column stored in 
!  packed format 
!
         allocate(frow1(ysize))
         allocate(frow2(ysize))
         allocate(lrow1(ysize))
         allocate(lrow2(ysize))

!
!   unpack target transform
!
         call unpack(target_xform,frow1,lrow1)
         call unpack(ref_xform,frow2,lrow2)
         
         do i = 1, ysize
           frow1(i) = frow1(i) * conjg(frow2(i))
           lrow1(i) = lrow1(i) * conjg(lrow2(i))
         enddo

         do j = 2, xsize/(2*nprocs)
           do i = 1, ysize
             correlation_xform(i,j) = target_xform(i,j) *                     &
     &                                conjg(ref_xform(i,j))
           enddo
         enddo

         call pack(correlation_xform,frow1,lrow1)
         deallocate(frow1)
         deallocate(frow2)
         deallocate(lrow1)
         deallocate(lrow2)

       else   ! My processor doesn't have the messy row

         do j = 1, xsize/(2*nprocs)
           do i = 1, ysize
             correlation_xform(i,j) = target_xform(i,j) *                     &
     &                                conjg(ref_xform(i,j))
           enddo
         enddo
       endif

!
!  correlation_xform now has the 2d transform of the image corrlation
!
       call pdcrft2(correlation_xform,correlation,xsize,ysize,                &
     &              -1, 1.d0/(xsize*ysize),p_context(),ip)

!
!  correlation now has the correlation array
!
       if(iam .eq. 0) then
         write(*,*)'The 1,1 correlation element is ', correlation(1,1)
       endif

!
! clean up space
!
       deallocate(target_image)
       deallocate(ref_image)
       deallocate(correlation)
       deallocate(target_xform)
       deallocate(ref_xform)
       deallocate(correlation_xform)
!
!  end blacs
!
       call exitutils(0)
       
!
!  end program
!
       stop
       end 

!
!  subroutine to unpack row 1 and row n2/2 + 1 of a complex
!  transform in packed format
!
       subroutine unpack(xform,frow,lrow)
       use putilities
       implicit none
       complex(long_t), intent(out) :: frow(:), lrow(:)
       complex(long_t), intent(in)  :: xform(:,:)
!
!  input:
!      xform  :: the transform in packed format
!      frow   :: first row of transform in unpacked format
!      lrow   :: last row of transform in unpacked format
!  note: This routine should be only called from the first processor
!        since only processor 0 will have the packed row of the
!        transform
!
!
       integer                      :: ysize, i, j

       ysize = size(xform,1)
       if( size(frow) .ne. ysize .or. size(lrow) .ne. ysize) then 
         write(*,*) 'size mismatch in unpack'
         call blacs_abort(p_context(),1)
       endif

!
!  unpack the first row 
!  rows appear to be columns because the transformed array
!  is stored in transpose format
!
       frow(1) = real(xform(1,1))
       frow(ysize/2+1) = imag(xform(1,1))
       frow(2:ysize/2) = xform(2:ysize/2,1)
       frow(ysize/2+2:ysize) = conjg(frow(2:ysize/2))

!
!  unpack the last row 
!
       lrow(1) = real(xform(ysize/2+1,1))
       lrow(ysize/2+1) = imag(xform(ysize/2+1,1))
       lrow(2:ysize/2) = xform(ysize/2+2:ysize,1)
       lrow(ysize/2+2:ysize) = conjg(lrow(2:ysize/2))
       return
       end subroutine unpack


!
!  subroutine to pack row 1 and row n2/2 + 1 of a complex
!  transform into packed format
!
       subroutine pack(xform,frow,lrow)
       use putilities
       implicit none
       complex(long_t), intent(in)  :: frow(:), lrow(:)
       complex(long_t), intent(out) :: xform(:,:)
!
!  input:
!      xform  :: the transform in packed format
!      frow   :: first row of transform in unpacked format
!      lrow   :: last row of transform in unpacked format
!  note: This routine should be only called from the first processor
!        since only processor 0 will have the packed row of the
!        transform
!
!
       integer                      :: ysize, i, j

       ysize = size(xform,1)
       if( size(frow) .ne. ysize .or. size(lrow) .ne. ysize) then 
         write(*,*) 'size mismatch in unpack'
         call blacs_abort(p_context(),1)
       endif

!
!  pack the first row 
!  rows appear to be columns because the transformed array
!  is stored in transpose format
!
       xform(1,1) = cmplx(real(frow(1)),real(frow(ysize/2+1)))
       xform(2:ysize/2,1) = frow(2:ysize/2)

!
!  pack the last row 
!
       xform(ysize/2+1,1) = cmplx(real(lrow(1)),real(lrow(ysize/2+1)))
       xform(ysize/2+2:ysize,1) = lrow(2:ysize/2)
       return
       end subroutine pack

       subroutine get_target_image(image)
       use putilities
       implicit none
       real(long_t), intent(out)   :: image(:,:)
       integer i, j

!
!      get a target image
!

       image  =  0.d0

!
!  create a horizontal bar
!
       do  j = 1, size(image,2)
        do i = size(image,1)/3, size(image,1)/2
           image(i,j) = 1.d0
        enddo
       enddo
       return
       end subroutine get_target_image

       subroutine get_ref_image(image)
       use putilities
       implicit none
       real(long_t), intent(out)   :: image(:,:)
       integer i, j

!
!      get a reference image
!

       image  =  0.d0

!
!  create a horizontal bar
!
       do  j = 1, size(image,2)
        do i = size(image,1)/3, size(image,1)/2
           image(i,j) = 1.d0
        enddo
       enddo
       return
       end subroutine get_ref_image

       subroutine filter(image)
       use putilities
       implicit none
       complex(long_t), intent(inout) :: image(:,:)

!
!      apply any sort of image filter
!      in this case, we have a null routine
!

       return
       end subroutine filter



