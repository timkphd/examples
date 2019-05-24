/* linsolve.h -- header file for linsolve.c -- declarations and
 *     definitions for use in solving linear system using ScaLAPACK.
 *     Includes prototypes for BLACS functions.
 */
#ifndef LINSOLVE_H
#define LINSOLVE_H

/* Size of ScaLAPACK matrix descriptor arrays */
#define DESCRIPTOR_SIZE 10

/*===================================================================
 *
 * BLACS functions 
 */

/* Get info from BLACS */
extern void Cblacs_get(int context, int what, int *val);

/* Set up a grid of processes */
extern void Cblacs_gridinit(int* context, char* order, 
                            int nproc_rows, int nproc_cols);
/* Get process row and column numbers */
extern void Cblacs_pcoord(int context, int p, 
                          int* my_proc_row, int* my_proc_col);
/* Shut down the blacs */
extern void Cblacs_exit(int doneflag);

/*===================================================================
 *
 * Locally defined functions 
 */
void Get_input(int p, int my_rank, int* n, int* nproc_rows, int* nproc_cols,
             int* row_block_size, int* col_block_size);

void Build_input_datatype(MPI_Datatype* input_datatype,
             int* n, int* nproc_rows, int* nproc_cols,
             int* row_block_size, int* col_block_size);

void Allocate(int my_rank, char* name, void* list, int size, 
              int datatype);

void Initialize(int p, int my_rank, float* A_local, 
         int local_mat_rows, int local_mat_cols, 
         float* exact_local, int exact_local_size);

/* Use PBLAS routines psaxpy and psnrm2 to compute ||y - x||_2  */
float Norm_diff(int n, float* x_local, int* x_descrip, 
                float* y_local, int* y_descrip);

/*===================================================================
 *
 * Wrappers for PBLAS and ScaLAPACK functions
 */

/* Simplified wrapper for the PBLAS routine psgemv */
/* Compute y = A*x */
void Mat_vect_mult(int m, int n, float* A_local, int* A_descrip, 
              float* x_local, int* x_descrip, 
		  float* y_local, int* y_descrip);

/* Use PBLAS routines psaxpy and psnrm2 to compute ||x - y||_2 */
float Norm_diff(int n, float* x_local, int* x_descrip,
                float* y_local, int* y_descrip);

/* Simplified wrapper for the ScaLAPACK routine descinit */
void Build_descrip(int my_rank, char* name, int* descrip, 
                   int m, int n, 
                   int row_block_size, int col_block_size,
                   int blacs_context, int leading_dim);

/* Simplified wrapper for the ScaLAPACK routine psgesv */
/* Solve the system Ax = b.  Return solution in b */
void Solve(int my_rank, int order, float* A_local, int* A_descrip, 
           int* pivot_list, float *b_local, int* b_descrip);

/* Simplified wrapper for ScaLAPACK routine numroc */
int Get_dimension(int order, int block_size, int my_process_row_or_col,
	int nproc_rows_or_cols);

#endif
