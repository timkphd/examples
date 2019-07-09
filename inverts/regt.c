/*
   LAPACKE_dgesv Example
   =====================

   The program computes the solution to the system of linear
   equations with a square matrix A and multiple
   right-hand sides B, where A is the coefficient matrix
   and b is the right-hand side matrix:

   Description
   ===========

   The routine solves for X the system of linear equations A*X = B,
   where A is an n-by-n matrix, the columns of matrix B are individual
   right-hand sides, and the columns of X are the corresponding
   solutions.

   The LU decomposition with partial pivoting and row interchanges is
   used to factor A as A = P*L*U, where P is a permutation matrix, L
   is unit lower triangular, and U is upper triangular. The factored
   form of A is then used to solve the system of equations A*X = B.

   LAPACKE Interface
   =================

   LAPACKE_dgesv (row-major, high-level) Example Program Results

  -- LAPACKE Example routine (version 3.7.0) --
  -- LAPACK is a software package provided by Univ. of Tennessee,    --
  -- Univ. of California Berkeley, Univ. of Colorado Denver and NAG Ltd..--
     December 2016

*/
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#include <lapacke.h>
#include <string.h>
#ifndef _LAPACKE_EXAMPLE_AUX_
#define _LAPACKE_EXAMPLE_AUX_


void print_matrix_rowmajor( char* desc, lapack_int m, lapack_int n, double* mat, lapack_int ldm );
void print_matrix_colmajor( char* desc, lapack_int m, lapack_int n, double* mat, lapack_int ldm );
void print_vector( char* desc, lapack_int n, lapack_int* vec );

#endif /* _LAPACKE_EXAMPLE_AUX_*/

#define FLT double
//void mset(FLT **m, int n, int in) {
void mset(FLT *m, int n, int in) {
	int i,j;
    for(i=0;i<n;i++) 
       for(j=0;j<n;j++) {
           if(i == j) {
               //m[i][j]=in; 
               m[i+j*n]=in;
           } else {
              // m[i][j]=0.1; 
               m[i+j*n]=0.1;
           }
       }
   
}
FLT system_clock() {
	FLT t;
	FLT six=1.0e-6;
	struct timeval tb;
	struct timezone tz;
	gettimeofday(&tb,&tz);
	t=(FLT)tb.tv_sec+((FLT)tb.tv_usec)*six;
 	return(t);
}


/* Main program */
int main(int argc, char **argv) {

        /* Locals */
        lapack_int n, nrhs, lda, ldb, info;
		int i, j;
		int DOP=0;
        /* Local arrays */
		double *A, *b;
		lapack_int *ipiv;
		int icount,jcount;
		double t1,t2,tmin,tmax,dt,tstart;
		double *tvect;
		tmin=1e30;
		tmax=0.0;

        /* Default Value */
	    n = 5; nrhs = 1;

        /* Arguments */
	    for( i = 1; i < argc; i++ ) {
	    	if( strcmp( argv[i], "-n" ) == 0 ) {
		    	n  = atoi(argv[i+1]);
			    i++;
		    }
			if( strcmp( argv[i], "-nrhs" ) == 0 ) {
				nrhs  = atoi(argv[i+1]);
				i++;
			}
		}
        scanf("%d",&n);
        /* Initialization */
        lda=n, ldb=nrhs;
		A = (double *)malloc(n*n*sizeof(double)) ;
		if (A==NULL){ printf("error of memory allocation\n"); exit(0); }
		b = (double *)malloc(n*nrhs*sizeof(double)) ;
		if (b==NULL){ printf("error of memory allocation\n"); exit(0); }
		ipiv = (lapack_int *)malloc(n*sizeof(lapack_int)) ;
		if (ipiv==NULL){ printf("error of memory allocation\n"); exit(0); }
		tstart=system_clock();
		tvect=(double*)malloc(500*sizeof(double)) ;
        for (icount=0; icount<500;icount++){
			mset(A,n,10);

			for(i=0;i<n*nrhs;i++)
				b[i] = 10.0;
				//b[i] = ((double) rand()) / ((double) RAND_MAX) - 0.5;

			/* Print Entry Matrix */
			if(DOP)print_matrix_rowmajor( "Entry Matrix A", n, n, A, lda );
			/* Print Right Rand Side */
			if(DOP)print_matrix_rowmajor( "Right Rand Side b", n, nrhs, b, ldb );
			if(DOP)printf( "\n" );
			/* Executable statements */
			if(DOP)printf( "LAPACKE_dgesv (row-major, high-level) Example Program Results\n" );
			/* Solve the equations A*X = B */
			t1=system_clock();
			info = LAPACKE_dgesv( LAPACK_ROW_MAJOR, n, nrhs, A, lda, ipiv,
							b, ldb );
			t2=system_clock();
			dt=t2-t1;
			jcount=icount+1;
			if(dt > tmax)tmax=dt;
			if(dt < tmin)tmin=dt;
			tvect[icount]=dt;
			if(t2-tstart> 120.0)icount=1000000;
			/* Check for the exact singularity */
			if( info > 0 ) {
					printf( "The diagonal element of the triangular factor of A,\n" );
					printf( "U(%i,%i) is zero, so that A is singular;\n", info, info );
					printf( "the solution could not be computed.\n" );
					exit( 1 );
			}
			if (info <0) exit( 1 );
			/* Print solution */
			if(DOP)print_matrix_rowmajor( "Solution", n, nrhs, b, ldb );
			/* Print details of LU factorization */
			if(DOP)print_matrix_rowmajor( "Details of LU factorization", n, n, A, lda );
			/* Print pivot indices */
			if(DOP)print_vector( "Pivot indices", n, ipiv );
        }
        printf("size= %d min=%g max=%g total=%g inverts=%d\n",n,tmin,tmax,t2-tstart,jcount);
        n=0;
        for(icount=0;icount<jcount;icount++){
        	printf("%f10.5 ",tvect[icount]);
        	n=n+1;
        	if(n==8){
        		printf("\n");
        		n=0;}
        }
        exit( 0 );
} /* End of LAPACKE_dgesv Example */

