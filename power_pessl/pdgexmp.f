!**********************************************************************
!    LICENSED MATERIALS - PROPERTY OF IBM                             *
!    "RESTRICTED MATERIALS OF IBM"                                    *
!                                                                     *
!    5765-C41                                                         *
!    (C) COPYRIGHT IBM CORP. 1995, 1997. ALL RIGHTS RESERVED.         *
!                                                                     *
!    U.S. GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION       *
!    OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE CONTRACT WITH       *
!    IBM CORP.                                                        *
!**********************************************************************
      program pdgexmp
      use putilities
!
!   calculate the performance of linear algebra solvers for 
!   different block sizes, matrix sizes and processor configurations
!
!   Subroutines called
!     array_create   from utility library
!     broadcast      from utility library
!     initutils      from utility library
!     exitutils      from utility library
!     g2l            from utility library
!     blacs_pinfo    from blacs library
!     blacs_gridinfo from blacs library 
!     blacs_barrier  from blacs library
!     dgsum2d        from blacs library
!     dgamx2d        from blacs library
!     numroc         from pessl library
!     pdgemm         from pessl library
!     pdgetrf        from pessl library
!     pdgetrs        from pessl library
!
      implicit none

!     .. parameters ..
      real(long_t), parameter :: zero=0.d0, one=1.d0
      integer, parameter      :: ia=1, ja=1, ib=1, jb=1, ix=1, jx=1

!     .. local arrays
      real(long_t), pointer :: a(:,:), b(:,:), x(:,:)
      integer          adesc(DESC_DIM), bdesc(DESC_DIM), xdesc(DESC_DIM)
      integer, allocatable   ::         ipiv(:)

!     .. local scalars ..
      real(long_t)       :: tf, t1, err, ts, t0, flf, xnrm, err2, fls
      real(long_t)       :: tmnull
      integer            :: icm, me, irm, i, j, imat
      integer            :: nprocs, n, nb, nrhs, ncases, nprows, status
      integer            :: npcols, mycol, myrow, ircode
      integer            :: iret, nqx, nbrhs, mpx
      integer            :: ierrcount, iam

!    .. external functions
      integer            :: numroc
      external           numroc
      real(long_t)       :: funca, funcx, timef, dnrm2
      external           funca, funcx, timef, dnrm2
!
!     interface block for local routines
!
      INTERFACE
        subroutine get2norm(x,b,mpx,nqx,err)
        use putilities
        real(long_t)    :: x(:,:), b(:,:)
        real(long_t)    :: err
        integer         :: mpx, nqx
        end subroutine get2norm
      END INTERFACE

!
!  set up communication will all the processors
!

      call blacs_pinfo(iam,nprocs)
!
!     the main input file
!
      do nprows = 1, nprocs
        npcols = nprocs/nprows
        if( nprows*npcols .ne. nprocs) cycle
        if (iam.eq.0) then 
         open (10,file='pdgexmp.inp')
         read (10,fmt=*) ncases
         read (10,fmt=*)
         nprocs = nprows*npcols
        endif
      
!
!  initialize using all of the target number of rows and columns
!
        call initutils(status,nprows,npcols)
        if(status .ne. 0 ) then
          write(*,*) 'Failed to initialize communication'
          stop 1
        endif
        call broadcast(ncases,0,0)

        call blacs_gridinfo(p_context(),nprows,npcols,myrow,mycol)
 
!
!     the report header
!
       if (myrow.eq.0 .and. mycol.eq.0) then 
         write (6,fmt=*) 'number of processors: ', nprocs
         write (6,fmt=*) 'processor array shape: ',nprows,' by ',npcols
         write (6,fmt=*)
         write (6,fmt=99997) 'n','nrhs','nb','nbrhs','time f','time s',
     +      'mflops f', 'mflops s','err'
       endif 
!

!
!     calculate timing overhead
!
      tmnull = timef()
      tmnull = timef() - tmnull

!
!     loop over all requests
!
       do imat = 1, ncases

         if (myrow.eq.0 .and.mycol .eq. 0) then 
            read (10,fmt=*) n, nrhs, nb, nbrhs
         endif
!
!  make sure everyone has the same problem size
!
         call broadcast(n,0,0)
         call broadcast(nrhs,0,0)
         call broadcast(nb,0,0)
         call broadcast(nbrhs,0,0)
   
         call array_create(a,adesc,n,n,CREATE_CYCLIC,nb,nb)
         call array_create(b,bdesc,n,nrhs,CREATE_CYCLIC,nb,nbrhs)
         call array_create(x,xdesc,n,nrhs,CREATE_CYCLIC,nb,nbrhs)

         mpx = numroc(xdesc(M_),xdesc(MB_),myrow,xdesc(RSRC_),nprows)
         nqx = numroc(xdesc(N_),xdesc(NB_),mycol,xdesc(CSRC_),npcols)

!
! we will not alway need n elements for the pivot vector, but
! it is always sufficient.
!
          allocate(ipiv(n),stat=ircode)
          if (ircode.ne.0) then 
             write(0,*) 'error: memory allocation failure '
             call blacs_abort(p_context(),1)
          endif
!
!        generate two matrices a and x 
!
         call pdgegen(funca,n,n,a,ia,ja,adesc,iret)
!
! if maxtrix generation fails, abort
         if(iret.ne.0) call blacs_abort(p_context(),1)
!
         call pdgegen(funcx,n,nrhs,x,ix,jx,xdesc,iret)
!
! if maxtrix generation fails, abort
         if(iret.ne.0) call blacs_abort(p_context(),1)
!
         
         
!
!       generate a rhs against a known solution
!
         call pdgemm('no transpose','no transpose',n,nrhs,n,
     +      one,a,ia,ja,adesc,x,ix,jx,xdesc,
     +      zero,b,ib,jb,bdesc)

!
!      factor the coefficient matrix
!      
         call blacs_barrier(p_context(),'all')
         t0 = timef()
         call pdgetrf(n,n,a,ia,ja,adesc,ipiv,iret)          
         t1 = timef()
         tf = (t1-t0-tmnull)/1.d3
!
!      solve for the rhs.
!
         if (iret.eq.0) then 
            call blacs_barrier(p_context(),'all')
            t0 = timef()
            call pdgetrs('no transpose',n,nrhs,
     +         a,ia,ja,adesc,ipiv,
     +         b,ib,jb,bdesc,iret)          
            t1 = timef()
            ts = (t1-t0-tmnull)/1.d3
!
!       check the result  for correctness and print error.
!       define error as  ||bx-x||/||x||
!
            call get2norm(x,b,mpx,nqx,err)
            call dgamx2d(p_context(),'all','1-tree',1,1,tf,1,irm,            &
     &                  icm,1,0,0)
            call dgamx2d(p_context(),'all','1-tree',1,1,ts,1,irm,            &
     &                  icm,1,0,0)
            flf = (((2./3.)*(dble(n)**3.))/tf)*1.d-6
            fls = (dble(nrhs)*(2.*dble(n)**2.)/ts)*1.d-6
         else 
            write(0,*)
     +         'factorization error: no solution will take place'
            call dgamx2d(p_context(),'all','1-tree',1,1,tf,1,irm,         &
     &            icm,1,0,0)
            ts  = zero
            err = zero
            flf = (((2./3.)*(dble(n)**3.))/tf)*1.d-6
            fls = zero
         endif

         
         if ((myrow.eq.0).and.(mycol.eq.0)) then 
            write(6,fmt=99996) n, nrhs,nb,nbrhs, tf,ts,
     +         flf,fls,err            
         endif
!
         deallocate(ipiv)
         deallocate(a)
         deallocate(b)
         deallocate(x)
        enddo

        call exitutils
        close(10)
      enddo
!
      call exitutils(0)
      stop
!
!
99997 format (4(a6,1x),4(a8,1x),a10)
99996 format (4(i6,1x),2(f8.2,1x),2(f8.0,1x),e10.3)
      end
      double precision function funca(i,j,m,n)
      
      funca = 3.d0 +
     +   sqrt(abs(dble(i)-dble(j)))/sqrt(dble(max(m,n)))
      return
      end
      double precision function funcx(i,j,m,n)
      
      funcx = dble(i)*dble(j)
      return
      end

      subroutine pdgegen(func,m,n,a,ia,ja,adesc,ierr)
!     .. scalar arguments ..
      use putilities
      integer  m, n, ia, ja, ierr
    
!     .. 
!     .. array arguments ..
      integer   adesc(DESC_DIM)
     
      double precision a(adesc(LLD_),*)
      integer, allocatable :: ig(:), jg(:)
!     .. 
!     .. function arguments ..
!*********************************************
!*                                           *
!* for pdgegen the func interface is :       *
!*                                           *
!*     double precision func (i,j,m,n)       *
!*                                           *
!*********************************************
      double precision func
      external         func
!     .. 
!     .. local scalars ..
      integer     i, j, jb, mb, nb
     +   irsr, icsr, icontxt, m_a, n_a, ii, jj, i1, j1, ib,
     +   ioff, joff, ip0, jp0, il, jl
!     .. 
      
!

      ierr = 0 
      m_a   = adesc(M_)
      n_a   = adesc(N_)
      mb    = adesc(MB_)
      nb    = adesc(NB_)
      irsr  = adesc(RSRC_)
      icsr  = adesc(CSRC_)


      if ((mb<=0).or.(nb<=0)) then 
               write(0,*)
     +      'error: invalid block sizes'
         ierr = 1
         return
      endif

      if  ((ia+m-1.gt.m_a).or.(ja+n-1.gt.n_a).or.
     +   (ia.lt.1).or.(ja.lt.1)) then 
         write(0,*)
     +      'error: submatrix specification outside matrix bounds',
     +      ia,ia+m-1,m_a,ja,ja+n-1,n_a
         ierr = 2
         return
      endif

!
!    throughout the loop i,j are global pointers,
!    il, jl are local pointers
!      
      allocate(ig(m_a))
      allocate(jg(n_a))
      call g2l(adesc,ig,jg)

      do j = ja, ja+n-1
         if (jg(j) .ne. -1) then 
            do i = ia, ia+m-1
               if (ig(i) .ne. -1) then 
                  a(ig(i),jg(j)) = func(i,j,m,n)
               endif
            enddo
         endif  
      enddo
      deallocate(ig)
      deallocate(jg)
      return
      end

      subroutine get2norm(x,b,mpx,nqx,err)
      use putilities
      implicit none
!
!  calculate 2-norm for ||x-b||
!  input arguments

      real(long_t)    :: x(:,:), b(:,:)
      real(long_t)    :: err
      integer         :: mpx, nqx
!
!  local variable
      integer         :: nprows, myrow, npcols, mycol, i, j
      integer         :: icontxt, icm, irm
      real(long_t), allocatable :: xnr(:), bnr(:)
      real(long_t)    :: err2, xnrm

      real(long_t)       :: funca, funcx, timef, dnrm2
      external           funca, funcx, timef, dnrm2

      call blacs_gridinfo(p_context(),nprows,npcols,myrow,mycol)
      icontxt = p_context()

      allocate(xnr(nprows))
      allocate(bnr(nprows))
c
c       check the result  for correctness and print error.
      err = 0.d0
      xnr = 0.d0
      bnr = 0.d0
       

      do j=1, nqx
        do i=1, mpx
          if (b(i,j).ne.b(i,j)) then
            write(0,*) 'warning: nanq in solution'
            err = b(i,j)
          endif
          b(i,j) = b(i,j) - x(i,j)
        enddo
        bnr(myrow+1) = dnrm2(mpx,b(1,j),1)
        call dgsum2d(icontxt,'col',' ',nprows,1,bnr,nprows,-1,mycol)
        xnr(myrow+1) = dnrm2(mpx,x(1,j),1)
        call dgsum2d(icontxt,'col',' ',nprows,1,xnr,nprows,-1,mycol)
        err2 = dnrm2(nprows,bnr,1)
        xnrm = dnrm2(nprows,xnr,1)
        err2 = err2/xnrm
        err  = max(err,err2)
      enddo

      call dgamx2d(icontxt,'all',' ',1,1,err,1,irm,icm,1,0,0)

      deallocate(xnr)
      deallocate(bnr)

      end subroutine get2norm
