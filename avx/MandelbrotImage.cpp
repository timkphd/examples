/* ============================================================================
 * Copyright (C) 2019 Intel Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 * OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * SPDX-License-Identifier: MIT
 * ============================================================================
 */

/*
. /nopt/nrel/apps/csso/env.sh
ml intel-oneapi-mpi/2021.8.0-intel
intel-oneapi-mpi/2021.8.0-intel
export I_MPI_CXX=icpx
icpx    -O3 -xCore-AVX512 -qopt-zmm-usage=high         MandelbrotImage.cpp -o ser_man
mpiicpc -O3 -xCore-AVX512 -qopt-zmm-usage=high -DDOMPI MandelbrotImage.cpp -o par_man
*/
 
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#ifdef DOMPI
#include <mpi.h>
#endif

//#include <cstdlib>
//#include <algorithm>
#include <immintrin.h>
#include <stdint.h>
// Time
//#include <Windows.h>
#define rdtsc __rdtsc

#define testIterations 1000
static int preventOptimize = 0;
#define _aligned_free free

/* Serial version please refer to 
https://github.com/ispc/ispc/blob/master/examples/mandelbrot_tasks/mandelbrot_tasks_serial.cpp
*/

/* AVX2 Implementation */
static __m256i avx2Mandel(__m256 c_re8, __m256 c_im8, uint32_t maxIterations) {
    __m256  z_re8 = c_re8;
    __m256  z_im8 = c_im8;
    __m256  four8 = _mm256_set1_ps(4.0f);
    __m256  two8 = _mm256_set1_ps(2.0f);
    __m256i result = _mm256_set1_epi32(0);
    __m256i one8 = _mm256_set1_epi32(1);

    for (auto i = 0; i < maxIterations; i++) {
        __m256 z_im8sq = _mm256_mul_ps(z_im8, z_im8);
        __m256 z_re8sq = _mm256_mul_ps(z_re8, z_re8);
        __m256 new_im8 = _mm256_mul_ps(z_re8, z_im8);
        __m256 z_abs8sq = _mm256_add_ps(z_re8sq, z_im8sq);
        __m256 new_re8 = _mm256_sub_ps(z_re8sq, z_im8sq);
        __m256 mi8 = _mm256_cmp_ps(z_abs8sq, four8, _CMP_LT_OQ);
        z_im8 = _mm256_fmadd_ps(two8, new_im8, c_im8);
        z_re8 = _mm256_add_ps(new_re8, c_re8);
        int mask = _mm256_movemask_ps(mi8);
        __m256i masked1 = _mm256_and_si256(_mm256_castps_si256(mi8), one8);
        if (0 == mask)
            break;
        result = _mm256_add_epi32(result, masked1);
    }
    preventOptimize++;
    return result;
};

void mandelbrot_AVX2(float x0, float y0, float x1, float y1,
	int width, int height, int maxIterations,
	int *output)
{
    float dx = (x1 - x0) / width;
    float dy = (y1 - y0) / height;

    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width; i = i + 8) {
            float x = x0 + i * dx;
            float y = y0 + j * dy;
            __m256 vecx = _mm256_set_ps(x + 7 * dx, x + 6 * dx, x + 5 * dx, x + 4 * dx, x + 3 * dx, x + 2 * dx, x + dx, x);
            __m256 vecy = _mm256_set1_ps(y);
            int index = (j * width + i);
            _mm256_storeu_si256((__m256i *)&output[index], avx2Mandel(vecx, vecy, maxIterations));
        }
    }
}

/* AVX512 Implementation */
static __m512i avx512Mandel(__m512 c_re16, __m512 c_im16, uint32_t maxIterations) {
    __m512 z_re16 = c_re16;
    __m512 z_im16 = c_im16;
    __m512 four16 = _mm512_set1_ps(4.0f);
    __m512 two16 = _mm512_set1_ps(2.0f);
    __m512i one16 = _mm512_set1_epi32(1);
    __m512i result = _mm512_setzero_si512();

    for (auto i = 0; i < maxIterations; i++) {
        __m512 z_im16sq = _mm512_mul_ps(z_im16, z_im16);
        __m512 z_re16sq = _mm512_mul_ps(z_re16, z_re16);
        __m512 new_im16 = _mm512_mul_ps(z_re16, z_im16);
        __m512 z_abs16sq = _mm512_add_ps(z_re16sq, z_im16sq);
        __m512 new_re16 = _mm512_sub_ps(z_re16sq, z_im16sq);
        __mmask16 mask = _mm512_cmp_ps_mask(z_abs16sq, four16, _CMP_LT_OQ);
        z_im16 = _mm512_fmadd_ps(two16, new_im16, c_im16);
        z_re16 = _mm512_add_ps(new_re16, c_re16);
        if (0 == mask)
            break;
        result = _mm512_mask_add_epi32(result, mask, result, one16);
    }
    preventOptimize++;
    return result;
};

void mandelbrot_AVX512(float x0, float y0, float x1, float y1,
	int width, int height, int maxIterations,
	int *output)
{
    float dx = (x1 - x0) / width;
    float dy = (y1 - y0) / height;

    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width; i = i + 16) {
            float x = x0 + i * dx;
            float y = y0 + j * dy;
            __m512 vecx = _mm512_set_ps(x + 15 * dx, x + 14 * dx, x + 13 * dx, x + 12 * dx, x + 11 * dx, x + 10 * dx, x + 9 * dx, x + 8 * dx, x + 7 * dx, x + 6 * dx, x + 5 * dx, x + 4 * dx, x + 3 * dx, x + 2 * dx, x + dx, x);
            __m512 vecy = _mm512_set1_ps(y);
            int index = (j * width + i);
            _mm512_store_epi32(&output[index], avx512Mandel(vecx, vecy, maxIterations));
        }
    }
}

int main(int argc, char *argv[]) {
    unsigned int width = 768;
    unsigned int height = 512;
    float x0 = -2;
    float x1 = 1;
    float y0 = -1;
    float y1 = 1;
    static uint64_t start, end;
    double dtAvx, dtAvx512;
    int myid;
    myid=0;

#ifdef DOMPI
            MPI_Init(&argc,&argv);
            MPI_Comm_rank(MPI_COMM_WORLD,&myid);
#endif
    int maxIterations = 256;

    // Init image buff
    //int *bufx8 = (int *)_aligned_malloc(width * height * sizeof(int), 64);
    // int *bufx16 = (int *)_aligned_malloc(width * height * sizeof(int), 64);

    int *bufx8 = (int *)aligned_alloc(64, width * height * sizeof(int));
    int *bufx16 = (int *)aligned_alloc(64,width * height * sizeof(int));
    // Sanity check
    mandelbrot_AVX2(x0, y0, x1, y1, width, height, maxIterations, bufx8);
    
    mandelbrot_AVX512(x0, y0, x1, y1, width, height, maxIterations, bufx16);
    for (int j = 0; j < height; j++) {
        for (int i = 0; i < width; i = i + 16) {
            if (bufx8[j*width+i] != bufx16[j*width + i]) {
                printf("Wrong implemetation.\n");
                return preventOptimize;
            }
        }
    }
    

    // AVX2 
    start = rdtsc();
    for (int i = 0; i < testIterations; ++i) {
        mandelbrot_AVX2(x0, y0, x1, y1, width, height, maxIterations, bufx8);
    }
    end = rdtsc();
    dtAvx = end - start;
	
    if (myid == 0)printf("512\n");
    // AVX512
    start = rdtsc();
    for (int i = 0; i < testIterations; ++i) {
         mandelbrot_AVX512(x0, y0, x1, y1, width, height, maxIterations, bufx16);
    }
    end = rdtsc();
    dtAvx512 = end - start;

    printf("%d AVX2/AVX512 = %f\n", myid, dtAvx / dtAvx512);
    _aligned_free(bufx8);
    _aligned_free(bufx16);

#ifdef DOMPI
        MPI_Finalize();
#endif
    return preventOptimize;
}
