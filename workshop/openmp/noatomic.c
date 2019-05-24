#include <stdio.h> 
#include <stdlib.h> 
#include <omp.h> 
main() { 
    float *x,*y,*work1,*work2; 
    int *index; 
    int n,i; 
    n=1000; 
    x=(float*)malloc(n*sizeof(float)); 
    y=(float*)malloc(n*sizeof(float)); 
    work1=(float*)malloc(n*sizeof(float)); 
    work2=(float*)malloc(n*sizeof(float)); 
    index=(int*)malloc(n*sizeof(float)); 
    for( i=0;i < n;i++) { 
        index[i]=(n-i)-1; 
        x[i]=0.0; 
        y[i]=0.0; 
        work1[i]=i; 
        work2[i]=i*i; 
    } 
#pragma omp parallel for  shared(x,y,index,n) 
    for( i=0;i< n;i++) { 
        x[index[i]] += work1[i]*work1[i]; 
        y[i] += work2[i]; 
    } 
        for( i=0;i < n;i++) 
                printf("%d %g %g\n",i,x[i],y[i]); 
} 
