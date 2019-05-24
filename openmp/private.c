#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>

#define FLT double
struct real_img {
    FLT xpart;
    FLT ypart;
};

struct real_img itype[9];
#pragma omp threadprivate(itype)

int *ray2;
#pragma omp threadprivate(ray2)

#define pi 3.141592653589793238462643383
void sub_1();
void sub_2(int in, int in2);
FLT sub_3(int in);
void sub_4();

void explain(char astr[]);



void sub_1() {
    int  i,j;
    FLT r,theta,x,y;
    r=0;
    theta=0;
    j=omp_get_thread_num();
    if(! itype) {
    		printf("itype not set for thread %d\n",j);
    }
    for(i=0;i<=8;i++) {
    	if(itype[i].xpart == 0 && itype[i].ypart == 0) {
    		printf("itype not copied for thread %d\n",j);
    	}
    	itype[i].xpart=itype[i].xpart*(j+1);
    	itype[i].ypart=itype[i].ypart*(j+1);
    }
    x=itype[0].xpart;
    y=itype[0].ypart;
    for(i=1;i<=8;i++) {
        x=x+itype[i].xpart;
        y=y+itype[i].ypart;
    }
    theta=atan2(y,x);
    r=sqrt(x*x+y*y);
#pragma omp critical
	{
    fflush(stdout);
    printf("from sub_1 thread %d, magnitude is thread+1= %4.2f, angle is zero=%10.8g\n",j,r,fabs(theta));
    fflush(stdout);
    }
}


void sub_2(int n,int nhalf) {
    int i,k;
    FLT x;
    k=omp_get_thread_num();
    if(ray2 == 0) {
    	ray2=(int *)malloc(10*sizeof(int));
#pragma omp critical
		{
		fflush(stdout);
		printf("(a) thread %d allocating ray2\n",k);
		}
	}
#pragma omp critical
	{
    fflush(stdout);
    printf("(b) thread %d ray2 is at %ld\n",k,ray2);
    }
    
	if(n <= nhalf) {
		for(i=0;i<10;i++) {
			ray2[i]=k+1;
		}
	}
	else {
		for(i=0;i<10;i++) {
		    if(ray2[i] != k+1) {
		    	printf("value not preserved\n");
		    }
			ray2[i]=ray2[i]+nhalf;
		}
	}
	
    x=sub_3(10);
    
#pragma omp critical
	{
    fflush(stdout);
    printf("(c) thread %d ",k);
    printf("n= %d x= %g\n",n,x);
    }
}

FLT sub_3(int in) {
	int i;
	FLT x;
	x=0.0;
	for(i=0;i<in;i++) {
		x=x+ray2[i];
	}
	return (x);
}

void sub_4() {
#pragma omp critical
	{
	fflush(stdout);
	printf("address of pointer ray2 %ld, address held in ray2 %ld, value held in ray2[0] %d\n",
	       &ray2,ray2,ray2[0]);
	}
}
main() {
	int i,j,k,max_threads;
	FLT pi4,xvect,yvect;
	
	max_threads=omp_get_max_threads();
	
	explain("a complex test of thread private with a do loop");
	explain("we pass in the array of structures ");
	explain("the structure is a 2d vector. we sum of all ");
	explain("the vectors to get us back to the real axis ");
	explain("we multiply the vectors times (thread+1) ");
	j=-1;
	itype[0].ypart=0;
	itype[0].xpart=1;
	pi4=pi/4.0;
	for(i=1;i<=8;i++) {
		yvect=sin(i*pi4);
		xvect=cos(i*pi4);
		itype[i].ypart=yvect-itype[i-1].ypart;
		itype[i].xpart=xvect-itype[i-1].xpart;
	}
	
#pragma omp parallel for copyin(itype) schedule(static,1)
	for(i=1;i<=max_threads;i++) {
		sub_1();
	}
	
	
	explain("a complex test of thread private with a do loop");
	explain("we access a threadprivate pointer allocated");
	explain("inside of the thread");
	
	j=max_threads*2;
	k=j/2;
	ray2=0;
#pragma omp parallel for copyin(ray2) schedule(static,1)
	for(i=1;i<=j;i++) {
		sub_2(i,k);
	}
#pragma omp parallel
	{
		if(ray2) {        
			printf("thread %d deallocating ray2 at %ld with value=%d\n",omp_get_thread_num(),ray2,ray2[0]);
			free(ray2);
			ray2=0;
		}
	}
	ray2=(int *)malloc(10*sizeof(int));
	ray2[0]=1234;
#pragma omp parallel for copyin(ray2) schedule(static,1)
	for(i=1;i<=k;i++) {
		sub_4();
	}
	
	
}

void explain(char astr[]){
	printf("%s\n",astr);
}

