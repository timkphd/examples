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

module numz
	integer, parameter:: b8 = selected_real_kind(14) ! basic real types
end module

 function quake (xin)
    use numz
    implicit none
	real(b8) x,a,b,t
	real(b8)xin
	real(b8)quake
	x=xin
     if(x < 0.1)x=0.1
     if(x >=0.1 .and. x <=2.0)then
        a=(-2.146128_b8)
        b=1.146128_b8
     else 
         if(x <= 3.0)then
            a=(-0.9058116_b8)
            b=0.5259698_b8
         else
            a=(-0.279157_b8)
            b=0.3160013_b8
         endif
     endif 
     t=a+b*x
     t=10.0_b8**t
     !write(18,*)"quake=",t
     quake=t
 end function

function atin(disin)
    use numz
    implicit none
    real(b8)dis,disin,y,x
    real(b8) atin
    dis=disin
	if(dis > 100.0)then
		y=5.333253_b8/(dis**2)
	else
		if(dis < 3.0)dis=3.0
		x=log10(dis)
		y=1.56301016_b8+x*(0.54671034_b8+x*(-0.54724666_b8))
		y=0.017535744506694952_b8*(10.8_b8**y)
	end if
	!write(18,*)"atin=",y
	atin=y
end function

! assume energy goes as (10^mag)/(d^2.5)
 function whack(latin1,lonin1,latin2,lonin2,mag,dep)
    use numz
    implicit none
    real(b8) latin1,lonin1,latin2,lonin2,mag,dep,d,i,ang,ang1
    real(b8) lat1,lon1,lat2,lon2
    real(b8) whack,quake,atin
    !write(*,*)lat1,lon1,lat2,lon2,mag,dep
	lat1=latin1*0.017453292519943295_b8
	lat2=latin2*0.017453292519943295_b8
	lon1=lonin1*0.017453292519943295_b8
	lon2=lonin2*0.017453292519943295_b8
	ang1=(sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(lon2-lon1)
	if(ang1 > 1.0_b8)ang1=1.0_b8
	ang=acos(ang1)
	d = 6377.83_b8 * ang
	d = sqrt(d*d+dep*dep)
	if(d < 3.0)d=3.0
	!write(18,*)"dis=",ang1,d,ang,dep
	if(mag > 0.0)then
!	i =(quake(mag))/(d^2.5)
	i =atin(d)*(quake(mag))
	else
	i=0
	endif
	!write(*,*)"whack=",i
	whack=i
end function
program fung
	use numz
    implicit none
    logical dowrite
	integer iline,mline,i,j
	real(b8) dx
	real(b8)mylat,mylon,dep,mag,ouch,slat,slon,whack,dummy
!$IFDEF _OPENMP
	integer omp_get_thread_num
!$ENDIF
	integer year,month,day,hour,minute
	real(b8) second
	integer cuspid
	real(b8), allocatable:: latitude(:),longitude(:),depth(:),SCSN(:)
	real(b8), allocatable:: lon_seq(:),lat_seq(:)
	real(b8),allocatable:: mytot(:,:),mymax(:,:)
	integer dlat,dlon
	real(b8)latb(20),lonb(2)
	integer PandS,statino
	real(b8) residual
	integer tod,method, ec,nen,dt
	real(b8) stdpos,stddepth,stdhorrel,stddeprel
	character(len=10)therest
	character(len=2)le,ct
	character(len=5)poly
	character(len=32)fname,fbase
	dowrite=.false.
	CALL get_command_argument(1,fname)
	open(11,file=fname,status="old")	
	if(dowrite)then
	OPEN(UNIT=12, FILE="reals"//trim(fname), STATUS="unknown", ACCESS="STREAM")
	OPEN(UNIT=13, FILE="ints"//trim(fname), STATUS="unknown", ACCESS="STREAM")
	OPEN(UNIT=14, FILE="chars"//trim(fname), STATUS="unknown", ACCESS="STREAM")
	OPEN(UNIT=15, FILE="ascii"//trim(fname), STATUS="unknown")
	endif
    iline=0
    mline=700000
    allocate(latitude(mline))
    allocate(longitude(mline))
    allocate(depth(mline))
    allocate(SCSN(mline))
	do 
	iline=iline+1
	read(11,1,end=2)year,month,day,hour,minute ,& 
		second, &
		cuspid, &
		latitude(iline),longitude(iline),depth(iline),SCSN(iline), &
		PandS,statino, &
		residual, &
		tod,method, ec,nen,dt, &
		stdpos,stddepth,stdhorrel,stddeprel, &
		le,ct,poly
!		if(depth .lt. 0.0 .or. SCSN .lt. 0.0)then
	if(dowrite)then
	write(*,1)year,month,day,hour,minute ,& 
		second, &
		cuspid, &
		latitude(iline),longitude(iline),depth(iline),SCSN(iline), &
		PandS,statino, &
		residual, &
		tod,method, ec,nen,dt, &
		stdpos,stddepth,stdhorrel,stddeprel, &
		le,ct,poly
!		endif
	! 10 8 byte reals
	write(12)second,latitude(iline),longitude(iline),depth(iline),SCSN(iline), &
		residual,stdpos,stddepth,stdhorrel,stddeprel
	! 13 4 byte integers
	write(13)year,month,day,hour,minute,cuspid, &
		PandS,statino,tod,method,ec,nen,dt
	write(14)le,ct,poly
	write(15,"(a2,',',a2,',',a5)")le,ct,poly
	endif

 1      format(i4,4(1x,i2.2),1x,&
        f6.3,1x,i9,1x,f8.5,1x,f10.5,1x,f7.3,1x,f5.2, &
        1x,i3,1x,i3,1x,f6.2,1x,i3,1x,i3,1x,i5,1x,i5, &
        1x,i7,4(1x,f7.3),2x,a2,1x,a2,1x,a5)
        enddo 
 2 continue    
 iline=iline-1
 write(*,*)latitude(iline),longitude(iline),depth(iline),SCSN(iline) 
 latb(1)=35.0;latb(2)=32.0  
 lonb(1)=-121.0;lonb(2)=-115.0
 dlon=16
 dlat=8
 if(.true.)then
 open(17,file="bounds")
 read(17,*)latb(1),latb(2),dlat
 read(17,*)lonb(1),lonb(2),dlon
 endif
 allocate(lat_seq(dlat))
 allocate(lon_seq(dlon))
 dx=(lonb(2)-lonb(1))/(dlon-1)
 do i=1,dlon
 	lon_seq(i)=lonb(1)+(i-1)*dx
 enddo 
 write(*,'(5f10.4)')lon_seq
 dx=(latb(2)-latb(1))/(dlat-1)
 do i=1,dlat
 	lat_seq(i)=latb(1)+(i-1)*dx
 enddo 
 write(*,'(5f10.4)')lat_seq
 !allocate(mytot(dlon,dlat))
 !allocate(mymax(dlon,dlat))
 allocate(mytot(dlat,dlon))
 allocate(mymax(dlat,dlon))
 mytot=0.0
 mymax=0.0
!$OMP PARALLEL do private(mylat,mylon,ouch,slat,slon,mag,dep,i,j) reduction(+: mytot) reduction(max: mymax)
  do mline=1,iline
!    if (mod(mline,1000) .eq. 0)write(*,*)mline,iline,omp_get_thread_num()
    if (mod(mline,1000) .eq. 0)write(*,*)mline,iline
    slat=latitude(mline)
    slon=longitude(mline)
    mag=SCSN(mline)
    dep=depth(mline)
    do i=1,dlat
    	mylat=lat_seq(i)
    	do j=1,dlon
        	mylon=lon_seq(j)
    	  	ouch=whack(mylat,mylon,slat,slon,mag,dep)
    	  	if(ouch > mymax(i,j))mymax(i,j)=ouch
    	 	 mytot(i,j)=mytot(i,j)+ouch
    	enddo
    enddo
 enddo
!$OMP END PARALLEL do
open(18,file="mymax")
open(19,file="mytot")
    do i=1,dlat
    	mylat=lat_seq(i)
    	do j=1,dlon
        	mylon=lon_seq(j)
        	!write(*,*)mylat,mylon,mytot(i,j),mymax(i,j)
        	write(18,'(e15.7)',advance="no")mymax(i,j)
        	write(19,'(e15.7)',advance="no")mytot(i,j)
        	if(j==dlon)then
        		write(18,*)
        		write(19,*)
        	endif
        	enddo
        enddo


	write(*,*)"at",lat_seq(1),lon_seq(1),"sum=",mytot(1,1),"max=",mymax(1,1)
	write(*,*)"at",lat_seq(1),lon_seq(dlon),"sum=",mytot(1,dlon),"max=",mymax(1,dlon)
	write(*,*)"at",lat_seq(dlat),lon_seq(1),"sum=",mytot(dlat,1),"max=",mymax(dlat,1)
	write(*,*)"at",lat_seq(dlat),lon_seq(dlon),"sum=",mytot(dlat,dlon),"max=",mymax(dlat,dlon)
end program

