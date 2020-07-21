/* cc  -lm t4.c -qsmp */
#include "data.h"
#include "io.h"
/* utility routines */
FLT system_clock(FLT *x);
FLT **matrix(int nrl,int nrh,int ncl,int nch);

/* work routines */
void mset(FLT **m, int n, int in);
FLT mcheck(FLT **m, int n, int in);
void over(FLT ** mat,int size);

int main(int argc,char *argv[]) {
    FLT **m1,**m2,**m3,**m4;
    FLT t0_start;
    FLT t1_start,t1_end,e1;
    FLT t2_start,t2_end,e2;
    FLT t3_start,t3_end,e3;
    FLT t4_start,t4_end,e4;
    int n,narg,iarg;
    int diag[5];
    diag[0]=10;
    diag[1]=20;
    diag[2]=30;
    diag[3]=40;
    diag[4]=50;
    iarg=argc;
    if(iarg > 5)iarg=5;
    if(iarg > 1){
    for (narg=1;narg<=iarg;narg++) {
	diag[narg-1]=atoi(argv[narg]);
    }
    }
    for(narg=0;narg<5;narg++)
	printf("%d ",diag[narg]);
    printf("\n");
    n=diag[4];
    m1=matrix(1,n,1,n);
    m2=matrix(1,n,1,n);
    m3=matrix(1,n,1,n);
    m4=matrix(1,n,1,n);
    mset(m1,n,diag[0]);
    mset(m2,n,diag[1]);
    mset(m3,n,diag[2]);
    mset(m4,n,diag[3]);
    
    system_clock(&t0_start);

#pragma omp parallel sections
 {
#pragma omp section  
         { 
			system_clock(&t1_start);
			over(m1,n);
			over(m1,n);
			system_clock(&t1_end);
			e1=mcheck(m1,n,diag[0]);
			t1_start=t1_start-t0_start;
			t1_end=t1_end-t0_start;
         }
#pragma omp section  
         { 
			system_clock(&t2_start);
			over(m2,n);
			over(m2,n);
			system_clock(&t2_end);
			e2=mcheck(m2,n,diag[1]);
			t2_start=t2_start-t0_start;
			t2_end=t2_end-t0_start;
         }
#pragma omp section  
         { 
           system_clock(&t3_start);
           over(m3,n);
           over(m3,n);
           system_clock(&t3_end);
           e3=mcheck(m3,n,diag[2]);
           t3_start=t3_start-t0_start;
           t3_end=t3_end-t0_start;
         }
#pragma omp section  
         { 
           system_clock(&t4_start);
           over(m4,n);
           over(m4,n);
           system_clock(&t4_end);
           e4=mcheck(m4,n,diag[3]);
           t4_start=t4_start-t0_start;
           t4_end=t4_end-t0_start;
         }
 }
 io( t1_start,  t1_end,  e1,
     t2_start,  t2_end,  e2,
     t3_start,  t3_end,  e3,
     t4_start,  t4_end,  e4)   ;   
 e1=e1+e2+e3+e4;
 if (e1 < 1) {
  return 0;
 }
 else {
  return 1;
 }
}


