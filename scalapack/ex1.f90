!LIBPATH=/opt/intel/Compiler/11.0/081/mkl/lib/em64t
!mpif90  -O1  -o ex1  ex1.f90  \
!  $(LIBPATH)/libmkl_scalapack_lp64.a \
!  $(LIBPATH)/libmkl_intel_lp64.a \
!  $(LIBPATH)/libmkl_blacs_openmpi_lp64.a \
!  $(LIBPATH)/libmkl_sequential.a \
!  $(LIBPATH)/libmkl_core.a  \
!  -lpthread


program ples
!       Parallel Linear Equation solver
!       Array A  = ( MP*MLA x NP*NLA )
!       Proc. grid is MP     x NP
!       Local mat. (al) MLA  x    NLA
!       array A(ig,jg) = 0.1*ig + 0.001*jg  (ig not= jg)
!                      = ig                 (ig    = jg)
!       Solve Ax=b, b=1
  integer, parameter    :: MP=2,MLA=4,MB=2,NP=2,NLA=4,NB=2
  integer, parameter    :: M=MLA*MP,       N=NLA*NP
  integer, dimension(10):: idescal, idescb
  real,    allocatable  :: al(:,:), b(:)
  integer, allocatable  :: ipiv(:)
  DATA               NPROW / 2 / , NPCOL / 2 /

  CALL SL_INIT( icon, NPROW, NPCOL )

!  call blacs_gridinit( icon,'c', mp, np ) !MP & NP = 2**x
  call blacs_gridinfo( icon, mp_ret, np_ret, myrow, mycol)
!  write(*,'( "(",2i2,")"," on ",i2," x",i2," grid  ", &
!        "Al(",i3,",",i3,")" )') myrow,mycol,MP,NP,MLA,NLA
  if( (MLA/MB)*MB .ne. MLA) stop 'MLA/MB not even'
  if( (NLA/NB)*NB .ne. MLA) stop 'NLA/NB not even'

  call descinit(idescal, m,n,mb,nb, 0, 0, icon, MLA, info)
  call descinit(idescb,  m,1,nb, 1, 0, 0, icon, MLA, info)


  allocate( al(MLA,NLA), ipiv(MLA+MB), b(MLA) )
  call setarray(al,myrow,mycol,4,4)
  write(*,'(i3,i3," vals",16f10.5)')myrow,mycol,al
  b=1.0
  call PSGESV(N, 1, al, 1,1,idescal, ipiv, &
                     b, 1,1,idescb,  info)
   if(mycol .eq. 0) write(*,'( "x=(",2i2,")",4(f8.4) )' ) myrow,mycol,b
   deallocate( al, ipiv, b )
   CALL BLACS_EXIT( 0 )
end program

subroutine setarray(a,myrow,mycol,lda_x, lda_y ) 
      ! distribute a matrix aa to the local arrays.
      implicit none
      real :: aa(8,8)
      real :: bb(8,1)
      integer :: lda_x, lda_y 
      real :: a(lda_x,lda_y)
      real ::ll,mm,cr,cc
      integer :: ii,jj,i,j,myrow,mycol,pr,pc,h,g
      integer , parameter :: nprow = 2, npcol = 2
      integer, parameter ::n=8,m=8,nb=2,mb=2,rsrc=0,csrc=0
      integer, parameter :: n_b = 1 
    do i=1,8
      do j=1,8
         if(i .eq. j)then
           aa(i,j)=i
         else
           aa(i,j)=0.1*i+0.001*j
         endif
      enddo
    enddo
      do i=1,m
          do j = 1,n
      ! finding out which pe gets this i,j element
              cr = real( (i-1)/mb )
              h = rsrc+aint(cr)
              pr = mod( h,nprow)
              cc = real( (j-1)/mb )
              g = csrc+aint(cc)
              pc = mod(g,nprow)
      ! check if on this pe and then set a
              if (myrow ==pr .and. mycol==pc)then
      ! ii,jj coordinates of local array element
      ! ii = x + l*mb
      ! jj = y + m*nb
                  ll = real( ( (i-1)/(nprow*mb) ) )
                  mm = real( ( (j-1)/(npcol*nb) ) )
                  ii = mod(i-1,mb) + 1 + aint(ll)*mb
                  jj = mod(j-1,nb) + 1 + aint(mm)*nb
                  a(ii,jj) = aa(i,j)
!                  write(*,12345) i,j,ii,jj,myrow,mycol
              end if
          end do
      end do
12345 format("a(",i2,",",i2,") maps to (",i2,",",i2,") on processor ",2i3)
end subroutine


