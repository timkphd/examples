/* Start reading here */

#include <fftw3.h>

#define NUM_POINTS 64


/* Never mind this bit */

#include <stdio.h>
#include <math.h>

#define REAL 0
#define IMAG 1
float theta;

void acquire_from_somewhere(fftwf_complex* signal) {
    /* Generate two sine waves of different frequencies and
 *      * amplitudes.
 *           */

    int i;
#pragma omp for private(theta)
    for (i = 0; i < NUM_POINTS; ++i) {
        theta = (float)i / (float)NUM_POINTS * M_PI;

        signal[i][REAL] = 1.0 * cos(4.0 * theta) + 0.5 * cos( 8.0 * theta);
        signal[i][IMAG] = 1.0 * sin(2.0 * theta) + 0.5 * sin(16.0 * theta);
        signal[i][IMAG] = 1.0 * cos(2.0 * theta) + 0.5 * cos(16.0 * theta);
//	signal[i][REAL]=i; 
//	signal[i][IMAG]=0;
    }
}

void do_something_with(fftwf_complex* result) {
    int i;
    for (i = 0; i < NUM_POINTS; ++i) {
        float mag = sqrt(result[i][REAL] * result[i][REAL] +
                          result[i][IMAG] * result[i][IMAG]);

        printf("%23.12f  %10.5f %10.5f\n", mag,result[i][REAL] ,result[i][IMAG]);
    }
}


/* Resume reading here */

int main() {
    fftwf_complex signal[NUM_POINTS];
    fftwf_complex result[NUM_POINTS];

    fftwf_plan plan = fftwf_plan_dft_1d(NUM_POINTS,
                                      signal,
                                      result,
                                      FFTW_FORWARD,
                                      FFTW_ESTIMATE);

    acquire_from_somewhere(signal);
    fftwf_execute(plan);
    do_something_with(result);

    fftwf_destroy_plan(plan);

    return 0;
}

