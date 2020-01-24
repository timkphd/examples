! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!   Copyright by The HDF Group.                                               *
!   Copyright by the Board of Trustees of the University of Illinois.         *
!   All rights reserved.                                                      *
!                                                                             *
!   This file is part of HDF5.  The full HDF5 copyright notice, including     *
!   terms governing use, modification, and redistribution, is contained in    *
!   the COPYING file, which can be found at the root of the source code       *
!   distribution tree, or in https://support.hdfgroup.org/ftp/HDF5/releases.  *
!   If you do not have access to either file, you may request a copy from     *
!   help@hdfgroup.org.                                                        *
! * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!
!            This program creates two files, copy1.h5, and copy2.h5.
!            In copy1.h5, it creates a 3x4 dataset called 'Copy1',
!            and write 0's to this dataset.
!            In copy2.h5, it create a 3x4 dataset called 'Copy2',
!            and write 1's to this dataset.
!            It closes both files, reopens both files, selects two
!            points in copy1.h5 and writes values to them.  Then it
!            uses an H5Scopy to write the same selection to copy2.h5.
!            Program reopens the files, and reads and prints the contents of
!            the two datasets.
!

     PROGRAM SELECTEXAMPLE

     USE HDF5 ! This module contains all necessary modules

     IMPLICIT NONE

     CHARACTER(LEN=8), PARAMETER :: filename1 = "quake.h5" ! File name
     CHARACTER(LEN=5), PARAMETER :: groupname = "quake"    ! Dataset name
     CHARACTER(LEN=3), PARAMETER :: dsetname1 = "max"    ! Dataset name
     CHARACTER(LEN=3), PARAMETER :: dsetname2 = "tot"    ! Dataset name
     CHARACTER(LEN=3), PARAMETER :: dsetname3 = "lon"    ! Dataset name
     CHARACTER(LEN=3), PARAMETER :: dsetname4 = "lat"    ! Dataset name
     
     CHARACTER(LEN=3) dsetname(4)
     

     INTEGER, PARAMETER :: RANK = 2 ! Dataset rank

     INTEGER(SIZE_T), PARAMETER :: NUMP = 2 ! Number of points selected

     INTEGER(HID_T) :: file_id        ! File1 identifier
     INTEGER(HID_T) :: dset_id(5)     ! Dataset1 identifier
     INTEGER(HID_T) :: dataspace(5)   ! Dataspace identifier
     INTEGER(HID_T) :: memspace       ! memspace identifier

     INTEGER(HSIZE_T), DIMENSION(1) :: dimsm = (/2/)
                                                   ! Memory dataspace dimensions
                                                   ! File dataspace dimensions
     INTEGER(HSIZE_T), DIMENSION(RANK,NUMP) :: coord ! Elements coordinates
                                                      ! in the file

     INTEGER, DIMENSION(6,8) :: buf1, buf2   ! Data buffers
     INTEGER, DIMENSION(6)   :: buf3         ! Data buffers
     INTEGER, DIMENSION(8)   :: buf4         ! Data buffers
     

     INTEGER :: memrank = 1  ! Rank of the dataset in memory

     INTEGER :: i, j

     INTEGER :: error  ! Error flag
     INTEGER(HSIZE_T), DIMENSION(2) :: data_dims
     INTEGER myset
     dsetname=(/'max','tot','lon','lat'/)

     !
     ! Create two files containing identical datasets. Write 0's to one
     ! and 1's to the other.
     !

     !
     ! Data initialization.
     !
     
     do i = 1, 6
          do j = 1, 8
               buf1(i,j) = i+10*j;
               buf2(i,j) = 2;
          end do
     end do

     do i = 1, 6
      buf3(i)=i*10
     enddo
     
     do i = 1, 8
      buf4(i)=i
     enddo
     !
     ! Initialize FORTRAN interface.
     !
     CALL h5open_f(error)

     !
     ! Create file using default properties.
     !
     CALL h5fcreate_f(filename1, H5F_ACC_TRUNC_F, file_id, error)

     !!!!!!!!!!!!!!!!!!!!!!!!
     do myset=1,2
     select case (myset)
     case (1)
        data_dims(1) = 6
        data_dims(2) = 8
     case (2)
        data_dims(1) = 6
        data_dims(2) = 8
     end select

     ! Create the data space for the  datasets.
     !
     CALL h5screate_simple_f(RANK, data_dims, dataspace(myset), error)
     !
     ! Create the datasets with default properties.
     !
     !
     ! Write the datasets.
     !
        CALL h5dcreate_f(file_id, dsetname(myset), H5T_NATIVE_INTEGER, dataspace(myset), dset_id(myset), error)
     select case (myset)
     case (1)
        CALL h5dwrite_f(dset_id(myset), H5T_NATIVE_INTEGER, buf1, data_dims, error)
     case(2)
         CALL h5dwrite_f(dset_id(myset), H5T_NATIVE_INTEGER, buf2, data_dims, error)
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


     !
     ! Close the files.
     !
     CALL h5fclose_f(file_id, error)


     END PROGRAM SELECTEXAMPLE
