! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!   Copyright by The HDF Group.                                               *
!   Copyright by the Board of Trustees of the University of Illinois.         *
!   All rights reserved.                                                      *
! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *



    PROGRAM QUAKE

    USE HDF5 ! This module contains all necessary modules

    IMPLICIT NONE

    INTEGER, PARAMETER :: b8 = SELECTED_REAL_KIND(15,307) ! This should map to REAL*8 
                                                          ! on most modern processors
    CHARACTER(LEN=8), PARAMETER :: filename1 = "quake.h5" ! File name
    CHARACTER(LEN=5), PARAMETER :: groupname = "quake"    ! group name

    CHARACTER(LEN=3) dsetname(4) ! Dataset names

    INTEGER(HID_T) :: group_id      ! Group identifier

    INTEGER(HID_T) :: file_id        ! File identifier
    INTEGER(HID_T) :: dset_id(5)     ! Dataset identifier
    INTEGER(HID_T) :: dataspace(5)   ! Dataspace identifier


    REAL(b8), DIMENSION(6,8) :: buf1, buf2   ! Data buffers
    REAL(b8), DIMENSION(6)   :: buf3         
    REAL(b8), DIMENSION(8)   :: buf4  
           
    INTEGER(HSIZE_T), DIMENSION(2) :: data_dims   ! Dimensions for buffers
    INTEGER(HSIZE_T), DIMENSION(1) :: data_1



    INTEGER :: i, j,myset

    INTEGER :: error  ! Error flag

    dsetname=(/'max','tot','lon','lat'/)    ! Dataset names

!
! Data initialization.
!

    do i = 1, 6
        do j = 1, 8
            buf1(i,j) = real(i,b8)+((10._b8)*real(j,b8))+0.1_b8
            buf2(i,j) = real(2,b8)
        end do
    end do

    do i = 1, 6
        buf3(i)=real(i,b8)/10._b8
    enddo

    do i = 1, 8
        buf4(i)=real(i,b8)/2._b8
    enddo
!
! Initialize FORTRAN interface.
!
    CALL h5open_f(error)

!
! Create file using default properties.
!
    CALL h5fcreate_f(filename1, H5F_ACC_TRUNC_F, file_id, error)

!
! Create a group named groupname in the file.
!
    CALL h5gcreate_f(file_id, groupname, group_id, error)

!
! Output 4 sets.
!
    do myset=1,4
        write(*,*)"doing ",myset,groupname//"/"//dsetname(myset)
        select case (myset)
            case (1,2)
                data_dims(1) = 6
                data_dims(2) = 8
            case (3)
                data_1(1) = 6
            case (4)
                data_1(1) = 8
        end select
!
! Create the data space for the  datasets.
!
        select case (myset)
            case (1,2)
                CALL h5screate_simple_f(2, data_dims, dataspace(myset), error)
            case (3,4)
                CALL h5screate_simple_f(1, data_1,    dataspace(myset), error)
        end select
!
! Create the datasets with default properties.
!
        CALL h5dcreate_f(file_id, groupname//"/"//dsetname(myset), &
                         H5T_NATIVE_DOUBLE, dataspace(myset), dset_id(myset), error)
!
! Write the datasets.
!
        select case (myset)
            case (1)
                CALL h5dwrite_f(dset_id(myset), H5T_NATIVE_DOUBLE, buf1, data_dims, error)
            case(2)
                CALL h5dwrite_f(dset_id(myset), H5T_NATIVE_DOUBLE, buf2, data_dims, error)
            case(3)
                CALL h5dwrite_f(dset_id(myset), H5T_NATIVE_DOUBLE, buf3, data_1, error)
            case(4)
                CALL h5dwrite_f(dset_id(myset), H5T_NATIVE_DOUBLE, buf4, data_1, error)
        end select

!
! Close the dataspace for the datasets.
!
        CALL h5sclose_f(dataspace(myset), error)

!
! Close the datasets.
!
        CALL h5dclose_f(dset_id(myset), error)
    enddo

    CALL h5gclose_f(group_id, error)

!
! Close the files.
!
     CALL h5fclose_f(file_id, error)


     END PROGRAM QUAKE
