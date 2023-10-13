#define FLT double
#define INT int

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <omp.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#include <string.h>



void mset(FLT **m, int n, int in);
void over(FLT ** mat,int size);
FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch);
void bunch(FLT **m , int sqr);
void free_matrix(FLT **m, INT nrl, INT nrh,INT ncl, INT nch);
double system_clock(FLT *x);







void invert(FLT **MAT , int sqr) {
	int i;
	MAT=matrix(1,sqr,1,sqr);
	mset(MAT,sqr,-76);
	over(MAT,sqr);
	free_matrix(MAT,1,sqr,1,sqr);
}


void mset(FLT **m, int n, int in) {
        int i,j;
    for(i=1;i<=n;i++)
       for(j=1;j<=n;j++) {
           if(i == j) {
               m[i][j]=in;
           } else {
               m[i][j]=1;
           }
       }

}


void over(FLT ** mat,int size)
{
        int k, jj, kp1, i, j, l, krow, irow;
        FLT pivot, temp;
        int sw[2000][2];
        for (k = 1 ;k<= size ; k++)
        {
                jj = k;
                if (k != size)
                {
                        kp1 = k + 1;
                        pivot = fabs(mat[k][k]);
                        for( i = kp1;i<= size ;i++)
                        {
                                temp = fabs(mat[i][k]);
                                if (pivot < temp)
                                {
                                        pivot = temp;
                                        jj = i;
                                }
                        }
                }
                sw[k][0] =k;
                sw[k][1] = jj;
                if (jj != k)
                        for (j = 1 ;j<= size; j++)
                        {
                                temp = mat[jj][j];
                                mat[jj][j] = mat[k][j];
                                mat[k][j] = temp;
                        }
                for (j = 1 ;j<= size; j++)
                        if (j != k)
                                mat[k][j] = mat[k][j] / mat[k][k];
                mat[k][k] = 1.0 / mat[k][k];
                for (i = 1; i<=size; i++)
                        if (i != k)
                                for (j = 1;j<=size; j++)
                                        if (j != k)
                                                mat[i][j] = mat[i][j] - mat[k][j] * mat[i][k];
                for (i = 1;i<=size;i++)
                        if (i != k)
                                mat[i][k] = -mat[i][k] * mat[k][k];
        }
        for (l = 1; l<=size; ++l)
        {
                k = size - l + 1;
                krow = sw[k][0];
                irow = sw[k][1];
                if (krow != irow)
                        for (i = 1; i<= size; ++i)
                        {
                                temp = mat[i][krow];
                                mat[i][krow] = mat[i][irow];
                                mat[i][irow] = temp;
                        }
        }
}


// Following based on:
// Numerical recipes in C : the art of scientific computing 
// William H. Press ... [et al.]. – 2nd ed.
FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch)
{
    INT i;
        FLT **m;
        m=(FLT **) malloc((unsigned) (nrh-nrl+1)*sizeof(FLT*));
        if (!m){
             printf("allocation failure 1 in matrix()\n");
             exit(1);
        }
        m -= nrl;
        for(i=nrl;i<=nrh;i++) {
            if(i == nrl){
                    m[i]=(FLT *) malloc((unsigned) (nrh-nrl+1)*(nch-ncl+1)*sizeof(FLT));
                    if (!m[i]){
                         printf("allocation failure 2 in matrix()\n");
                         exit(1);
                    }
                    m[i] -= ncl;
            }
            else {
                m[i]=m[i-1]+(nch-ncl+1);
            }
        }
        return m;
}

void free_matrix(FLT **m, INT nrl, INT nrh,
                          INT ncl, INT nch)
/* free a float matrix allocated by matrix() */
{
  m[nrl] += ncl;
  free((char*) (m[nrl]));
  m += nrl;
  free((char*) (m));
}

double system_clock(FLT *x) {
        double t;
        double six=1.0e-6;
        struct timeval tb;
        struct timezone tz;
        gettimeofday(&tb,&tz);
        t=(double)tb.tv_sec+((double)tb.tv_usec)*six;
        if(x){
                *x=t;
        }
        return(t);
}


#ifndef NOMAIN

int main(int argc, char **argv) {
 	FLT **mat;
	INT i,count,msize;
	double st,et,dt;
	count=40;
	msize=1000;
	if ( argc > 1 ) {
	  count=atoi(argv[1]);
	}
	if ( argc > 2 ) {
	  msize=atoi(argv[2]);
	}
	st=system_clock(0);
#pragma omp parallel for schedule (static) private(mat) 
	for( i=0;i<count;i++) {
		invert(mat, msize);
	}
	et=system_clock(0);
	printf("%g %d %d\n",et-st,count,msize);
}

#endif
