#include <stdio.h> 
#include <stdlib.h> 
#include <omp.h> 
main() { 
    float *x,*y,*work1,*work2; 
    float sum;
    int *index; 
    int n,i; 
    n=1000; 
    x=(float*)malloc(n*sizeof(float)); 
    y=(float*)malloc(n*sizeof(float)); 
    work1=(float*)malloc(n*sizeof(float)); 
    work2=(float*)malloc(n*sizeof(float)); 
    index=(int*)malloc(n*sizeof(float)); 
    srand((unsigned) n);
    for( i=0;i < n;i++) { 
//        index[i]=(n-i)-1; 
        index[i]=(rand() % (n/10));
        x[i]=0.0; 
        y[i]=0.0; 
        work1[i]=i; 
        work2[i]=i*i; 
    } 
    sum=0;
#pragma omp parallel for  shared(x,y,index,n,sum) 
    for( i=0;i< n;i++) { 
#pragma omp atomic 
        x[index[i]] += work1[i]; 
#pragma omp atomic 
	sum+= work1[i];
        y[i] += work2[i]; 
    } 
        for( i=0;i < n;i++) 
                printf("%d %g %g\n",i,x[i],y[i]); 
    printf("sum %g\n",sum);
} 
