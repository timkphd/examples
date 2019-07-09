module myinvert
 contains
   subroutine invert (matrix,size)
    implicit none
    integer, parameter:: b8 = selected_real_kind(14)
    integer, parameter :: nmax=1000
    integer switch,k, jj, kp1, i, j, l, krow, irow,size
    dimension switch(nmax,2)
    real(b8) matrix(size,size)
    real(b8) pivot, temp
    do 100 k = 1,size
    jj = k
        if (k .ne. size) then
        kp1 = k + 1
        pivot = (matrix(k, k))
        do 1 i = kp1,size
        temp = (matrix(i, k))
        if (abs(pivot) .lt. abs(temp)) then
        pivot = temp
        jj = i
        endif
 1  continue
        endif
    switch(k, 1) = k
    switch(k, 2) = jj
    if (jj .ne. k) then
        do 2  j = 1 ,size 
    temp = matrix(jj, j)
    matrix(jj, j) = matrix(k, j)
    matrix(k, j) = temp
 2  continue
    endif
    do 3 j = 1,size
    if (j .ne. k)matrix(k, j) = matrix(k, j) / matrix(k, k)
 3  continue
    matrix(k, k) = 1.0 / matrix(k, k)
    do 4 i = 1,size
    if (i.ne.k) then
    do 40 j = 1,size
    if(j.ne.k)matrix(i,j)=matrix(i,j)-matrix(k,j)*matrix(i,k)
 40 continue
    endif
 4  continue
    do 5 i = 1, size
    if (i .ne. k)matrix(i, k) = -matrix(i, k) * matrix(k, k)
 5  continue
 100    continue
    do 6 l = 1,size
    k = size - l + 1
    krow = switch(k, 1)
    irow = switch(k, 2)
    if (krow .ne. irow) then
    do 60 i = 1,size
    temp = matrix(i, krow)
    matrix(i, krow) = matrix(i, irow)
    matrix(i, irow) = temp
 60 continue
    endif
 6  continue
    return
    end
	subroutine dGESV( N, NRHS, A, LDA, IPIV, B, LDB, INFO )
	implicit none
	integer, parameter:: b8 = selected_real_kind(14)
	real(b8) A(:,:),B(:,:)
	integer :: IPIV(:)
	integer n,nrhs,lda,ldb,info
	real(b8), allocatable :: x(:)
	allocate(x(n))
	call invert(a,n)
	x=matmul(a,b(:,1))
	b(:,1)=x
	deallocate(x)
	info=0
	end subroutine
end module