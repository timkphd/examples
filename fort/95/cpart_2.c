#include <stdio.h>
#include <stdlib.h>
struct pass {int lenc, lenf; float *c,  *f;};

void f_routine(long alpha, double *beta, double *gamma, double delta[], struct pass *arrays);

/* this routine is called by fortran but it
   also calls a fortran routine "simulation"
*/
void do_sim(){ 
	struct pass arrays;
	long alpha;
	double beta;
	double gamma;
	double *delta;
	int i;
	printf("C in do_sim\n");	
	alpha=10;
	delta=(double*)malloc(alpha*sizeof(double));
	beta=0.5;
	gamma=0;
	for (i=0;i<alpha;i++) {
		delta[i]=100*i;
	}
	arrays.lenc=10;
	arrays.lenf=10;
	arrays.c=(float*)malloc(arrays.lenc*sizeof(float));
	for (i=0;i<10;i++) {
		arrays.c[i]=i;
	}
/* call the fortran subroutine */
	f_routine(alpha, &beta, &gamma, delta, &arrays);
	printf("C back in do_sim\n");	
	printf("beta = %g gamma=%g\n",beta,gamma);
	for(i=0; i< arrays.lenc;i++) {
		printf("%g %g\n",arrays.c[i],arrays.f[i]);
	}
}
