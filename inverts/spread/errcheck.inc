!*******************************************************************************
!                             INTEL CONFIDENTIAL
!  Copyright(C) 2001-2010 Intel Corporation. All Rights Reserved.
!  The source code contained  or  described herein and all documents related to
!  the source code ("Material") are owned by Intel Corporation or its suppliers
!  or licensors.  Title to the  Material remains with  Intel Corporation or its
!  suppliers and licensors. The Material contains trade secrets and proprietary
!  and  confidential  information of  Intel or its suppliers and licensors. The
!  Material  is  protected  by  worldwide  copyright  and trade secret laws and
!  treaty  provisions. No part of the Material may be used, copied, reproduced,
!  modified, published, uploaded, posted, transmitted, distributed or disclosed
!  in any way without Intel's prior express written permission.
!  No license  under any  patent, copyright, trade secret or other intellectual
!  property right is granted to or conferred upon you by disclosure or delivery
!  of the Materials,  either expressly, by implication, inducement, estoppel or
!  otherwise.  Any  license  under  such  intellectual property  rights must be
!  express and approved by Intel in writing.
!
!*******************************************************************************

      SUBROUTINE CheckVslError( num )

        USE MKL_VSL_TYPE
        INTEGER(KIND=4) :: num


      if ( num == VSL_ERROR_FEATURE_NOT_IMPLEMENTED ) then
        print 33, "Error: this feature not implemented yet (code ",     &
     &             num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_UNKNOWN ) then
        print 33, "Error: unknown error (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BADARGS ) then
        print 33, "Error: bad arguments (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_MEM_FAILURE ) then
        print 33, "Error: memory failure. Memory allocation problem",   &
     &            " maybe (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_NULL_PTR ) then
        print 33, "Error: null pointer (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_INVALID_BRNG_INDEX ) then
        print 33, "Error: invalid BRNG index (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_LEAPFROG_UNSUPPORTED ) then
        print 33, "Error: leapfrog initialization is unsupported",      &
     &            " (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_SKIPAHEAD_UNSUPPORTED ) then
        print 33, "Error: skipahead initialization is unsupported",     &
     &            " (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BRNGS_INCOMPATIBLE ) then
        print 33, "Error: BRNGs are not compatible for the operation",  &
     &            " (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_STREAM ) then
        print 33, "Error: random stream is invalid (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BRNG_TABLE_FULL ) then
        print 33, "Error: table of registered BRNGs is full (code ",    &
     &             num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_STREAM_STATE_SIZE ) then
        print 33, "Error: value in StreamStateSize field is bad",       &
     &            " (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_WORD_SIZE ) then
        print 33, "Error: value in WordSize field is bad (code ",       &
     &             num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_NSEEDS ) then
        print 33, "Error: value in NSeeds field is bad (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_NBITS ) then
        print 33, "Error: value in NBits field is bad (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_UPDATE ) then
        print 33, "Error: number of updated entries in buffer is",      &
     &            " invalid (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_NO_NUMBERS ) then
        print 33, "Error: zero number of updated entries in buffer",    &
     &            " (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_INVALID_ABSTRACT_STREAM ) then
        print 33, "Error: abstract random stream is invalid (code ",    &
     &             num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_FILE_CLOSE ) then
        print 33, "Error: can`t close file (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_FILE_OPEN ) then
        print 33, "Error: can`t open file (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_FILE_WRITE ) then
        print 33, "Error: can`t write to file (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_FILE_READ ) then
        print 33, "Error: can`t read from file (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_BAD_FILE_FORMAT ) then
        print 33, "Error: file format is unknown (code ",num,")."
        stop 1
      end if

      if ( num == VSL_ERROR_UNSUPPORTED_FILE_VER ) then
        print 33, "Error: unsupported file version (code ",num,")."
        stop 1
      end if

33    format(A,I5,A)

      END SUBROUTINE
