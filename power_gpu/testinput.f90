module mytests
contains
attributes(global)  &
subroutine test1( a )
integer, device :: a(*)
integer,device :: myblock,blocksize,subthread,thread,index,gridsize
integer thx,thy,thz,bkx,bky
    bkx=blockIdx%x-1
    bky=blockIdx%y-1
    thx=threadIdx%x-1
    thy=threadIdx%y-1
    thz=threadIdx%z-1
!/* get my block within a grid */
     myblock=bkx+(bky)*(gridDim%x);
!/* how big is each block within a grid */
     blocksize=blockDim%x*blockDim%y*blockDim%z;
!/* how big is the grid */
     gridsize=gridDim%x*gridDim%y*gridDim%z;
!/* get thread within a block */
     subthread=thz*(blockDim%x*blockDim%y)+thy*blockDim%x+thx;
!/* find my thread */
    thread=myblock*blocksize+subthread;
    index=thread*6+1
    a(index)=thread;
    a(index+1)=bkx;
    a(index+2)=bky;
    a(index+3)=thx;
    a(index+4)=thy;
    a(index+5)=thz;
return
end subroutine test1
end module mytests

program t1
use cudafor
use mytests
integer n 
integer, allocatable, device :: iarr(:)

integer, allocatable :: h(:)
integer gx,gy,bx,by,bz
    type(dim3) ::  dimGrid
    type(dim3) ::  dimBlock

istat = cudaSetDevice(0)
write(*,*)"Enter grid dimensions: gx gy"
read(*,*)gx,gy
write(*,*)"Enter block dimensions: bx by bz"
read(*,*)bx,by,bz
write(*,'(" Grid dimensions: ",2i4)')gx,gy
write(*,'(" Block dimensions:",3i4)')bx,by,bz
n=gx*gy*bx*by*bz
allocate(iarr(n*6))
allocate(h(n*6))
!dimGrid = dim3(gx,gy)
dimGrid = dim3(gx,gy,1)

dimBlock = dim3(bx,by,bz)
h = 0; iarr = h
call test1<<<dimGrid,dimBlock>>> (iarr)
h = iarr
write(*,"('thread   blockid(x   y)   threadid(x   y   z)')")
write(*,"(i6,8x,2i4,10x,3i4)")h
deallocate(iarr)
end program t1

