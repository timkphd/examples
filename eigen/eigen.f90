!
!  The test performs the following operations :
!
!
!       1. The code calls  FEASTINIT  to define the default values for the input
!          FEAST parameters.
!
!       2. The  code  solves  the  standard eigenvalue  problem  Ax=ex   using 
!          DFEAST_SCSREV.
!
!*******************************************************************************
      program  dexample_sparse
      use mytype
      use qsort_c_module
      use timeit
      implicit none
!!!!!!!!!!!!!!!!! Matrix declaration variables !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      character*1 UPLO
      parameter   (UPLO='F')
!!!!!!!!!!!!!!!!! Declaration of FEAST variables !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      integer     fpm(128)
      real*8      Emin,Emax
      real*8      epsout
      integer     loop
      integer     M0,M,info
!!!!!!!!!!!!!!!!! E - eigenvalues, X - eigenvectors, res - residual !!!!!!!!!!!!
      real*8,allocatable ::      E(:),X(:,:),res(:)
 !     integer       i,j
      integer       ldx, ldy
   integer , parameter :: maxnz=10000
   integer , allocatable:: row_ptr(:)
   type(ent), allocatable:: vals(:)
   integer :: numnz,msize,k
   integer :: i,j
   character (len=32) arg
   real*8 t1,t2


!!! Search interval [Emin,Emax] including M eigenpairs !!!!!!!!!!!!!!!!!!!!!!!!!
!!! values are read from the command line  Should be 
!!!      Emin=3.0
!!!      Emax=7.0 
!!!      M0=8
      call get_command_argument(1,arg,status=k) ; if (k .ne. 0) goto 1234
      read(arg,*)Emin
      call get_command_argument(2,arg,status=k) ; if (k .ne. 0) goto 1234
      read(arg,*)Emax
      call get_command_argument(3,arg,status=k) ; if (k .ne. 0) goto 1234
      read(arg,*)M0
      print *,'Search interval ', Emin,' ', Emax
      print *,'The initial guess of subspace dimension to be used',M0
      ldx=msize
      ldy=msize


! Read the number of nonzeros and the size of the matrix
   read(*,*)numnz,msize
! Allocate our vector to store the data triplets.  In
! the end this will also contain col_ind and values
! in the proper order.
! NOTE: numnz <= maxnz
   allocate(vals(maxnz))
! Read our data.  In a real program the data could be
! generated on the fly in any order.
   do k=1,numnz
        read(*,*)vals(k)%i,vals(k)%j,vals(k)%val
   enddo
! On return from QsortC vals%j contains the col_ind
! and vals%val contains the values.  Note we pass in
! only the section of the array that contains data.
   call QsortC(vals(1:numnz))
! By convention row_ptr is one bigger than the
! size of the matrix and the last entry is equal
! to numnz+1.
   allocate(row_ptr(msize+1))
! Fill row_ptr
   call getrow(vals,row_ptr,numnz)
      


!
!        Task 1. Call FEASTINIT to define the default values for the input
!        FEAST parameters.
!
      call feastinit(fpm)
      fpm(1)=1
      print *, ' Testing dfeast_scsrev '
!
!         Task 2. Solve the standard eigenvalue problem Ax=ex.
! 
!    character  uplo,   /* Upper or lower triangular part of the matrix or full*/
!    integer    n,      /* Size of the problem */
!    real*8     a,      /* a, ia, and ja represent the sparse matrix stored in the CSR format */
!    integer    ia,
!    integer    ja,
!    integer    fpm,    /* Parameter array initialized by feastinit */
!    real*8     epsout, /* On output contains the relative error on the trace */
!    integer    loop,   /* On output contains the number of refinement loops needed to converge */
!    real*8     emin,   /* The lower bound of the interval to be searched for Eigenvalues */
!    real*8     emax,   /* The upper bound of the interval to be searched for Eigenvalues */
!    integer    m0,     /* The initial guess of subspace dimension to be used */
!    real*8     e,      /* On output, this array contains the Eigenvalues found in the interval */
!    real*8     x,      /* On output, contains all Eigenvectors corresponding to e */
!    integer    m,      /* On output, the total numbers of Eigenvalues found in the interval */
!    real*8     res,    /* On output, the relative residual vector of length m */
!    integer    info    /* On output, contains error code or 0 if the execution is successful */
!      allocate(E(msize),X(msize,msize),res(msize))
      allocate(E(msize),X(msize,M0),res(msize))
      x=huge(x)
      t1=atime()
      call dfeast_scsrev(UPLO,msize, &
                        vals(1:numnz)%val,row_ptr,vals(1:numnz)%j, &
                        fpm,epsout,loop, &
                        Emin,Emax,M0,E,X,M,res,info)
      t2=atime(t1)
      write(*,*)"Runtime=",t2
      print  *,' FEAST OUTPUT INFO ',info
      if(info.ne.0) stop 1

      print *, 'Number of eigenvalues found ', M
      print *, ' Computed    '
      print *, ' Eigenvalues '
      do k=1,M
         print *, E(k)
      enddo
      print *, ' Eigenvectors '
      do j=1,M
        write(*,"(11f10.2)")(x(i,j),i=1,msize)
      enddo
      stop
 1234 write(*,*)"Need to enter Search interval and "
      write(*,*)"initial guess of subspace dimension"
      write(*,*)"to be used  on the command line"
      write(*,*)"For example:"
      write(*,*)"3.0 7.0 8"

      end program dexample_sparse
