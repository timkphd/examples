//Allocate and fill memory until it breaks or you
//filled N GB where N is on the command line.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#define FLT double

/* utility routines */
FLT system_clock(FLT *x);

int main(int argc,char *argv[]) {
    char *rays[1024];
    long bsize;
    FLT t0_start;
    FLT t1_start;
    int i,n,m;
    bsize=1073741824;
    sscanf(argv[1],"%d",&n);
    system_clock(&t0_start);
    for(m=0;m<n;m++) {
       rays[m]=(char*)malloc(bsize);
       if (rays[m] == 0){
	       printf("returned 0\n");
	       exit(-1);
       }
       memset(rays[m],'.',bsize);
       system_clock(&t1_start);
       printf("%d ::  %g\n",m,t1_start-t0_start);
       }
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
