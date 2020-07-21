/* cc  -lm t4.c -qsmp */
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#define FLT double

/* utility routines */
FLT system_clock(FLT *x);
FLT **matrix(int nrl,int nrh,int ncl,int nch);

/* work routines */
void mset(FLT **m, int n, int in);
FLT mcheck(FLT **m, int n, int in);
void over(FLT ** mat,int size);

int main(int argc,char *argv[]) {
    FLT **ms[64];
    FLT t0_start;
    FLT t1_start,t1_end,e1;
    FLT t2_start,t2_end,e2;
    FLT t3_start,t3_end,e3;
    FLT t4_start,t4_end,e4;
    int n;
    n=1024;
    ms[0]=matrix(1,n,1,n);
    ms[1]=matrix(1,n,1,n);
    ms[2]=matrix(1,n,1,n);
    ms[3]=matrix(1,n,1,n);
	mset(ms[0],n,10);
    mset(ms[1],n,20);
    mset(ms[2],n,30);
    mset(ms[3],n,40);
    
    system_clock(&t0_start);

#pragma omp parallel sections
 {
#pragma omp section  
         { 
			system_clock(&t1_start);
			over(ms[0],n);
			over(ms[0],n);
			system_clock(&t1_end);
			e1=mcheck(ms[0],n,10);
			t1_start=t1_start-t0_start;
			t1_end=t1_end-t0_start;
         }
#pragma omp section  
         { 
			system_clock(&t2_start);
			over(ms[1],n);
			over(ms[1],n);
			system_clock(&t2_end);
			e2=mcheck(ms[1],n,20);
			t2_start=t2_start-t0_start;
			t2_end=t2_end-t0_start;
         }
#pragma omp section  
         { 
           system_clock(&t3_start);
           over(ms[2],n);
           over(ms[2],n);
           system_clock(&t3_end);
           e3=mcheck(ms[2],n,30);
           t3_start=t3_start-t0_start;
           t3_end=t3_end-t0_start;
         }
#pragma omp section  
         { 
           system_clock(&t4_start);
           over(ms[3],n);
           over(ms[3],n);
           system_clock(&t4_end);
           e4=mcheck(ms[3],n,40);
           t4_start=t4_start-t0_start;
           t4_end=t4_end-t0_start;
         }
 }           
 printf("section 1 start time= %10.5g   end time= %10.5g  error= %g\n",t1_start,t1_end,e1);
 printf("section 2 start time= %10.5g   end time= %10.5g  error= %g\n",t2_start,t2_end,e2);
 printf("section 3 start time= %10.5g   end time= %10.5g  error= %g\n",t3_start,t3_end,e3);
 printf("section 4 start time= %10.5g   end time= %10.5g  error= %g\n",t4_start,t4_end,e4);
return 0;
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

FLT mcheck(FLT **m, int n, int in) {
	int i,j;
	FLT x;
    x=0.0;
    for(i=1;i<=n;i++) 
       for(j=1;j<=n;j++) {
           if(i == j) {
               x=x+fabs(m[i][j]-in); 
           } else {
               x=x+fabs(m[i][j]-1); 
           }
       }
   return x;
}

void over(FLT ** mat,int size)
{
        int k, jj, kp1, i, j, l, krow, irow;
        FLT pivot, temp;
        FLT sw[5000][2];
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

FLT system_clock(FLT *x) {
	FLT t;
	FLT six=1.0e-6;
	struct timeval tb;
	struct timezone tz;
	gettimeofday(&tb,&tz);
	t=(FLT)tb.tv_sec+((FLT)tb.tv_usec)*six;
 	if(x){
 		*x=t;
 	}
 	return(t);
}

