/******
program ples
!       Parallel Linear Equation solver
!       Array A  = ( MP*MLA x NP*NLA )
!       Proc. grid is MP     x NP
!       Local mat. (al) MLA  x    NLA
!       array A(ig,jg) = 0.1*ig + 0.001*jg  (ig not= jg)
!                      = ig                 (ig    = jg)
!       Solve Ax=b, b=1
******/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifdef DOMKL
#include <mkl_cblas.h>
#include <mkl_blas.h>
#include <mkl_scalapack.h>
#endif

#ifdef NOUNDER
#define PSGESV     psgesv
#define DESCINIT   descinit
#else
#define PSGESV     psgesv_
#define DESCINIT   descinit_
#endif

extern void   Cblacs_pinfo( int* mypnum, int* nprocs);
extern void   Cblacs_get( int context, int request, int* value);
extern int    Cblacs_gridinit( int* context, char * order, int np_row, int np_col);
extern void   Cblacs_gridinfo( int context, int*  np_row, int* np_col, int*  my_row, int*  my_col);
extern void   Cblacs_gridexit( int context);
extern void   Cblacs_exit( int error_code);
extern void   Cblacs_gridmap( int* context, int* map, int ld_usermap, int np_row, int np_col);

void setarray(float *a, int myrow, int mycol, int lda_x, int lda_y);
void DESCINIT(int *idescal, int *m,int *n,int *mb,int *nb, int *dummy1 , int *dummy2 , int *icon, int *mla, int *info);

	int icon;

int main() {
	int mp=2;
	int mla=4;
	int mb=2;
	int np=2;
	int nla=4;
	int nb=2;
	int mype,npe;
	int idescal[11], idescb[11];
	float *al, *b;
	int *ipiv;
	int nprow=2 , npcol=2;
	int ib;
	int info;
	int  mp_ret, np_ret, myrow, mycol;
	int zero=0;
	int one=1;
	int  m,n;
	m=mla*mp;
	n=nla*np;
	
	Cblacs_pinfo( &mype, &npe );
	Cblacs_get( -1, 0, &icon );
	Cblacs_gridinit( &icon,"c", mp, np ); /* MP & NP = 2**x */
	Cblacs_gridinfo( icon, &mp_ret, &np_ret, &myrow, &mycol);
	info=0;
	DESCINIT(idescal, &m, &n  , &mb, &nb , &zero, &zero, &icon, &mla, &info);
	info=0;
	DESCINIT(idescb,  &m, &one, &nb, &one, &zero, &zero, &icon, &mla, &info);
	
	al=(float*)malloc(sizeof(float)*mla*nla);
	b=(float*)malloc(sizeof(float)*mla);
	ipiv=(int*)malloc(sizeof(int)*(mla+mb));
	
	setarray(al,myrow,mycol,4,4);
	printf("%3d%3d vals%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f%10.5f\n",
	myrow,mycol,al[ 0],al[ 1],al[ 2],al[ 3]
	           ,al[ 4],al[ 5],al[ 6],al[ 7]
	           ,al[ 8],al[ 9],al[10],al[11]
	           ,al[12],al[13],al[14],al[15]);
	
	
	for(ib=0;ib<mla;ib++) {
		b[ib]=1.0;
	}

/*    psgesv_(n, 1, al, 1,1,idescal, ipiv, b, 1,1,idescb,  info) */
      PSGESV(&n, &one, al, &one,&one,idescal, ipiv, b, &one,&one,idescb,  &info);
      if(mycol == 0 ){
      	printf("x=(%2d%2d)%8.4f%8.4f%8.4f%8.4f\n",myrow,mycol,b[0],b[1],b[2],b[3]);
      }
	free(al);
	free(ipiv);
	free(b);
	Cblacs_exit( 0 );
return 0;	
  }
  
float **matrix(int nrl,int nrh,int ncl,int nch);
int mod(int i, int j);

void setarray(float *a,int myrow, int mycol, int lda_x, int lda_y){
      float **aa;
      float ll,mm,cr,cc;
      int ii,jj,i,j,pr,pc,h,g;
      int nprow = 2, npcol = 2;
      int n=8,m=8,nb=2,mb=2,rsrc=0,csrc=0;
      int n_b = 1;
      int index;
      aa=matrix(1,8,1,8);
      for (i=1;i<=8;i++) {
      	for (j=1;j<=8;j++) {
         if(i == j){
           aa[i][i]=i;
         }
         else {
            aa[i][j]=0.1*i+0.001*j; 
         }
         }
      }
      for (i=1;i<=m;i++) {
      	for (j=1;j<=n;j++) {
      // finding out which pe gets this i,j element
              cr = (float)( (i-1)/mb );
              h = rsrc+(int)(cr);
              pr = mod( h,nprow);
              cc = (float)( (j-1)/mb );
              g = csrc+(int)(cc);
              pc = mod(g,nprow);
      // check if on this pe and then set a
              if (myrow == pr && mycol==pc){
      // ii,jj coordinates of local array element
      // ii = x + l*mb
      // jj = y + m*nb
                  ll = (float)( ( (i-1)/(nprow*mb) ) );
                  mm = (float)( ( (j-1)/(npcol*nb) ) );
                  ii = mod(i-1,mb) + 1 + (int)(ll)*mb;
                  jj = mod(j-1,nb) + 1 + (int)(mm)*nb;
                  index=(jj-1)*lda_x+ii;
                  index=index-1;
/*                  a(ii,jj) = aa(i,j) */
                  a[index] = aa[i][j];
              }
          }
		}

  	}

int mod(int i, int j) {
	return (i % j);
}
float **matrix(int nrl,int nrh,int ncl,int nch)
{
    int i;
	float **m;
	m=(float **) malloc((unsigned) (nrh-nrl+1)*sizeof(float*));
	if (!m){
	     printf("allocation failure 1 in matrix()\n");
	     exit(1);
	}
	m -= nrl;
	for(i=nrl;i<=nrh;i++) {
	    if(i == nrl){ 
		    m[i]=(float *) malloc((unsigned) (nrh-nrl+1)*(nch-ncl+1)*sizeof(float));
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

