#define FLT double
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* utility routines */
FLT system_clock();
void mset(FLT **m, int n, int in0);
void over(FLT ** mat,int size);
void free_matrix(FLT **m, int nrl, int nrh, int ncl, int nch) ;
FLT **matrix(int nrl,int nrh,int ncl,int nch);

int doinvert(int wait) {
	FLT **m1;
	int n=750;
	m1=matrix(1,n,1,n);
	mset(m1,n,10);
	double dt,now,t2;
	int count;
	dt=(double)wait/1000.0;
	count=0;
	now=system_clock();
	t2=now+dt;
	while(system_clock() < t2){
		over(m1,n);
		count++;
	}
	free_matrix(m1,1,n,1,n);
	return count;
}

void mset(FLT **m, int n, int in) 
{
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
        FLT sw[2000][2];
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
                                mat[jj][j] = mat[k][ j];
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

/*
The routine matrix was  adapted from
Numerical Recipes in C The Art of Scientific Computing
Press, Flannery, Teukolsky, Vetting
Cambridge University Press, 1988.
*/
FLT **matrix(int nrl,int nrh,int ncl,int nch)
{
    int i;
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

void free_matrix(FLT **m, int nrl, int nrh, 
                          int ncl, int nch) 
/* free a float matrix allocated by matrix() */
{
  m[nrl] += ncl;
  free((char*) (m[nrl]));
  m += nrl; 
  free((char*) (m)); 
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
