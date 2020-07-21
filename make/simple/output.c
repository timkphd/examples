#include "headers.h"
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

