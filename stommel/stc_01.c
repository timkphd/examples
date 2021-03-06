#define FLT double
#define INT int
#include "mpi.h"
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#if macintosh
#include <console.h>
#endif


FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch);
FLT *vector(INT nl, INT nh);
INT *ivector(INT nl, INT nh);

INT mint(FLT x);
FLT walltime();
void bc(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_jacobi(FLT ** psi,FLT ** new_psi,FLT *diff,INT i1,INT i2,INT j1,INT j2);
void write_grid(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_transfer(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
void do_force (INT i1,INT i2,INT j1,INT j2);
void do_transfer(FLT ** psi,INT i1,INT i2,INT j1,INT j2);
char* unique(char *name);
FLT force(FLT y);
#define pi 3.141592653589793239
FLT **the_for;
FLT dx,dy,a1,a2,a3,a4,a5,a6;
INT nx,ny;
FLT alpha;


INT numnodes,myid,mpi_err;
#define mpi_master 0
MPI_Status status;
INT mytop,mybot;


int main(int argc, char **argv)
{
FLT lx,ly,beta,gamma;
INT steps;

FLT t1,t2;
/*FLT t3,t4,dt; */
/* FLT diff */
FLT mydiff,diff;
FLT dx2,dy2,bottom;
FLT di;
FLT **psi;     /* our calculation grid */
FLT **new_psi; /* temp storage for the grid */
INT i,j,i1,i2,j1,j2;
INT iout;

#if macintosh
        argc=ccommand(&argv);
#endif
    mpi_err=MPI_Init(&argc,&argv);
    mpi_err=MPI_Comm_size(MPI_COMM_WORLD,&numnodes);
    mpi_err=MPI_Comm_rank(MPI_COMM_WORLD,&myid);

/* ! find id of neighbors using the communicators defined above */
  mytop   = myid-1;if( mytop    < 0         )mytop   = MPI_PROC_NULL;
  mybot   = myid+1;if( mybot    == numnodes)mybot   = MPI_PROC_NULL;
    if(myid == mpi_master) {
        scanf("%d %d",&nx,&ny);
        scanf("%lg %lg",&lx,&ly);
        scanf("%lg %lg %lg",&alpha,&beta,&gamma);
        scanf("%d",&steps);
        printf("%d %d\n",nx,ny);
        printf("%g %g\n",lx,ly);
        printf("%g %g %g\n",alpha,beta,gamma);
        printf("%d\n",steps);
    }
    mpi_err=MPI_Bcast(&nx,   1,MPI_INT,   mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&ny,   1,MPI_INT,   mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&steps,1,MPI_INT,   mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&lx,   1,MPI_DOUBLE,mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&ly,   1,MPI_DOUBLE,mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&alpha,1,MPI_DOUBLE,mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&beta, 1,MPI_DOUBLE,mpi_master,MPI_COMM_WORLD);
    mpi_err=MPI_Bcast(&gamma,1,MPI_DOUBLE,mpi_master,MPI_COMM_WORLD);
 

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
/* we stripe the grid across the processors */
    j1=1;
    j2=nx;
    di=(FLT)ny/(FLT)numnodes;
    i1=mint(1.0+myid*di);
    i2=mint(1.0+(myid+1)*di)-1;
    if(myid == mpi_master)printf("numnodes= %d\n",numnodes);
    printf("myid= %d mytop=  %d mybot=  %d\n",myid,mytop,mybot);
    printf("myid= %d holds [%d:%d][%d:%d]\n",myid,i1,i2,j1,j2);
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
    t1=MPI_Wtime();
    iout=steps/100;
    if(iout == 0)iout=1;

      if(steps > 0){
       for( i=1; i<=steps;i++) {
        do_jacobi(psi,new_psi,&mydiff,i1,i2,j1,j2);
        do_transfer(psi,i1,i2,j1,j2);
        mpi_err= MPI_Reduce(&mydiff,&diff,1,MPI_DOUBLE,MPI_SUM,mpi_master,MPI_COMM_WORLD);
        if(myid == mpi_master && i % iout == 0){
           printf("%8d %15.5f\n",i,diff);
        }
      }
    }
    t2=MPI_Wtime();
    if(myid == mpi_master)printf("run time = %10.3g\n",t2-t1);
    write_grid(psi,i1,i2,j1,j2);
    mpi_err = MPI_Finalize();
    return 0;

}

 void bc(FLT ** psi,INT i1,INT i2,INT j1,INT j2){
/* sets the boundary conditions */
/* input is the grid and the indices for the interior cells */
INT j;
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



/*
The routines matrix, ivector and vector were adapted from
Numerical Recipes in C The Art of Scientific Computing
Press, Flannery, Teukolsky, Vetting
Cambridge University Press, 1988.
*/
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


INT *ivector(INT nl, INT nh)
{
	INT *v;

	v=(INT *)malloc((unsigned) (nh-nl+1)*sizeof(INT));
	if (!v) {
	    printf("allocation failure in ivector()\n");
		exit(1);
    }		
	return v-nl;
}

FLT *vector(INT nl, INT nh)
{
	FLT *v;

	v=(FLT *)malloc((unsigned) (nh-nl+1)*sizeof(FLT));
	if (!v) {
	    printf("allocation failure in vector()\n");
		exit(1);
    }		
	return v-nl;
}


void do_transfer(FLT ** psi,INT i1,INT i2,INT j1,INT j2) {
    INT num_y;
    num_y=j2-j1+3;

    if((myid % 2) == 0){ 
/* send to top */
      mpi_err=MPI_Send(&psi[i1][j1-1],  num_y,MPI_DOUBLE,mytop,10, MPI_COMM_WORLD);  
/* rec from top */
      mpi_err=MPI_Recv(&psi[i1-1][j1-1],num_y,MPI_DOUBLE,mytop,10,MPI_COMM_WORLD,&status);  
/* rec from bot */
      mpi_err=MPI_Recv(&psi[i2+1][j1-1],num_y,MPI_DOUBLE,mybot,10,MPI_COMM_WORLD,&status);
/* send to bot */
      mpi_err=MPI_Send(&psi[i2][j1-1],  num_y,MPI_DOUBLE,mybot,10, MPI_COMM_WORLD);
    }
    else{
/* rec from bot */
      mpi_err=MPI_Recv(&psi[i2+1][j1-1],num_y,MPI_DOUBLE,mybot,10,MPI_COMM_WORLD,&status);
/* send to bot */
      mpi_err=MPI_Send(&psi[i2][j1-1],  num_y,MPI_DOUBLE,mybot,10,MPI_COMM_WORLD);
/* send to top */
      mpi_err=MPI_Send(&psi[i1][j1-1],  num_y,MPI_DOUBLE,mytop,10,MPI_COMM_WORLD);
/* rec from top */
      mpi_err=MPI_Recv(&psi[i1-1][j1-1],num_y,MPI_DOUBLE,mytop,10,MPI_COMM_WORLD,&status);
    }
}


char* unique(char *name) {
        static char unique_str[40];
    int i;
    
    for(i=0;i<40;i++) unique_str[i]=(char)0;

    if(myid > 99){
        sprintf(unique_str,"%s%d",name,myid);
    }
    else {
        if(myid > 9)
            sprintf(unique_str,"%s0%d",name,myid);
        else 
            sprintf(unique_str,"%s00%d",name,myid);
    }
    return unique_str;
}

void write_grid(FLT ** psi,INT i1,INT i2,INT j1,INT j2) {
/* ! input is the grid and the indices for the interior cells */
    INT i,j,i0,j0,i3,j3;
    FILE *f18;
    if(i1==1) {
        i0=0;
    }
    else {
        i0=i1;
    }
    if(i2==nx) {
        i3=nx+1;
    }
    else {
        i3=i2;
    }
    if(j1==1) {
        j0=0;
    }
    else {
        j0=j1;
    }
    if(j2==ny) {
        j3=ny+1;
    }
    else {
        j3=j2;
    }
    f18=fopen(unique("out1c_"),"w");
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

