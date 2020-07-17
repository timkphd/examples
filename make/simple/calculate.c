#include "headers.h"
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
    for( i=i1;i<=i2;i++) {
        for(j=j1;j<=j2;j++){
            new_psi[i][j]=a1*psi[i+1][j] + a2*psi[i-1][j] + 
                         a3*psi[i][j+1] + a4*psi[i][j-1] - 
                         a5*the_for[i][j];
            *diff=*diff+fabs(new_psi[i][j]-psi[i][j]);
         }
    }
    for( i=i1;i<=i2;i++)
        for(j=j1;j<=j2;j++)
           psi[i][j]=new_psi[i][j];
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
