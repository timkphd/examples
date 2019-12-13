#include <math.h>
#include <stdio.h>
#include <stdlib.h>
/* this routine is called by fortran */
int C_Library_Function(float* sendbuf, int sendcount, float *recvcounts, float *mysum) {
int i;
float pi=3.1415926;
printf("In C mysum before loop =%g\n",*mysum);
*mysum=0.0;

for(i=0;i<sendcount;i++) {
	recvcounts[i]=sin((sendbuf[i]-1)*(2.0*pi/((sendcount-1))));
	*mysum=*mysum+recvcounts[i]*recvcounts[i];
}
printf("In C mysum after loop  = %g\n",*mysum);
return 1234;
}

/****************************/

