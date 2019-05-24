subroutine sum( a, b, c, n) 
real*4 a(10,10), b(10,10), c(10,10) 
integer i,j,n
!!!$acc data copy(a) copy(b) create(c)
!$acc kernels
  do i=1,n !line7
    do j=1,n !line8 
      c(i,j) = a(i,j)+ b(i,j)
    enddo 
  enddo
!$acc end kernels
!!!$acc exit data copyout(c)
!!!$acc end data
end
program main
  integer i, j, n 
  real*4 input_a(10,10), input_b(10,10), output_c(10,10) 

  n = 10 
  do i=1,n
    do j=1,n 
      input_a(i,j) = i 
      input_b(i,j) = j
    enddo 
  enddo
  call sum(input_a,input_b,output_c,n) 
  do i=1,n
    do j=1,n
      print*, output_c(i,j) 
    enddo
  enddo
end


