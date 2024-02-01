/*
 * Copyright (c) 2017, NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */



#include <stdio.h>
#include <math.h>

#ifdef __cplusplus
extern "C" {
#endif

void
check(int* res, int* exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i]) {
	    tests_passed ++;
        } else {
            tests_failed ++;
	    if( tests_failed < 50 )
            printf(
	    "test number %d FAILED. res %d(%08x)  exp %d(%08x)\n",
	     i+1,res[i], res[i], exp[i], exp[i] );
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}

void
check_(int* res, int* exp, int* np)
{
    check(res, exp, *np);
}

void
checkf(float* res, float* exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i]) {
	    tests_passed ++;
        } else {
            tests_failed ++;
	    if( tests_failed < 50 )
            printf(
	    "test number %d FAILED. res %g  exp %g\n",
	     i+1,res[i], exp[i]);
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}

void
checkf_(float* res, float* exp, int* np)
{
    checkf(res, exp, *np);
}

void
checkftol(float* res, float* exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;
    float tol = 0.000001;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i]) {
	    tests_passed ++;
	}else if( exp[i] != 0.0 && fabsf((exp[i]-res[i])/exp[i]) <= tol ){
	    tests_passed ++;
	}else if( exp[i] == 0.0 && res[i] <= tol ){
	    tests_passed ++;
        } else {
            tests_failed ++;
	    if( tests_failed < 50 )
            printf(
	    "test number %d FAILED. res %f  exp %f\n",
	     i+1,res[i], exp[i]);
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}

void
checkftol_(float* res, float* exp, int* np)
{
    checkftol(res, exp, *np);
}

void
checkftol5(float* res, float* exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;
    float tol = 0.00002;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i]) {
	    tests_passed ++;
	}else if( exp[i] != 0.0 && fabsf((exp[i]-res[i])/exp[i]) <= tol ){
	    tests_passed ++;
	}else if( exp[i] == 0.0 && res[i] <= tol ){
	    tests_passed ++;
        } else {
            tests_failed ++;
	    if( tests_failed < 50 )
            printf(
	    "test number %d FAILED. res %f  exp %f\n",
	     i+1,res[i], exp[i]);
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}


void
checkll(long long *res, long long *exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i]) {
	    tests_passed ++;
        } else {
             tests_failed ++;
	    if( tests_failed < 50 )
             printf( "test number %d FAILED. res %lld(%0llx)  exp %lld(%0llx)\n",
	     i+1,res[i], res[i], exp[i], exp[i] );
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}

void
checkll_(long long *res, long long *exp, int *np)
{
    checkll(res, exp, *np);
}

void
checkd(double* res, double* exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i])
	    tests_passed ++;
        else {
            tests_failed ++;
	    if( tests_failed < 50 )
            printf("test number %d FAILED. res %lg  exp %lg\n",
                      i+1, res[i], exp[i] );
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}

void
checkd_(double* res, double* exp, int* np)
{
    checkd(res, exp, *np);
}

void
checkdtol(double* res, double* exp, int n)
{
    int i;
    int tests_passed = 0;
    int tests_failed = 0;
    double tol = 0.00000000002;

    for (i = 0; i < n; i++) {
        if (exp[i] == res[i]){
	    tests_passed ++;
	}else if( exp[i] != 0.0 && ((exp[i]-res[i])/exp[i]) <= tol ){
	    tests_passed ++;
	}else if( exp[i] == 0.0 && res[i] <= tol ){
	    tests_passed ++;
        }else{
	    tests_failed ++;
	    if( tests_failed < 50 )
            printf(
	    "test number %d FAILED. res %lg  exp %lg\n",
	     i+1,res[i], exp[i]);
        }
    }
    if (tests_failed == 0) {
	printf("%3d tests completed. %d tests PASSED. %d tests failed.\n",
                      n, tests_passed, tests_failed);
    } else {
	printf("%3d tests completed. %d tests passed. %d tests FAILED.\n",
                      n, tests_passed, tests_failed);
    }
}

void
checkdtol_(double* res, double* exp, int* np)
{
    checkdtol(res, exp, *np);
}

void
fcpyf_(float *r, float f)
{
    *r = f;
}

void
fcpyf(float *r, float f)
{
    fcpyf_(r, f);
}

void
fcpyi_(int *r, int f)
{
    *r = f;
}

void
fcpyi(int *r, int f)
{
    fcpyi_(r, f);
}

#if defined(WINNT) || defined(WIN32)
void
__stdcall CHECK(int* res, int* exp, int* np)
{
    check_(res, exp, np);
}

void
__stdcall CHECKD( double* res, double* exp, int* np)
{
    checkd_(res, exp, np);
}

void
__stdcall CHECKF( double* res, double* exp, int* np)
{
    checkf_(res, exp, np);
}

void
__stdcall CHECKFTOL( double* res, double* exp, int* np)
{
    checkftol_(res, exp, np);
}

void
__stdcall CHECKDTOL( double* res, double* exp, int* np)
{
    checkdtol_(res, exp, np);
}

void
__stdcall CHECKLL(long long *res, long long *exp, int *np)
{
    checkll_(res, exp, np);
}

void
__stdcall FCPYF(float *r, float f)
{
    fcpyf_(r, f);
}

void
__stdcall FCPYI(int *r, int f)
{
    fcpyi_(r, f);
}
#endif
#ifdef __cplusplus
}
#endif

