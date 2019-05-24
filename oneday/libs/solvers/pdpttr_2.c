/**********************************************************************/
/*                                                                    */
/* This program illustrates the use of the ScaLAPACK routines         */
/* PDPTTRF and PDPTTRS to factor and solve a symmetric positive       */
/* definite tridiagonal system of linear equations T*x = b in         */
/* two distinct contexts.                                             */
/*                                                                    */
/* Using Matlab notation, if we define                                */
/*                                                                    */
/* T = diag(D)+diag(E,-1)+diag(E,1)                                   */
/*                                                                    */
/* and set                                                            */
/*                                                                    */
/* D = [ 1.8180 1.6602 1.3420 1.2897 1.3412 1.5341 1.7271 1.3093 ]    */
/* E = [ 0.8385 0.5681 0.3704 0.7027 0.5466 0.4449 0.6946 ]           */
/*                                                                    */
/* then,                                                              */
/*                                                                    */
/* if b = [ 1 2 3 4 5 6 7 8 ]                                         */
/* x = [ 0.3002 0.5417 1.4942 1.8546 1.5008 3.0806 1.0197 5.5692 ]    */
/*                                                                    */
/* if b = [ 8 7 6 5 4 3 2 1 ]                                         */
/* x = [ 3.9036 1.0772 3.4122 2.1837 1.3090 1.2988 0.6563 0.4156 ]    */
/*                                                                    */
/* Note that PDPTTRS overwrites b with x. Also, D, E and b have been  */
/* hardcoded, which means that this code is not malleable - it works  */
/* only with four processors.                                         */
/*                                                                    */
/* The following has been tested on an IBM SP (and should be changed  */
/* depending on the target platform):                                 */
/*                                                                    */
/* % module load scalapack                                            */
/* % mpcc -c pdpttr_2.c                                               */
/* % mpxlf -o pdpttr_2.x pdpttr_2.o $SCALAPACK $PBLAS $BLACS -lessl   */
/* % poe pdpttr_2.x -procs 4                                          */
/*                                                                    */
/**********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mpi.h"
#include <mkl_cblas.h>
#include <mkl_blas.h>
#include <mkl_scalapack.h>

#define max(A,B) ((A)>(B)?(A):(B))
#define min(A,B) ((A)>(B)?(B):(A))


extern void   Cblacs_pinfo( int* mypnum, int* nprocs);
extern void   Cblacs_get( int context, int request, int* value);
extern int    Cblacs_gridinit( int* context, char * order, int np_row, int np_col);
extern void   Cblacs_gridinfo( int context, int*  np_row, int* np_col, int*  my_row, int*  my_col);
extern void   Cblacs_gridexit( int context);
extern void   Cblacs_exit( int error_code);
extern void   Cblacs_gridmap( int* context, int* map, int ld_usermap, int np_row, int np_col);


main()
{

   int     context, context_1, context_2, desca[9], descb[9], ib, 
           info, ja, laf, lda, ldb, lwork, map[2], mb, mype, n, 
           nb, npcol, npe, nrhs;
   double  b[4], d[4], e[4];
   double  *af, *work;
 
   /* Set array dimensions and blocking */

   n=8; nrhs=1;
   lda=4; ldb=4;
   ja=1; ib=1;
   mb=4; nb=4;
   npcol = 2;
 
   laf=12*npcol+3*nb;
   lwork=max(8*npcol,(10+2*min(100,nrhs))*npcol+4*nrhs);
 
   af = (double *)malloc(laf*sizeof(double));
   work = (double *)malloc(lwork*sizeof(double));
 
   /* Start BLACS */
 
   Cblacs_pinfo( &mype, &npe );
   Cblacs_get( 0, 0, &context );
   Cblacs_gridinit( &context, "R", 1, npe );
 
   /* Processes 0 and 2 contain d(1:4) and e(1:4) */
   /* Processes 1 and 3 contain d(5:8) and e(5:8) */
 
   if      ( mype == 0 || mype == 2 ){
           d[0]=1.8180; d[1]=1.6602; d[2]=1.3420; d[3]=1.2897;
           e[0]=0.8385; e[1]=0.5681; e[2]=0.3704; e[3]=0.7027;
   }
   else if ( mype == 1 || mype == 3 ){
           d[0]=1.3412; d[1]=1.5341; d[2]=1.7271; d[3]=1.3093;
           e[0]=0.5466; e[1]=0.4449; e[2]=0.6946; e[3]=0.0000;
   }

   if ( mype == 0 || mype == 1 ) {
 
      /* New context for processes 0 and 1 */

      map[0]=0; map[1]=1;
      Cblacs_get( context, 10, &context_1 );
      Cblacs_gridmap( &context_1, map, 1, 1, 2 );
 
      /* Right-hand side is set to b = [ 1 2 3 4 5 6 7 8 ] */

      if      ( mype == 0 ) {   
              b[0]=1.0; b[1]=2.0; b[2]=3.0; b[3]=4.0; 
      }
      else if ( mype == 1 ) {
              b[0]=5.0; b[1]=6.0; b[2]=7.0; b[3]=8.0; 
      }

      /* Array descriptor for A (D and E) */
 
      desca[0]=501; desca[1]=context_1; desca[2]=n; desca[3]=nb;
      desca[4]=0; desca[5]=lda; desca[6]=0;
 
      /* Array descriptor for B */
 
      descb[0]=502; descb[1]=context_1; descb[2]=n; descb[3]=nb;
      descb[4]=0; descb[5]=ldb; descb[6]=0;

      /* Factorization */
 
      pdpttrf_( &n, d, e, &ja, desca, af, &laf, 
               work, &lwork, &info );

      /* Solution */

      pdpttrs_( &n, &nrhs, d, e, &ja, desca, b, &ib, descb,  
               af, &laf, work, &lwork, &info );
 
      printf( "MYPE=%i: x[:] = %7.4f %7.4f %7.4f %7.4f\n", 
              mype, b[0], b[1], b[2], b[3]);

   } 

   else {
    
      /* New context for processes 0 and 1 */

      map[0]=2; map[1]=3;
      Cblacs_get( context, 10, &context_2 );
      Cblacs_gridmap( &context_2, map, 1, 1, 2 );
    
      /* Right-hand side is set to b = [ 8 7 6 5 4 3 2 1 ] */

      if      ( mype == 2 ) {
              b[0]=8.0; b[1]=7.0; b[2]=6.0; b[3]=5.0;
      }
      else if ( mype == 3 ) {
              b[0]=4.0; b[1]=3.0; b[2]=2.0; b[3]=1.0;
      }
    
      /* Array descriptor for A (D and E) */
    
      desca[0]=501; desca[1]=context_2; desca[2]=n; desca[3]=nb; 
      desca[4]=0; desca[5]=lda; desca[6]=0;
    
      /* Array descriptor for B */

      descb[0]=502; descb[1]=context_2; descb[2]=n; descb[3]=nb;
      descb[4]=0; descb[5]=ldb; descb[6]=0;
 
      /* Factorization */
 
      pdpttrf_( &n, d, e, &ja, desca, af, &laf, 
               work, &lwork, &info );

      /* Solution */

      pdpttrs_( &n, &nrhs, d, e, &ja, desca, b, &ib, descb,  
               af, &laf, work, &lwork, &info );

      printf( "MYPE=%i: x[:] = %7.4f %7.4f %7.4f %7.4f\n", 
              mype, b[0], b[1], b[2], b[3]);

   }

   Cblacs_gridexit( context );
   Cblacs_exit( 0 );
 
}