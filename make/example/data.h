#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#ifndef FLT
#define FLT double
#endif
void mset(FLT **m, int n, int in);
FLT mcheck(FLT **m, int n, int in);
void over(FLT ** mat,int size);
FLT **matrix(int nrl,int nrh,int ncl,int nch);
FLT system_clock(FLT *x);
