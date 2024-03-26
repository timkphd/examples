#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

/* utility routines */
double system_clock(double *x);
void mysleep(float t); 

#ifdef ISLEEP
#define MYSLEEP mysleep
#else
#define MYSLEEP sleep
#endif

int main(int argc,char *argv[]) {
#define MGB 2048
    char *rays[MGB];
    long bsize;
    double t0_start;
    double t1_start;
    double t2_start;
    float dt;
    int i,n,m;
    dt=-1;
    bsize=1073741824;
    n=MGB;
    if(argc > 1)sscanf(argv[1],"%d",&n);
    if(argc > 2)sscanf(argv[2],"%f",&dt);
    system_clock(&t0_start);
    t2_start=t0_start;
    for(m=0;m<n;m++) {
       rays[m]=(char*)malloc(bsize);
       if (rays[m] == 0){
	       printf("returned 0\n");
	       exit(-1);
       }
       memset(rays[m],'.',bsize);
       system_clock(&t1_start);
       printf("%6d ::  %15.7f %15.7f %10.3f\n",m+1,t1_start-t0_start,t1_start-t2_start,(bsize/(t1_start-t2_start))*1e-9);
       t2_start=t1_start;
       if((dt > 0.0) && (m < (n-1))){
	       printf("sleeping %8.2f\n",dt);
	       MYSLEEP(dt);
       }
    }
}

double system_clock(double *x) {
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

void mysleep(float t) {
	double now,t2;
	system_clock(&now);
	t2=now+t;
	while (now < t2 ) {
		system_clock(&now);
	}
}

