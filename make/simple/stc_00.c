#include "headers.h"
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
