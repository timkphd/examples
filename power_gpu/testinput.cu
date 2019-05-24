#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
void checkCUDAError(const char *msg);
 __global__ void Kernel(int *dat);
main() {
	int *dat_local, *dat_remote;
	int gx,gy;
	int bx,by,bz;
	int size;
	int numthreads,j;
	
	printf(" %s\n","Enter grid dimensions: gx gy");
	scanf("%d %d",&gx,&gy);
	printf(" %s\n","Enter block dimensions: bx by bz");
	scanf("%d %d %d",&bx,&by,&bz);
	printf(" Grid dimensions:  %3d%4d\n",gx,gy);	
	printf(" Block dimensions: %3d%4d%4d\n",bx,by,bz);	
	dim3 dimGrid(gx,gy);
	dim3 dimBlock(bx,by,bz);
	
	numthreads=gx*gy*bx*by*bz;
	
	size=6*sizeof(int)*numthreads;
	cudaMalloc((void**) &dat_remote, size);
        checkCUDAError("cudaMalloc");
	dat_local=(int*)malloc(size);
	
	Kernel<<<dimGrid,dimBlock>>>(dat_remote);
        checkCUDAError("Kernel");
	cudaMemcpy(dat_local, dat_remote, size,cudaMemcpyDeviceToHost);
        checkCUDAError("copy");
	
	printf("%s\n","thread   blockid(x   y)   threadid(x   y   z)");
for(int i=0;i<numthreads;i++) {
		j=i*6;
		printf("%6d         %3d %3d           %3d %3d %3d\n",
		dat_local[j],
		dat_local[j+1],dat_local[j+2],
		dat_local[j+3],dat_local[j+4],dat_local[j+5]);
	}
			  
}


 __global__ void Kernel(int *dat) {
/* get my block within a grid */
    int myblock=blockIdx.x+blockIdx.y*gridDim.x;
/* how big is each block within a grid */
    int blocksize=blockDim.x*blockDim.y*blockDim.z;
/* get thread within a block */
    int subthread=threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*blockDim.x+threadIdx.x;
/* find my thread */
    int thread=myblock*blocksize+subthread;
#if __DEVICE_EMULATION__
	printf("gridDim=(%3d %3d) blockIdx=(%3d %3d)     blockDim=(%3d %3d %3d)  threadIdx=(%3d %3d %3d)  %6d\n",    
	  gridDim.x,gridDim.y,
	  blockIdx.x,blockIdx.y,
	  blockDim.x,blockDim.y,blockDim.z,
	  threadIdx.x,threadIdx.y,threadIdx.z,thread);
#endif
/* starting index into array */
	int index=thread*6;
	dat[index]=thread;
	dat[index+1]=blockIdx.x;
	dat[index+2]=blockIdx.y;
	dat[index+3]=threadIdx.x;
	dat[index+4]=threadIdx.y;
	dat[index+5]=threadIdx.z;
}

void checkCUDAError(const char *msg)
{
    cudaError_t err = cudaGetLastError();
    if( cudaSuccess != err)
    {
        fprintf(stderr, "Cuda error: %s: %s.\n", msg,
                                  cudaGetErrorString( err) );
        exit(EXIT_FAILURE);
    }
}

