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

FLT *svec1,*svec2,*rvec1,*rvec2;

INT numnodes,myid,mpi_err;
#define mpi_master 0
INT myrow,mycol;
INT nrow,ncol;
INT myrow,mycol;
INT myid_col,myid_row,nodes_row,nodes_col;
MPI_Status status;
MPI_Comm ROW_COMM,COL_COMM;
INT mytop,mybot,myleft,myright;


int main(int argc, char **argv)
{
FLT lx,ly,beta,gamma;
INT steps;

FLT t1,t2;
/*FLT t3,t4,dt; */
/* FLT diff */
FLT mydiff,diff;
FLT dx2,dy2,bottom;
FLT di,dj;
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
/*
! find a reasonable grid topology based on the number
! of processors
*/
  nrow=mint(sqrt((FLT)(numnodes)));
  ncol=numnodes/nrow;
  while (nrow*ncol != numnodes) {
      nrow=nrow+1;
      ncol=numnodes/nrow;
  }
  if(nrow > ncol){
      i=ncol;
      ncol=nrow;
      nrow=i;
  }
  myrow=myid/ncol+1;
  mycol=myid - (myrow-1)*ncol + 1;
  if(myid == mpi_master) printf(" nrow= %d ncol= %d\n",nrow ,ncol);
/*
! make the row and col communicators
! all processors with the same row will be in the same ROW_COMM
*/
  mpi_err=MPI_Comm_split(MPI_COMM_WORLD,myrow,mycol,&ROW_COMM);
  mpi_err=MPI_Comm_rank( ROW_COMM, &myid_row);
  mpi_err=MPI_Comm_size( ROW_COMM, &nodes_row);
/* ! all processors with the same col will be in the same COL_COMM */
  mpi_err=MPI_Comm_split(MPI_COMM_WORLD,mycol,myrow,&COL_COMM);
  mpi_err=MPI_Comm_rank( COL_COMM, &myid_col);
  mpi_err=MPI_Comm_size( COL_COMM,& nodes_col);
/* ! find id of neighbors using the communicators created above */
  mytop   = myid_col-1;if( mytop    < 0         )mytop   = MPI_PROC_NULL;
  mybot   = myid_col+1;if( mybot    == nodes_col)mybot   = MPI_PROC_NULL;
  myleft  = myid_row-1;if( myleft   < 0         )myleft  = MPI_PROC_NULL;
  myright = myid_row+1;if( myright  == nodes_row)myright = MPI_PROC_NULL;
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
    dj=(FLT)ny/(FLT)nodes_row;
    j1=mint(1.0+myid_row*dj);
    j2=mint(1.0+(myid_row+1)*dj)-1;
    di=(FLT)nx/(FLT)nodes_col;
    i1=mint(1.0+myid_col*di);
    i2=mint(1.0+(myid_col+1)*di)-1;
    if(myid == mpi_master)printf("nodes_row= %d nodes_col= %d\n",nodes_row,nodes_col);
    printf("myid= %d myrow=  %d mycol=  %d\n",myid,myrow,mycol);
    printf("myid= %d myid_row=  %d myid_col=  %d\n",myid,myid_row,myid_col);
    printf("myid= %d holds [%d:%d][%d:%d]\n",myid,i1,i2,j1,j2);
/* allocate the grid to (i1-1:i2+1,j1-1:j2+1) this includes boundary cells */
    psi=    matrix((INT)(i1-1),(INT)(i2+1),(INT)(j1-1),(INT)(j2+1));
    new_psi=matrix((INT)(i1-1),(INT)(i2+1),(INT)(j1-1),(INT)(j2+1));
    the_for=matrix((INT)(i1-1),(INT)(i2+1),(INT)(j1-1),(INT)(j2+1));
    svec1=vector((INT)(i1-1),(INT)(i2+1));
    svec2=vector((INT)(i1-1),(INT)(i2+1));
    rvec1=vector((INT)(i1-1),(INT)(i2+1));
    rvec2=vector((INT)(i1-1),(INT)(i2+1));
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
    INT num_x,num_y;
    INT i,j;
    num_x=i2-i1+3;
    num_y=j2-j1+3;
    for(i=i1-1;i<=i2+1;i++){
        svec1[i]=psi[i][j1];
        svec2[i]=psi[i][j2];
    }
    if((myid_col % 2) == 0){
/* send to left */
      mpi_err=MPI_Sendrecv(&svec1[i1-1],num_x,MPI_DOUBLE,myleft,100,
                           &rvec1[i1-1],num_x,MPI_DOUBLE,myleft,100,ROW_COMM,&status);
/* rec from right */
      mpi_err=MPI_Sendrecv(&svec2[i1-1],num_x,MPI_DOUBLE,myright,100,
                           &rvec2[i1-1],num_x,MPI_DOUBLE,myright,100,ROW_COMM,&status);
    }
    else {
/* we are on an odd col processor */
/* rec from right */
      mpi_err=MPI_Sendrecv(&svec2[i1-1],num_x,MPI_DOUBLE,myright,100,
                           &rvec2[i1-1],num_x,MPI_DOUBLE,myright,100,ROW_COMM,&status);
/* send to left */
      mpi_err=MPI_Sendrecv(&svec1[i1-1],num_x,MPI_DOUBLE,myleft,100,
                           &rvec1[i1-1],num_x,MPI_DOUBLE,myleft,100,ROW_COMM,&status);
    }
    if(myleft != MPI_PROC_NULL){
		for(i=i1-1;i<=i2+1;i++){
		    psi[i][j1-1]=rvec1[i];
		}
	}
    if(myright != MPI_PROC_NULL){
		for(i=i1-1;i<=i2+1;i++){
		    psi[i][j2+1]=rvec2[i];
		}
    }
    if((myid_row % 2) == 0){ 
/* send to top */
      mpi_err=MPI_Sendrecv(&psi[i1][j1-1],  num_y,MPI_DOUBLE,mytop,10,
                           &psi[i1-1][j1-1],num_y,MPI_DOUBLE,mytop,10,COL_COMM,&status);  
/* send to bot */
      mpi_err=MPI_Sendrecv(&psi[i2][j1-1],  num_y,MPI_DOUBLE,mybot,10,
                           &psi[i2+1][j1-1],num_y,MPI_DOUBLE,mybot,10,COL_COMM,&status);
    }
    else{
/* send to bot */
      mpi_err=MPI_Sendrecv(&psi[i2][j1-1],  num_y,MPI_DOUBLE,mybot,10,
                           &psi[i2+1][j1-1],num_y,MPI_DOUBLE,mybot,10,COL_COMM,&status);
/* send to top */
      mpi_err=MPI_Sendrecv(&psi[i1][j1-1],  num_y,MPI_DOUBLE,mytop,10,
                           &psi[i1-1][j1-1],num_y,MPI_DOUBLE,mytop,10,COL_COMM,&status);
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
    INT i,j,k,i0,j0,i3,j3;
    INT istart,iend,jstart,jend;
    INT *counts,*offsets;
    INT dj,mystart,myend,icol;
    FLT *arow;
    FILE *f18;
    
/*
! the master prints the whole grid a line at a time.
! for a given line, each processor checks to see if
! it holds part of that line and then sends the 
! number of cells held using the MPI_GATHER.  the
! MPI_GATHERV is then used to send the data
*/
    istart=i1;
    iend=i2;
    jstart=j1;
    jend=j2;
    if(istart == 1)istart=0;
    if(jstart == 1)jstart=0;
    if(iend == nx)iend=nx+1;
    if(jend == ny)jend=ny+1;
    i0=0;
    j0=0;
    i3=nx+1;
    j3=ny+1;
    if(myid == mpi_master){
        f18=fopen(unique("out5c_"),"w");
        fprintf(f18,"%6d %6d\n",i3-i0+1,j3-j0+1);
        arow=vector(j0,j3);
        offsets=ivector((INT)0,(INT)(numnodes-1));
        counts=ivector((INT)0,(INT)(numnodes-1));
        offsets[0]=0;
    }
    for( i=i0;i<=i3;i++){
       if(i >= istart && i <= iend){
           dj=jend-jstart+1;
           mystart=jstart;
           myend=jend;
           icol=i;
       }
       else {
           dj=0;
           mystart=jstart;
           myend=jstart;
           icol=istart;
       }
       mpi_err=MPI_Gather(&dj,   1,MPI_INT,
                          counts,1,MPI_INT,
                          mpi_master,MPI_COMM_WORLD);                     
       if(myid == mpi_master){ 
           for( k=1;k<=numnodes-1;k++){
	           offsets[k]=counts[k-1]+offsets[k-1];
	       }
       }
        mpi_err=MPI_Gatherv(&psi[icol][mystart],dj,           MPI_DOUBLE,
                             arow,             counts,offsets,MPI_DOUBLE,
                             mpi_master,MPI_COMM_WORLD);
       if(myid == mpi_master){
	       for( j=j0;j<=j3;j++){
	           fprintf(f18,"%14.7g",arow[j]);
	           if(j != j3)fprintf(f18," ");
	       }
	       fprintf(f18,"\n");
       }
    }
    if(myid == mpi_master)fclose(f18);

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

