!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-422                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1996. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
      module putilities
        use cdata
        use create
        use delete
        use scatter_gather
        use bcast
        use init
        use index
        use northsouth
        use eastwest
        implicit none
!
!  All variables public by default.
!
        public
!
!   Publically accessible routines follow.
!
        public array_create
        public array_delete
        public scatter
        public gather
        public initutils
        public exitutils
        public p_context
        public sendnorthborder
        public sendsouthborder
        public sendeastborder
        public sendwestborder
        public rcvnorthborder
        public rcvsouthborder
        public rcveastborder
        public rcvwestborder
        public g2l
        public l2g

        
        interface array_create
        module procedure create_s_array, create_d_array,                   &
     &                   create_c_array, create_z_array
        end interface

        interface array_delete
        module procedure delete_s_array, delete_d_array,                   &
     &                   delete_c_array, delete_z_array
        end interface

        interface gather
        module procedure sgather,dgather,cgather,zgather
        end interface

        interface scatter
        module procedure sscatter,dscatter,cscatter,zscatter
        end interface

        interface broadcast
        module procedure broad_int, broad_double, broad_single,           &
     &                   broad_complex, broad_dcomplex,                   &
     &                   broad_iarray, broad_darray, broad_sarray,        &
     &                   broad_carray, broad_dcarray
        end interface


        interface sendnorthborder
        module procedure dsendnorth,csendnorth,ssendnorth,zsendnorth
        end interface
        
        interface sendsouthborder
        module procedure dsendsouth,csendsouth,ssendsouth,zsendsouth
        end interface
        
        interface sendeastborder
        module procedure dsendeast,ssendeast,csendeast,zsendeast
        end interface
        
        interface sendwestborder
        module procedure dsendwest,ssendwest,csendwest,zsendwest
        end interface

        
        interface rcvnorthborder
        module procedure drcvnorth,crcvnorth,srcvnorth,zrcvnorth
        end interface
        
        interface rcvsouthborder
        module procedure drcvsouth,crcvsouth,srcvsouth,zrcvsouth
        end interface
        
        interface rcveastborder
        module procedure drcveast,srcveast,crcveast,zrcveast
        end interface
        
        interface rcvwestborder
        module procedure drcvwest,srcvwest,crcvwest,zrcvwest
        end interface
        
 
      end module putilities

