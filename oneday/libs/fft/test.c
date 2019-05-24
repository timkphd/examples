/*#include <fftw.h>*/
#include <fftw3.h>
#include <stdio.h>
#include <stdlib.h>
#define N 16
main()
{
     int i;
     fftw_complex in[N], out[N];
     float fact;
     fftw_plan p,p2;
printf(" stuff in data\n");
     for (i=0;i<N;i++) {
/*      in[i].re=(i*i); in[i].im=1; */
     	in[i][0]=(i*i); in[i][1]=1;
     }
printf(" create plans\n");
     p  = (fftw_plan)fftw_plan_dft_1d(N,in,out,FFTW_FORWARD,FFTW_ESTIMATE);
     p2 = (fftw_plan)fftw_plan_dft_1d(N,out,in,FFTW_BACKWARD,FFTW_ESTIMATE);
printf(" do it\n");
     fftw_execute(p);
     for (i=0;i<N;i++) {
/*	printf("%12.4f %12.4f\n",out[i].re,out[i].im); */
  	printf("%12.4f %12.4f\n",out[i][0],out[i][1]); 
     }
printf(" \n");
printf(" undo it\n");
     fftw_execute(p2);
     fact=1.0/(float)N;
     for (i=0;i<N;i++) {
/*	printf("%10.2f %10.2f\n",in[i].re*fact,in[i].im*fact); */
	printf("%10.2f %10.2f\n",in[i][0]*fact,in[i][1]*fact); 
     }
printf(" clean up\n");
     fftw_destroy_plan(p);  
     fftw_destroy_plan(p2);  
}

