#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include "multShare.h"
// Thread block size
#define BLOCK_SIZE 16
 __global__ void MatMulKernel(const Matrix, const Matrix, Matrix);
/*
 * multShare.c
 *
 * Robert Hochberg
 * January 24, 2012
 *
 * Based nearly entirely on the code from the CUDA C Programming Guide
 */
// Matrix multiplication - Host code
// Matrix dimensions are assumed to be multiples of BLOCK_SIZE
void MatMul(const Matrix A, const Matrix B, Matrix C) {
  // Load A and B to device memory
  Matrix d_A;
  d_A.width = d_A.stride = A.width;
  d_A.height = A.height;
  size_t size = A.width * A.height * sizeof(float);
  cudaError_t err = cudaMalloc(&d_A.elements, size);
  printf("CUDA malloc A: %s\n",cudaGetErrorString(err));
  cudaMemcpy(d_A.elements, A.elements, size, cudaMemcpyHostToDevice);
  Matrix d_B;
  d_B.width = d_B.stride = B.width;
  d_B.height = B.height;
  size = B.width * B.height * sizeof(float);
  err = cudaMalloc(&d_B.elements, size);
  printf("CUDA malloc B: %s\n",cudaGetErrorString(err));
/* 37 */
  cudaMemcpy(d_B.elements, B.elements, size, cudaMemcpyHostToDevice);
  // Allocate C in device memory
  Matrix d_C;
  d_C.width = d_C.stride = C.width;
  d_C.height = C.height;
  size = C.width * C.height * sizeof(float);
  err = cudaMalloc(&d_C.elements, size);
  printf("CUDA malloc C: %s\n",cudaGetErrorString(err));
  // Invoke kernel
  dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
  dim3 dimGrid(B.width / dimBlock.x, A.height / dimBlock.y);
    MatMulKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C);
    err = cudaThreadSynchronize();
    printf("Run kernel: %s\n", cudaGetErrorString(err));
  // Read C from device memory
  err = cudaMemcpy(C.elements, d_C.elements, size, cudaMemcpyDeviceToHost);
  printf("Copy C off of device: %s\n",cudaGetErrorString(err));
  // Free device memory
  cudaFree(d_A.elements);
  cudaFree(d_B.elements);
  cudaFree(d_C.elements);
}
int main(int argc, char* argv[]){
  Matrix A, B, C;
  int a1, a2, b1, b2;

srand(1234);
  a1 = atoi(argv[1]); /* Height of A */
  a2 = atoi(argv[2]); /* Width  of A */
  b1 = a2;           /* Height of B */
/* 40 */

b2 = atoi(argv[3]); /* Width  of B */
A.height = a1;
A.width = a2;
A.elements = (float*)malloc(A.width * A.height * sizeof(float));
B.height = b1;
B.width = b2;
B.elements = (float*)malloc(B.width * B.height * sizeof(float));
C.height = A.height;
C.width = B.width;
C.elements = (float*)malloc(C.width * C.height * sizeof(float));
for(int i = 0; i < A.height; i++)
  for(int j = 0; j < A.width; j++)
    A.elements[i*A.width + j] = (rand() % 10);
for(int i = 0; i < B.height; i++)
  for(int j = 0; j < B.width; j++)
    B.elements[i*B.width + j] = (rand() % 5);
MatMul(A, B, C);
for(int i = 0; i < min(10, A.height); i++){
  for(int j = 0; j < min(10, A.width); j++)
    printf("%5.0f ", A.elements[i*A.width + j]);
  printf("\n");
}
printf("\n");
for(int i = 0; i < min(10, B.height); i++){
  for(int j = 0; j < min(10, B.width); j++)
    printf("%5.0f ", B.elements[i*B.width + j]);
  printf("\n");
}
printf("\n");
/* 41 */

for(int i = 0; i < min(10, C.height); i++){
  for(int j = 0; j < min(10, C.width); j++)
    printf("%5.0f ", C.elements[i*C.width + j]);
  printf("\n");
}
  printf("\n");
}

/* 42 */
