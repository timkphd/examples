! Hauksson, E. and W. Yang, and P.M. Shearer, "Waveform Relocated Earthquake Catalog for Southern California (1981 to 2011)"; Bull. Seismol. Soc. Am., Vol. 102, No. 5, pp.2239-2244, October 2012, doi:10.1785/0120120010
! 
! The locatino methods and formats are similar to what was applied by: 
! Lin, G., P. M. Shearer, and E. Hauksson (2007),Applying a three-dimensional velocity model, waveform cross 
! correlation, and cluster analysis to locate southern California seismicity from 1981 to 2005, 
! J. Geophys. Res., 112, B12309, doi:10.1029/2007JB004986.  
! 
! ONLY EARTHQUAKES are included in this file. Quarry blasts and other events have been removed.  
! 
! LOCATION FILE  FORMAT DESCRIPTION
! The locations are in the following custom format with 146 character lines:
! 
! 1981 01 01 04 13 55.710   3301565 33.25524 -115.96763   5.664  2.26  45  17   0.21   1   4   260   460      76   0.300   0.800   0.003   0.003  le ct Poly5
! where
!       1981 = year
!          1 = month
!          1 = day
!          4 = hour
!         13 = minute
!     55.710 = second
! 
!    3301565 = SCSN cuspid (up to 9 digits)
! 
!   33.25524 = latitude
! -115.96763 = longitude
!      5.664 = depth (km)
!       2.26 = SCSN calculated preferred magnitude (0.0 if unassigned)
! 
!         45 = number of P and S picks used for 1D SSST or 3D location (different from old format)
!         17 =  to nearest statino in km (different from old format)
!       0.21 = rms residual (s) for 1D location; value of 99.0 indicates information not available
! 
!          1 = local day/night flag (=0 for day, =1 for night in Calif.)
! 
!          4 = location method flag (=1 for SCSN catalog or 1d hypoinverse relocation,  
!                   =2 for 1D SSST,  =3 for 3D, =4 for waveform cross-correlation)
!              Superseeded by flag below
!        260 = similar event cluster identification number (0 if the event is not relocated with waveform cross-correlation data)
! 
!        460 = number of events in similar event cluster (0 if the event is not in similar event clusters)
! 
!       76 = number of differential times used to locate this event
! 
!      0.300 = est. std. error (km) in absolute horz. position
!      0.800 = est. std. error (km) in absolute depth
!      0.003 = est. std. error (km) in horz. position relative to other events in cluster
!      0.003 = est. std. error (km) in depth relative to other events in cluster
! 
!         le = SCSN flag for event type (le=local, qb=quarry, re=regional)
!         ct = for location method (ct=cross-correlation; 3d=3d velocity model; xx= not relocated, SCSN location used)
!       Poly5= the polygon where the earthquake is located.  We used 5 polygons to  
!              generate this catlog. 
! 
! This catalog is complete, so an attempt is made to include cluster relocated, 3D-model relocated, and not relocated earthquakes.  
! If you only want cluster relocated events, you can 'grep ct ...' to get a list of events.  
! 
! VERSIONS
! 
! 1.0) Preliminary version that still needs some quality checking.  
!      If you find issues with the catalog, please email:  hauksson@caltech.edu
! -------------------------------------------------------------------------------------------------

!  hexdump -v -e '"%d %d %d %d %d %d %d %d %d %d %d %d %d\n"' ints | head
!  hexdump -v -e '"%f %f  %f %f %f %f %f %f %f %f\n"' reals | head
!  hexdump -v -e '"%c%c %c%c %c%c%c%c%c\n"' chars | head
program fung
	integer, parameter:: b8 = selected_real_kind(14) ! basic real types
	integer year,month,day,hour,minute
	real(b8) second
	integer cuspid
	real(b8) latitude,longitude,depth,SCSN
	integer PandS,statino
	real(b8) residual
	integer tod,method, ec,nen,dt
	real(b8) stdpos,stddepth,stdhorrel,stddeprel
	character(len=10)therest
	character(len=2)le,ct
	character(len=5)poly
	character(len=32)fname,fbase
	CALL get_command_argument(1,fname)
	open(11,file=fname,status="old")	
	OPEN(UNIT=12, FILE="reals"//trim(fname), STATUS="NEW", ACCESS="STREAM")
	OPEN(UNIT=13, FILE="ints"//trim(fname), STATUS="NEW", ACCESS="STREAM")
	OPEN(UNIT=14, FILE="chars"//trim(fname), STATUS="NEW", ACCESS="STREAM")
	OPEN(UNIT=15, FILE="ascii"//trim(fname), STATUS="NEW")

	do 
	read(11,1,end=2)year,month,day,hour,minute ,& 
		second, &
		cuspid, &
		latitude,longitude,depth,SCSN, &
		PandS,statino, &
		residual, &
		tod,method, ec,nen,dt, &
		stdpos,stddepth,stdhorrel,stddeprel, &
		le,ct,poly
!		if(depth .lt. 0.0 .or. SCSN .lt. 0.0)then
	write(*,1)year,month,day,hour,minute ,& 
		second, &
		cuspid, &
		latitude,longitude,depth,SCSN, &
		PandS,statino, &
		residual, &
		tod,method, ec,nen,dt, &
		stdpos,stddepth,stdhorrel,stddeprel, &
		le,ct,poly
!		endif
	! 10 8 byte reals
	write(12)second,latitude,longitude,depth,SCSN, &
		residual,stdpos,stddepth,stdhorrel,stddeprel
	! 13 4 byte integers
	write(13)year,month,day,hour,minute,cuspid, &
		PandS,statino,tod,method,ec,nen,dt
	write(14)le,ct,poly
	write(15,"(a2,',',a2,',',a5)")le,ct,poly

 1      format(i4,4(1x,i2.2),1x,&
        f6.3,1x,i9,1x,f8.5,1x,f10.5,1x,f7.3,1x,f5.2, &
        1x,i3,1x,i3,1x,f6.2,1x,i3,1x,i3,1x,i5,1x,i5, &
        1x,i7,4(1x,f7.3),2x,a2,1x,a2,1x,a5)
        enddo 
 2 continue       
end program

