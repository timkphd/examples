/************************************************************

Shows the effects of cache blocking on a matrix multiply like
operation.

Ref: http://cseweb.ucsd.edu/classes/wi12/cse240A-a/cache2.pdf

If this program seg faults on startup you need to increase your
stack size.  On some machines (OSX) the compile line shown
below will fix the issue.  On others you may need to run ulimit.

cc -Wl,-stack_size,0x10000000,-stack_addr,0xc0000000 -O3 block.c

Timothy H. Kaiser, Ph.D.
Director of Research and High Performance Computing
Director Golden Energy Computing Organization
tkaiser@mines.edu

************************************************************/
/****
[tkaiser@mio cache]$ date
Fri Jan 11 09:50:43 MST 2013

[tkaiser@mio cache]$ icc -O3 block.c 
[tkaiser@mio cache]$ ./a.out
Array size 1024 x 1024
Memory usage 24576 Kbytes
did y and z
                Time       Test       Blocking
                           Value      Factor  
did normal       11.334    257.647
did blocking      2.173    257.647    B=32
did normal       11.736    257.647
did blocking      2.636    257.647    B=64
did normal       11.466    257.647
did blocking      2.880    257.647    B=128
did normal       11.689    257.647
did blocking      2.919    257.647    B=256
[tkaiser@mio cache]$ 
****/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define N 1024 
#define MIN(a,b) (((a)<(b))?(a):(b))
#define FLT double
double MYCLOCK();
int main(int argc,char **argv)
{
int i,j,k,jj,kk,B,it;
FLT x[N][N],y[N][N],z[N][N];
FLT r;
double t1,t2,t3,t4;
int bray[4];
bray[0]=32;
bray[1]=64;
bray[2]=128;
bray[3]=256;

printf("Array size %d x %d\n",(int)N,(int)N);
printf("Memory usage %d Kbytes\n",(int)((3*N*N*sizeof(FLT))/1024));

for (i=0; i< N; i=i+1) for (j=0; j< N; j=j+1) y[i][j]=(double)rand()/(double)RAND_MAX;
for (i=0; i< N; i=i+1) for (j=0; j< N; j=j+1) z[i][j]=(double)rand()/(double)RAND_MAX;
printf("did y and z\n");
printf("                Time       Test       Blocking\n");
printf("                           Value      Factor  \n");
for (it=0;it<4;it++) {
for (i=0; i< N; i=i+1) for (j=0; j< N; j=j+1) x[10][10]=0.0;
t1=MYCLOCK();
	for (i=0; i< N; i=i+1)
		for (j=0; j< N; j=j+1) {
			r=0.0;
			for (k=0; k < N; k=k+1) {
				r=r +y[i][k]*z[k][j];
			}
			x[i][j]=r;
		}
t2=MYCLOCK()-t1;

printf("did normal   %10.3f    %g\n",t2,x[10][10]);
for (i=0; i< N; i=i+1) for (j=0; j< N; j=j+1) x[i][j]=0.0;
t1=MYCLOCK();
B=bray[it];
for (jj=0; jj< N; jj=jj+B) 
for (kk=0; kk< N; kk=kk+B) {
	for (i=0; i< N; i=i+1)
		for (j=jj; j< MIN(jj+B,N); j=j+1) {
			r=0.0;
			for (k=kk; k < MIN(kk+B,N); k=k+1) {
				r=r +y[i][k]*z[k][j];
			}
			x[i][j]=x[i][j]+r;
		}
}
t2=MYCLOCK()-t1;
printf("did blocking %10.3f    %g    B=%d\n",t2,x[10][10],B);
}
/*
*/
}
#include <sys/time.h>
#include <unistd.h>
double MYCLOCK()
{
        struct timeval timestr;
        void *Tzp=0;
        gettimeofday(&timestr, Tzp);
        return ((double)timestr.tv_sec + 1.0E-06*(double)timestr.tv_usec);
}
