/*
! This program calculates an integral of a polynomial
! Inputs:
!  integer            np    = the order of the polynomial
!  double precision   poly  = array of polynomial coefficients
!  double precision   a     = lower bound for integration
!  double precision   b     = upper bound for integration
!  double precision   eps   = desired accuracy
!  integer            jmax  = maximum subdivisions for the 
!                             trapezoidal integration
! Suggested input:
! 3
! 1
! 2
! 3
! 4
! 0 1000
! 1e-20 20
!
! Output:
! Integral over the range 0 to 1000 =         1.001001e+12
!
!    Timothy H. Kaiser 
!    tkaiser@mines.edu
!    Aug 2010
*/
#define FLT double
#define INT int
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>

#define pmax 10
FLT poly[pmax];
int np;

/*
!myfunc: Evaluate a polynomial at a point (x)
!        The coefficients for the polynomial
!        are in the array poly.  The order is
!        np.
*/
FLT myfunc(FLT x){
   FLT sum,xt;
   int i;
   sum=poly[0];
   xt=x;
   for (i=1;i<=np;i++) {
     sum=sum+xt*poly[i];
     xt=xt*x;
   }
   return sum;
}


/*
! trapzd and qsimp are adapted from:
! Numerical Recipes: the art of scientific computing /William H. Press ... [et al.].
! with various additions and years of publication
! Publisher:	Cambridge University Press
!
! Taken together trapzd and qsimp calculate the integral 
! of a function over same range, a to b.  The function to
! be integrated is passed in as an argument.  EPS is the
! desired accuracy and JMAX is the maximum number of times
! that trapzd is called, each time refining the previous
! estimate of the integral.  The routine trapzd integrates
! by the trapezoidal rule.
*/

#define FUNC(x) ((*func)(x))
FLT trapzd(FLT (*func)(FLT), FLT a, FLT b, int n)
{
	FLT x,tnm,sum,del;
	static FLT s;
	int it,j;

	if (n == 1) {
		return (s=0.5*(b-a)*(FUNC(a)+FUNC(b)));
	} else {
		for (it=1,j=1;j<n-1;j++) it <<= 1;
		tnm=it;
		del=(b-a)/tnm;
		x=a+0.5*del;
		for (sum=0.0,j=1;j<=it;j++,x+=del) sum += FUNC(x);
		s=0.5*(s+(b-a)*sum/tnm);
		return s;
	}
}
#undef FUNC

FLT qsimp(FLT (*func)(FLT), FLT a, FLT b, FLT EPS, int JMAX)
{
        FLT trapzd(FLT (*func)(FLT), FLT a, FLT b, int n);
        int j;
        FLT s,st,ost,os;

        ost = os = -1.0e30;
        for (j=1;j<=JMAX;j++) {
                st=trapzd(func,a,b,j);
                s=(4.0*st-ost)/3.0;
                if (fabs(s-os) < EPS*fabs(os)) return s;
                if (s == 0.0 && os == 0.0 && j > 6) return s;
                os=s;
                ost=st;
        }
        printf("Too many steps in routine qsimp\n");
        return 0.0;
}

FLT myfunc(FLT x);
int main(int argc, char **argv) {
   FLT a,b,s,eps;
   int jmax;
   int i;
   char *aform="Integral over the range %lg to %lg = %20.7lg\n";
/*
! We are integrating a polynomial read in the order (np)
! then the coefficients (poly).
*/
   scanf("%d",&np);
   for(i=0;i<=np;i++) {
     scanf("%lf",&poly[i]);
   }
/*
! Read the lower (a) and upper (b) integrations bounds.
*/
   scanf("%lf %lf",&a,&b);
/*
! Read the desired accuracy (eps) and the 
! maximum subdivisions for the trapezoidal
! integration (jmax).
*/
   scanf("%lf %d",&eps,&jmax);
   s=qsimp(myfunc,a,b,eps,jmax);
   printf(aform,a,b,s);
}
