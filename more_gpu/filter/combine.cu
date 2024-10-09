// nvc++   -O3 -static-nvidia -c++libs   combine.cu  -o reduce
// /usr/local/cuda-12.6/bin/nvcc   -DTRANSPOSE -O3 combine.cu -o treduce
// If copied to a container
// ml apptainer/1.1.9-ubkbfc2
// salloc --nodes=1 --time=04:00:00 --account=hpcapps --partition=gpu --exclusive --mem=0  --gres=gpu:4
// apptainer exec --nv  comp.sif /extra01/reduce

#include <string>
#include <vector>
#include <stdio.h>
#include <float.h>
#include <limits.h>
#include <unistd.h>
#include <sys/time.h>

// Macro for checking errors in CUDA API calls
#define cudaErrorCheck(call)                                                              \
do{                                                                                       \
    cudaError_t cuErr = call;                                                             \
    if(cudaSuccess != cuErr){                                                             \
        printf("CUDA Error - %s:%d: '%s'\n", __FILE__, __LINE__, cudaGetErrorString(cuErr));\
        exit(0);                                                                            \
    }                                                                                     \
}while(0)


/* A gettimeofday routine to give access to the wall
   clock timer on most UNIX-like systems.  */
double mysecond()
{
    struct timeval tp;
    struct timezone tzp;
    int i = gettimeofday(&tp,&tzp);
    return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}


template <typename T>
__global__ void mytreduce(T const * __restrict__ const myorg, T * __restrict__ const b, int newspec, int oldspec, int newspac, int oldspac, int specfac, int spacfac,int len,int awidth)

{
    int nindex = threadIdx.x + blockIdx.x * blockDim.x;
    if (nindex < len) {
            int newrow = nindex / newspec         ;
            int newcol = nindex - newrow * newspec ;
            int oldcol = newcol * specfac          ;
            int oldrow = newrow * spacfac          ;
            int oindex = oldrow * oldspec + oldcol ;
            float mysum=0;
            int count=0;
                for (int s=-awidth;s<=awidth;s++){
                    int i = oindex + s * oldspec;
                    if ((i > -1 ) && ((s + oldrow) < oldspac)){
                        mysum=mysum+myorg[i];
                        count++;
                    }
                }
                b[nindex]=(int)(((float)mysum)/count + 0.5);
    }
        
}


template <typename T>
__global__ void myreduce(T const * __restrict__ const myorg, T * __restrict__ const b, int newspec, int oldspec, int newspac, int oldspac, int specfac, int spacfac,int len,int awidth)

{
    int nindex = threadIdx.x + blockIdx.x * blockDim.x;
    if (nindex < len) {
                int vnew = nindex/newspac;
                int hnew = nindex-vnew*newspac;
                int v = vnew*specfac;
                int h = hnew*spacfac;
                int oindex=v*oldspac+h;
                float mysum=0.0;
                int count=0;
                for (int s=-awidth;s<=awidth;s++){
                    int i=h+s;
                    if ((i > -1 ) && (i < oldspac)){
                        mysum=mysum+myorg[oindex+s];
                        count++;
                    }
                }
                b[nindex]=(int)(((float)mysum)/count + 0.5);
    }
        
}




int main(int argc, char** argv)
{
    int *d_a, *d_b, *A, *B;;

    int GPU=0;
    int N,OLD;
    int blockSize=192;
    cudaSetDevice(GPU);
    
    int oldspec=1600;
    int oldspac=102;
    int w=10;
    int specfac = 1;
    int spacfac = 10;
    
// int rspec = Int16.Parse(args[0]);
// int rspac = Int16.Parse(args[1]);

       if (argc == 2){
           sscanf(argv[1],"%d",&spacfac);
       }
       if (argc == 3){
           sscanf(argv[1],"%d",&specfac);
           sscanf(argv[2],"%d",&spacfac);
       }
       if (argc == 4){
           sscanf(argv[1],"%d",&specfac);
           sscanf(argv[2],"%d",&spacfac);
           sscanf(argv[3],"%d",&w);
       }

    printf("specfac = %d    spacfac = %d    width = %d\n",specfac,spacfac,w);    
    int newspec=(oldspec/specfac);
    if ( (newspec*specfac) < oldspec ) newspec++;
    int newspac=(oldspac/spacfac);
    if ( (newspac*spacfac) < oldspac ) newspac++;
    printf("newspac %d    newspec %d\n",newspac,newspec);
    
    N=newspec*newspac;
    OLD=oldspec*oldspac;


    cudaMalloc((void**)&d_a, sizeof(int)*OLD);
    cudaMalloc((void**)&d_b, sizeof(int)*N);
    A=(int*)malloc(sizeof(int)*OLD);
    B=(int*)malloc(sizeof(int)*N);

    /* Compute execution configuration */
    dim3 dimBlock(blockSize);
    dim3 dimGrid(N/dimBlock.x );
    if( N % dimBlock.x != 0 ) dimGrid.x+=1;
    printf(" using %d threads per block, %d blocks\n",dimBlock.x,dimGrid.x);
    
    FILE *f18;
#ifdef TRANSPOSE
    f18=fopen("transpose","r");
#else
    f18=fopen("original","r");
#endif
    for (int ic=0;ic<OLD;ic++){
        fscanf(f18,"%d",&A[ic]);
    }
    fclose(f18);
    
    double tstart,tinn,tred,tout;
    tinn=0;
    tred=0;
    tout=0;
    

    int ntimes=1000;
    for (int icount=0;icount<ntimes;icount++){
        tstart=mysecond();
    /* Copy image to device */
        cudaErrorCheck( cudaMemcpy(d_a, A, OLD*sizeof(int), cudaMemcpyHostToDevice) );
        tinn=tinn+(mysecond()-tstart);
        
        tstart=mysecond();      
    /* shrink it */
#ifdef TRANSPOSE
        mytreduce<<<dimGrid,dimBlock>>>(d_a, d_b, newspec, oldspec, newspac, oldspac,specfac, spacfac,N,w);
#else
        myreduce<<<dimGrid,dimBlock>>>(d_a, d_b, newspec, oldspec, newspac, oldspac,specfac, spacfac,N,w);
#endif
        tred=tred+(mysecond()-tstart);
        
        tstart=mysecond();
    /* Copy image to cpu */
        cudaErrorCheck( cudaMemcpy(B, d_b, N*sizeof(int), cudaMemcpyDeviceToHost));
        tout=tout+(mysecond()-tstart);
    }
    printf("      INPUT           COMPUTE         OUTPUT\n");

    printf("%15g %15g %15g\n",tinn/ntimes,tred/ntimes,tout/ntimes);
    
     
#ifdef TRANSPOSE
    f18=fopen("new_gpu_transpose","w");
#else
    f18=fopen("new_gpu","w");
#endif

    for (int ic=0;ic<N;ic++){
        fprintf(f18,"%d\n",B[ic]);
    }
    fclose(f18);
    
    cudaFree(d_a);
    cudaFree(d_b);
    free(A);
    free(B);
}

