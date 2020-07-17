#define FLT double
#define INT int
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#if macintosh
#include <console.h>
#endif


FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch);
INT mint(FLT x);
FLT walltime();
void bc(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_jacobi(FLT ** psi,FLT ** new_psi,FLT *diff,INT i1,INT i2,INT j1,INT j2);
void write_grid(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_transfer(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_force (INT i1,INT i2,INT j1,INT j2);
FLT force(FLT y);
#define pi 3.141592653589793239
FLT **the_for;
FLT dx,dy,a1,a2,a3,a4,a5,a6;
INT nx,ny;
FLT alpha;

INT myid;
INT myrow,mycol;
INT myid_col,myid_row,nodes_row,nodes_col;
