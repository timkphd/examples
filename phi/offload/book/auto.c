#include <stdio.h>
#include <stdlib.h>
#include "mkl.h"
// we define size in the compile line
// #define SIZE 4096
double op_count;
double Flops;
#define DTYPE float
#define LOOP_COUNT 5
int main (int argc, char *argv[], char *envp[])
{

    double tstart,tend,tave;
    DTYPE *A, *B, *C;
    int m, n, k, i, j,ic,try;
    char transa,transb;
    DTYPE alpha, beta;
    m=SIZE;
    n=SIZE;
    k=SIZE;
    alpha=1.0;
    beta=1.0;
    transa='n';
    transb='n';
//#    mkl_set_num_threads(12);
//#    omp_set_num_threads(12);
//    while(*envp)
//        printf("%s\n",*envp++);
    A = (DTYPE *)mkl_malloc( m*k*sizeof( DTYPE ), 64 );
    B = (DTYPE *)mkl_malloc( k*n*sizeof( DTYPE ), 64 );
    C = (DTYPE *)mkl_malloc( m*n*sizeof( DTYPE ), 64 );
    if (A == NULL || B == NULL || C == NULL) {
      printf( "\n ERROR: Can't allocate memory for matrices. Aborting... \n\n");
      mkl_free(A);
      mkl_free(B);
      mkl_free(C);
      return -1;
    }
	for (try=0; try<=1; try++) {
		printf (" Intializing matrix data \n\n");
		for (i = 0; i < (m*k); i++) {
			A[i] = (DTYPE)(i+1);
		}

		for (i = 0; i < (k*n); i++) {
			B[i] = (DTYPE)(-i-1);
		}

		for (i = 0; i < (m*n); i++) {
			C[i] = 0.0;
		}


		sgemm(&transa, &transb,&m, &n, &k, &alpha, A, &k, B, &n, &beta, C, &n);

		tstart=dsecnd();
		for (ic=0; ic< LOOP_COUNT;ic++) {
			sgemm(&transa, &transb,&m, &n, &k, &alpha, A, &k, B, &n, &beta, C, &n);
		}
		tend=dsecnd();
		tave=(tend-tstart)/LOOP_COUNT;
		op_count =(2.0*SIZE*SIZE*SIZE + 1.0*SIZE*SIZE);
		Flops    = op_count/tave;
		printf("size= %8d,  GFlops= %8.3f\n",SIZE,Flops/1e9);
		if (mkl_mic_enable() != 0 ) {
			printf("could not enable Automatic Offload - no MIC devices? Exiting\n");
			return -1;
		}
	}
}



