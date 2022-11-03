#define FLT double
#define INT int
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#if macintosh
#include <console.h>
#endif


FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch);
INT mint(FLT x);
FLT walltime();
void bc(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_jacobi(FLT ** psi,FLT ** new_psi,FLT *diff,INT i1,INT i2,INT j1,INT j2);
void write_grid(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_transfer(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_force (INT i1,INT i2,INT j1,INT j2);
FLT force(FLT y);
#define pi 3.141592653589793239
FLT **the_for;
FLT dx,dy,a1,a2,a3,a4,a5,a6;
INT nx,ny;
FLT alpha;

INT myid;
INT myrow,mycol;
INT myid_col,myid_row,nodes_row,nodes_col;

int main(int argc, char **argv)
{
FLT lx,ly,beta,gamma;
INT steps;

FLT t1,t2;
/*FLT t3,t4,dt; */
/* FLT diff */
FLT mydiff;
FLT dx2,dy2,bottom;
FLT di,dj;
FLT **psi;     /* our calculation grid */
FLT **new_psi; /* temp storage for the grid */
INT i,j,i1,i2,j1,j2;
INT iout;

#if macintosh
        argc=ccommand(&argv);
#endif
        scanf("%d %d",&nx,&ny);
        scanf("%lg %lg",&lx,&ly);
        scanf("%lg %lg %lg",&alpha,&beta,&gamma);
        scanf("%d",&steps);
        printf("%d %d\n",nx,ny);
        printf("%g %g\n",lx,ly);
        printf("%g %g %g\n",alpha,beta,gamma);
        printf("%d\n",steps);

/* calculate the constants for the calculations */
    dx=lx/(nx+1);
    dy=ly/(ny+1);
    dx2=dx*dx;
    dy2=dy*dy;
    bottom=2.0*(dx2+dy2);
    a1=(dy2/bottom)+(beta*dx2*dy2)/(2.0*gamma*dx*bottom);
    a2=(dy2/bottom)-(beta*dx2*dy2)/(2.0*gamma*dx*bottom);
    a3=dx2/bottom;
    a4=dx2/bottom;
    a5=dx2*dy2/(gamma*bottom);
    a6=pi/(ly);
/* set the indices for the interior of the grid */
    myid=0;
    nodes_row=1;
    nodes_col=1;
    myid_row=0;
    myid_col=0;
    myrow=1;
    mycol=1;
    dj=(FLT)ny/(FLT)nodes_row;
    j1=mint(1.0+myid_row*dj);
    j2=mint(1.0+(myid_row+1)*dj)-1;
    di=(FLT)nx/(FLT)nodes_col;
    i1=mint(1.0+myid_col*di);
    i2=mint(1.0+(myid_col+1)*di)-1;
    printf("%d %d %d %d %d %d %d\n",myid,myrow,mycol,i1,i2,j1,j2);
/* allocate the grid to (i1-1:i2+1,j1-1:j2+1) this includes boundary cells */
    psi=    matrix((INT)(i1-1),(INT)(i2+1),(INT)(j1-1),(INT)(j2+1));
    new_psi=matrix((INT)(i1-1),(INT)(i2+1),(INT)(j1-1),(INT)(j2+1));
    the_for=matrix((INT)(i1-1),(INT)(i2+1),(INT)(j1-1),(INT)(j2+1));
/* set initial guess for the value of the grid */
    for(i=i1-1;i<=i2+1;i++)
        for(j=j1-1;j<=j2+1;j++)
          psi[i][j]=1.0;
/* set boundary conditions */
    bc(psi,i1,i2,j1,j2);
    do_force(i1,i2,j1,j2);
/* do the jacobian iterations */
    t1=walltime();
    iout=steps/100;
    if(iout == 0)iout=1;

    for( i=1; i<=steps;i++) {
        do_jacobi(psi,new_psi,&mydiff,i1,i2,j1,j2);
       if(i % iout == 0){
           printf("%8d %15.5f\n",i,mydiff);
        }
     }
     t2=walltime();
     printf("run time = %10.3g\n",t2-t1);
     write_grid(psi,i1,i2,j1,j2);
    return 0;
}

 void bc(FLT ** psi,INT i1,INT i2,INT j1,INT j2){
/* sets the boundary conditions */
/* input is the grid and the indices for the interior cells */
int j;
/*  do the top edges */
    if(i1 ==  1) {
        for(j=j1-1;j<=j2+1;j++)
            psi[i1-1][j]=0.0;
     }
/* do the bottom edges */
    if(i2 == ny) {
        for(j=j1-1;j<=j2+1;j++)
          psi[i2+1][j]=0.0;
     }
/* do left edges */
    if(j1 ==  1) {
        for(j=i1-1;j<=i2+1;j++)
          psi[j][j1-1]=0.0;
    }
/* do right edges */
    if(j2 == nx) {
        for(j=i1-1;j<=i2+1;j++)
            psi[j][j2+1]=0.0;
     }
}

void do_jacobi(FLT ** psi,FLT ** new_psi,FLT *diff,INT i1,INT i2,INT j1,INT j2){
/*
! does a single Jacobi iteration step
! input is the grid and the indices for the interior cells
! new_psi is temp storage for the the updated grid
! output is the updated grid in psi and diff which is
! the sum of the differences between the old and new grids
*/
    INT i,j;
    *diff=0.0;
    FLT locdiff;
    locdiff=0.0;
#pragma omp parallel for schedule (static) private(i) firstprivate(a1,a2,a3,a4,a5) reduction(+ : locdiff)
    for( i=i1;i<=i2;i++) {
        for(j=j1;j<=j2;j++){
            new_psi[i][j]=a1*psi[i+1][j] + a2*psi[i-1][j] + 
                         a3*psi[i][j+1] + a4*psi[i][j-1] - 
                         a5*the_for[i][j];
            locdiff=locdiff+fabs(new_psi[i][j]-psi[i][j]);
         }
    }
#pragma omp parallel for schedule (static) private(i)
    for( i=i1;i<=i2;i++)
        for(j=j1;j<=j2;j++)
           psi[i][j]=new_psi[i][j];
    *diff=locdiff;
}

void do_force (INT i1,INT i2,INT j1,INT j2) {
/*
! sets the force conditions
! input is the grid and the indices for the interior cells
*/
    FLT y;
    INT i,j;
    for( i=i1;i<=i2;i++) {
        for(j=j1;j<=j2;j++){
            y=j*dy;
            the_for[i][j]=force(y);
        }
   }
}


FLT force(FLT y) {
    return (-alpha*sin(y*a6));
}



FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch)
{
    INT i;
	FLT **m;
	m=(FLT **) malloc((unsigned) (nrh-nrl+1)*sizeof(FLT*));
	if (!m){
	     printf("allocation failure 1 in matrix()\n");
	     exit(1);
	}
	m -= nrl;
	for(i=nrl;i<=nrh;i++) {
	    if(i == nrl){ 
		    m[i]=(FLT *) malloc((unsigned) (nrh-nrl+1)*(nch-ncl+1)*sizeof(FLT));
		    if (!m[i]){
		         printf("allocation failure 2 in matrix()\n");
		         exit(1);
		    }		
		    m[i] -= ncl;
	    }
	    else {
	        m[i]=m[i-1]+(nch-ncl+1);
	    }
	}
	return m;
}


INT mint(FLT x) {
    FLT y;
    INT j;
    j=(INT)x;
    y=(FLT)j;
    if(x-y >= 0.5)j++;
    return j;
}


FLT walltime()
{
        return((FLT)clock()/((FLT)CLOCKS_PER_SEC));  
}




void write_grid(FLT ** psi,INT i1,INT i2,INT j1,INT j2) {
/* ! input is the grid and the indices for the interior cells */
    INT i,j,i0,j0,i3,j3;
    FILE *f18;
    i0=0;
    j0=0;
    i3=i2+1;
    j3=j2+1;
    f18=fopen("out_serial","w");
    fprintf(f18,"%6d %6d\n",i3-i0+1,j3-j0+1);
    for( i=i0;i<=i3;i++){
	       for( j=j0;j<=j3;j++){
	           fprintf(f18,"%14.7g",psi[i][j]);
	           if(j != j3)fprintf(f18," ");
	       }
	       fprintf(f18,"\n");
       }
    fclose(f18);
}

