      program testit
      INCLUDE 'fftw3.f'
      double complex in, out
      parameter (N=16)
      dimension in(N), out(N)
      integer*8 p,p2
      integer i,j
      real fact
      write(*,*)"stuff in data"
      do i=1,N
        j=i-1
        in(i)=cmplx(j*j,1)
      enddo
      write(*,*)"create plans"
      call dfftw_plan_dft_1d(p ,N,in,out,FFTW_FORWARD,FFTW_ESTIMATE)
      call dfftw_plan_dft_1d(p2,N,in,out,FFTW_BACKWARD,FFTW_ESTIMATE)
      write(*,*)"do it"
      call dfftw_execute_dft(p, in, out)
      do i=1,N
        write(*,"(f12.4,1x,f12.4)")out(i)
      enddo
      write(*,*)
      write(*,*)"undo it"
      call dfftw_execute_dft(p2, out,in)
      fact=1.0/N
      do i=1,N
        write(*,"(f10.2,1x,f10.2)")in(i)*fact
      enddo
      write(*,*)"clean up"
      call dfftw_destroy_plan(p)
      call dfftw_destroy_plan(p2)
      end program

