#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
void subdomain( float *x, int iam,int ipoints);
void   pdomain( float *x, int iam,int ipoints);


void subdomain( float *x, int iam,int ipoints) {
    int ibot,itop,i;
    int sum;
    ibot=(iam)*ipoints+1;
    itop=ibot+ipoints-1;
    for(i=ibot;i<=itop;i++)
        x[i]=iam;
    sum=0;
    for(i=ibot;i<=itop;i++)
        sum=sum+x[i];
#pragma omp critical
    printf(" iam= %d doing %d %d %d \n",iam,ibot,itop,sum/ipoints);
}

void pdomain( float *x, int iam,int ipoints) {
    int ibot,itop,i;
    float y;
    int sum;
    ibot=(iam)*ipoints+1;
    itop=ibot+ipoints-1;
    printf(" section= %d is from %d to  %d",iam,ibot,itop);
    y=x[ibot];
    for(i=ibot;i<=itop;i++)
    	if(y != x[i]){
    		y=x[i];
    	}
    if(y == x[ibot]) {
    	printf(" and contains %g\n",y);
    }
    else
    	printf(" failed\n");
}

main () {
	int i,iam,np,npoints,ipoints;
	float *x;
	x=0;
#pragma omp parallel shared(x,npoints,np) default(none) private(iam,ipoints)
	{
		npoints=2*3*4*5*7;
		iam = omp_get_thread_num();
		np = omp_get_num_threads();
#pragma omp single
		{
			if(x !=0)printf("single fails\n");
			x=(float *)malloc((unsigned)npoints*sizeof(float));
			x--;
		}
#pragma omp barrier
		ipoints = npoints/np;
		subdomain(x,iam,ipoints);
	}
	printf("outside of the parallel region\n");
    for(i=0;i < np;i++) {
       ipoints = npoints/np;
       pdomain(x,i,ipoints);
    }
}

