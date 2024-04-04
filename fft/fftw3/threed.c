#include <fftw3.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#define rrand() (float)rand()/(float)(RAND_MAX); 
unsigned long NUM_POINTS;
#define REAL 0
#define IMAG 1

/* fftw_complex *an_array;
an_array = (fftw_complex*) fftw_malloc(5*12*27 * sizeof(fftw_complex));
Accessing the array elements, however, is more tricky—you can’t simply use 
multiple applications of the ‘[]’ operator like you could for fixed-size 
arrays. Instead, you have to explicitly compute the offset into the array 
using the formula given earlier for row-major arrays. For example, to 
reference the (i,j,k)-th element of the array allocated above, you would 
use the expression an_array[k + 27 * (j + 12 * i)].
*/

double mysecond()
{
    struct timeval tp;
    struct timezone tzp;
    int i = gettimeofday(&tp,&tzp);
    return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

void printit(fftw_complex* result) {
    int i;
    printf("results\n");
    for (i = 0; i < NUM_POINTS; ++i) {
        double mag = sqrt(result[i][REAL] * result[i][REAL] +
                          result[i][IMAG] * result[i][IMAG]);
        printf("%23.12f %10.5f %10.5f\n", mag,result[i][REAL] ,result[i][IMAG]);
    }
}

void fillit(fftw_complex* signal) {
    int i;
    for (i = 0; i < NUM_POINTS; ++i) {
        signal[i][REAL] = rrand();
        signal[i][IMAG] = rrand();
    }
}

int main(int argc, char **argv){
     int N=16;
     double c1,c2,s1,s2,d1,d2;
     if (argc > 1) N=atoi(argv[1]);
#ifdef ONED
     NUM_POINTS=N;
     printf("vector size %d elements %ld\n",N,NUM_POINTS);
#else
#ifdef TWOD
     NUM_POINTS=N*N;
     printf("grid size %d elements %ld\n",N,NUM_POINTS);
#else
     NUM_POINTS=N*N*N;
     printf("cube size %d elements %ld\n",N,NUM_POINTS);
#endif
#endif
     fftw_complex *signal;
     fftw_complex *result;
     signal=(fftw_complex*)fftw_malloc(NUM_POINTS*sizeof(fftw_complex));
     result=(fftw_complex*)fftw_malloc(NUM_POINTS*sizeof(fftw_complex));

     fftw_plan p;

/*
	FFTW_ESTIMATE specifies that, instead of actual measurements of
different algorithms, a simple heuristic is used to pick a (probably
sub-optimal) plan quickly. With this flag, the input/output arrays
are not overwritten during planning.

	FFTW_MEASURE tells FFTW to find an optimized plan by actually
computing several FFTs and measuring their execution time. Depending
on your machine, this can take some time (often a few seconds).
FFTW_MEASURE is the default planning option.

*/
    printf(" create plan\n");
    c1=mysecond();
#ifdef ONED
    p = fftw_plan_dft_1d(N,     signal,result,FFTW_FORWARD,FFTW_ESTIMATE);
#else
#ifdef TWOD
    p = fftw_plan_dft_2d(N,N,   signal,result,FFTW_FORWARD,FFTW_ESTIMATE);
#else
    p = fftw_plan_dft_3d(N,N,N, signal,result,FFTW_FORWARD,FFTW_ESTIMATE);
#endif
#endif
    c2=mysecond();
    printf(" stuff in data\n");
    s1=mysecond();
    fillit(signal);
    s2=mysecond();
    printf(" do it\n");
    d1=mysecond();
    fftw_execute(p);
    d2=mysecond();
    if (NUM_POINTS < 257 ) printit(result);
    printf(" clean up\n");
    fftw_destroy_plan(p);  
#ifdef ONED    
    printf("create 1d plan %15.6f\n",c2-c1);
#else
#ifdef TWOD
    printf("create2d plan %15.6f\n",c2-c1);
#else
    printf("   create plan %15.6f\n",c2-c1);
#endif
#endif
    printf(" stuff in data %15.6f\n",s2-s1);
    printf("        do fft %15.6f\n",d2-d1);
}

