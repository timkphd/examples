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
      integer     i, j, jb, mb, nb, merow, mecol, nprows, npcols,
     +   irsr, icsr, icontxt, m_a, n_a, ii, jj, i1, j1, ib,
     +   ioff, joff, ip0, jp0, il, jl
!     .. 
      
!
      icontxt = adesc(CTXT_) 
      call blacs_gridinfo(icontxt,nprows,npcols,merow,mecol)

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
