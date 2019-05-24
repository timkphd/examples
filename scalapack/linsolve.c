/*
mpixlc_r linsolve.c  -DNOUNDER -L$LAPACK_ROOT/lib64 -L$ESSL_ROOT/lib64 
-L$SCALAPACK_ROOT/lib64 -llapack -lscalapack -lblas -llapack -lblas -lscalapack 
-L/opt/ibmcmp/xlf/bg/14.1/lib64 -lxlopt -lxl -lxlf90 -lxlfmath -o linsolve
*/
/* linsolve.c
 *
 *   Use Scalapack and MPI to solve a system of linear equations
 *   on a virtual rectangular grid of processes.
 *
 *   Input:
 *       n: order of linear system
 *       nproc_rows: number of rows in process grid
 *       nproc_cols: number of columns in process grid
 *       row_block_size:  blocking size for matrix rows
 *       col_block_size:  blocking size for matrix columns
 *
 *   Output:
 *       Input data, error in solution, and time to solve system.
 *
 *   Algorithm:
 *	1.  Initialize MPI and BLACS.
 *      2.  Get process rank (my_rank) and total number of 
 *          processes (p).
 *      3a. Process 0 read and broadcast matrix order (n),
 *          number of process rows (nproc_rows), number 
 *          of process columns (nproc_cols), row_block_size,
 *	    and col_block_size.
 *      3b. Process != 0 receive same.
 *      4.  Use Cblacs_gridinit to set up process grid.
 *      5.  Compute amount of storage needed for local arrays,
 *          and attempt to allocate.
 *      6.  Use ScaLAPACK routine descinit to initialize
 *          descriptors for A, exact (= exact solution), and b.
 *      7.  Use random number generator to generate contents 
 *          of local block of matrix (A_local).
 *      8.  Set entries of exact to 1.0.
 *	9.  Generate b by computing b = A*exact.  Use
 *          PBLAS routine psgemv.
 *     10.  Solve linear system by call to ScaLAPACK routine
 *          psgesv (solution returned in b). 
 *     11.  Use PBLAS routines psaxpy and psnrm2 to compute
 *          the norm of the error ||b - exact||_2.
 *     12.  Process 0 print results.
 *     13.  Shutdown BLACS and MPI.
 *
 *   Notes:
 *      1.  The vectors, exact and b, are significant only
 *          in the first process column.
 *      2.  A_local is allocated as a linear array.
 *      3.  In order that a row block of the matrix be multiplied
 *          by a column block of a vector, it's necessary that
 *          row_block_size = col_block_size, i.e., blocks must
 *          be square.
 *      4.  Beware:  matrices are column major.
 *      5.  Beware:  x[0] in C -> x(1) in FORTRAN
 *      6.  Naming of fortran subprograms (lower case followed
 *          by an underscore) will not work on many systems.
 *
 *   See Chap 15, pp. 340 & ff, in PPMPI.
 */

#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"
#include "linsolve.h"  /* Function prototypes, including BLACS prototypes */

#ifdef NOUNDER
#define PSAXPY     psaxpy
#define PSNRM2     psnrm2
#define PSGESV     psgesv
#define PSGEMV     psgemv
#define SLARNV     slarnv
#define DESCINIT   descinit
#define NUMROC     numroc
#else
#define PSAXPY     psaxpy_
#define PSNRM2     psnrm2_
#define PSGESV     psgesv_
#define PSGEMV     psgemv_
#define SLARNV     slarnv_
#define DESCINIT   descinit_
#define NUMROC     numroc_
#endif


/*===================================================================*/
main(int argc, char** argv) {
    float*	b_local;
    int		b_local_size;
    int		b_descrip[DESCRIPTOR_SIZE];  /* X_descrip provides */
                /* information on the size and layout of the dis-  */
                /* tributed array X.  See ScaLAPACK routine desc-  */
                /* init for details.                               */

    float*	exact_local;
    int		exact_local_size;
    int		exact_descrip[DESCRIPTOR_SIZE];

    float*	A_local;
    int		local_mat_rows;
    int		local_mat_cols;
    int		A_descrip[DESCRIPTOR_SIZE];
    int*	pivot_list;

    int 	p;
    int		my_rank;
    int		nproc_rows;
    int		nproc_cols;
    int		m, n;             /* matrix order */
    int		row_block_size;
    int		col_block_size;
    int		blacs_grid;    /* internal description of process */
                                  /* grid                            */
    int		i;
    int		my_process_row;
    int		my_process_col;
    float	error_2;
    double 	start_time;
    double 	elapsed_time;

    /* Initialize MPI */
    MPI_Init(&argc, &argv);

    MPI_Comm_size(MPI_COMM_WORLD, &p);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    Get_input(p, my_rank, &n, &nproc_rows, &nproc_cols,
             &row_block_size, &col_block_size);

    /* The matrix is square */
    m = n;

    /* Build BLACS grid */
    /* First get BLACS System Context */
    Cblacs_get(0, 0, &blacs_grid);

    /* blacs_grid is in/out. */
    /* "R": process grid will use row major ordering. */
    Cblacs_gridinit(&blacs_grid, "R", nproc_rows, nproc_cols);

    /* Get my process coordinates in the process grid */
    Cblacs_pcoord(blacs_grid, my_rank, &my_process_row, 
                  &my_process_col);

#ifdef DEBUG
    printf("myid %d at %10.5f\n",my_rank,1.0);
#endif
    /* Figure out space needs for the arrays and attempt to */
    /* malloc storage. */
    local_mat_rows = Get_dimension(m, row_block_size, 
                                   my_process_row, nproc_rows);
    local_mat_cols = Get_dimension(n, col_block_size, 
                                   my_process_col, nproc_cols);
    Allocate(my_rank, "A", &A_local, local_mat_rows*local_mat_cols, 1);

    b_local_size = Get_dimension(m, row_block_size, 
                                 my_process_row, nproc_rows);
    Allocate(my_rank, "A", &b_local, b_local_size, 1.1);

    exact_local_size = Get_dimension(m, col_block_size, 
                                     my_process_row, nproc_rows);
    Allocate(my_rank, "A", &exact_local, exact_local_size, 1);

#ifdef DEBUG
    printf("myid %d at %10.5f\n",my_rank,2.0);
#endif

    /* Now build the matrix descriptors */
    Build_descrip(my_rank, "A", A_descrip, m, n, row_block_size, 
                  col_block_size, blacs_grid, local_mat_rows);
    Build_descrip(my_rank, "B", b_descrip, m, 1, row_block_size, 
                  1, blacs_grid, b_local_size);
    Build_descrip(my_rank, "Exact", exact_descrip, n, 1, 
                  col_block_size, 1, blacs_grid, exact_local_size);
 #ifdef DEBUG
   printf("myid %d at %10.5f\n",my_rank,3.0);
#endif


    /* Initialize A_local and exact_local */
    Initialize(p, my_rank, A_local, local_mat_rows, local_mat_cols, 
               exact_local, exact_local_size);
#ifdef DEBUG
    printf("myid %d at %10.5f\n",my_rank,3.1);
#endif


    /* Set b = A*exact */
    Mat_vect_mult(m, n, A_local, A_descrip, exact_local, 
                  exact_descrip, b_local, b_descrip);
#ifdef DEBUG
    printf("myid %d at %10.5f\n",my_rank,3.2);
#endif


    /* Allocate storage for pivots */
    Allocate(my_rank, "pivot_list", &pivot_list, 
             local_mat_rows + row_block_size, 0);
#ifdef DEBUG
    printf("myid %d at %10.5f\n",my_rank,4.0);
#endif


    /* Done with setup!  Solve the system. */
    MPI_Barrier(MPI_COMM_WORLD);
    start_time = MPI_Wtime();
    Solve(my_rank, n, A_local, A_descrip, pivot_list, 
               b_local, b_descrip);
    elapsed_time = MPI_Wtime() - start_time;
/*
    for (i = 0; i < b_local_size; i++)
        printf("Process %d > b_local[%d] = %f\n", 
           my_rank, i, b_local[i]);
    for (i = 0; i < exact_local_size; i++)
        printf("Process %d > exact_local[%d] = %f\n", 
           my_rank, i, exact_local[i]);
*/

    /* Compute norm of error */
    error_2 = Norm_diff(n, b_local, b_descrip, exact_local, 
                        exact_descrip);


    /* Print results */
    if (my_rank == 0) {
        printf("n = %d, p = %d\n", n, p);
        printf("Process rows = %d, Process columns = %d\n", 
               nproc_rows, nproc_cols);
        printf("Row block size = %d, Column block_size = %d\n",
               row_block_size, col_block_size);
        printf("2-norm of error = %g\n",error_2);
        printf("Elapsed time for solve = %g milliseconds\n", 
               1000.0*elapsed_time);
    }


    /* Now free up allocated resources and shut down */
    /* Call Cblacs_exit.  Argument != 0 says, "User program */
    /*    will shut down MPI." */
    Cblacs_exit(1);
    MPI_Finalize();
}  /* main */


/*===================================================================
 *
 * Process 0 read and broadcast input data
 */
void Get_input(int p, int my_rank, int* n, int* nproc_rows, 
             int* nproc_cols,
             int* row_block_size, int* col_block_size) {

    MPI_Datatype input_datatype;

    Build_input_datatype(&input_datatype, n, nproc_rows,
            nproc_cols, row_block_size, col_block_size);

    if (my_rank == 0) 
        scanf("%d %d %d %d %d", n, nproc_rows, 
              nproc_cols, row_block_size, col_block_size);

    MPI_Bcast(n, 1, input_datatype, 0, MPI_COMM_WORLD);

    if (p < ((*nproc_rows)*(*nproc_cols))) {
        fprintf(stderr, 
           "Process %d > p = %d, nproc_rows = %d, nproc_cols = %d\n",
            my_rank, p, *nproc_rows, *nproc_cols);
        fprintf(stderr, "Process %d > Need more processes!  Quitting.", 
                my_rank);
        MPI_Abort(MPI_COMM_WORLD, -1);
    }
}  /* Get_input */


/*===================================================================
 *
 * Build derived datatype for distributing input data
 */
void Build_input_datatype(MPI_Datatype* input_datatype, 
    int* n, int* nproc_rows, int* nproc_cols, 
    int* row_block_size, int* col_block_size) {

    int 	array_of_block_lengths[5];
    MPI_Aint 	array_of_displacements[5];
    MPI_Aint 	base_address; 
    MPI_Aint  	temp_address;
    int		i;
    MPI_Datatype  array_of_types[5]; 

    for (i = 0; i < 5; i++) {
	array_of_block_lengths[i] = 1;
        array_of_types[i] = MPI_INT;
    }
 
    /* Compute displacements from n */
    array_of_displacements[0] = 0; 
    MPI_Address(n, &base_address);
    MPI_Address(nproc_rows, &temp_address);
    array_of_displacements[1] = temp_address - base_address;
    MPI_Address(nproc_cols, &temp_address);
    array_of_displacements[2] = temp_address - base_address;
    MPI_Address(row_block_size, &temp_address);
    array_of_displacements[3] = temp_address - base_address;
    MPI_Address(col_block_size, &temp_address);
    array_of_displacements[4] = temp_address - base_address;

    MPI_Type_struct(5, array_of_block_lengths, array_of_displacements, 
                    array_of_types, input_datatype);
    MPI_Type_commit(input_datatype);

}  /* Build_input_datatype */
 

/*===================================================================
 *
 * Simplified wrapper for ScaLAPACK routine numroc                   
 * numroc computes minimum number of rows or columns needed to store 
 * a process' piece of a distributed array                          
 */
int Get_dimension(int order, int block_size, int my_process_row_or_col,
	int nproc_rows_or_cols) {

    int first_process_row_or_col = 0;  /* Assume array begins in row */
                                       /* or column 0.               */
    int return_val;

    extern int NUMROC(int* order, int* block_size, 
           int* my_process_row_or_col, int* first_process_row_or_col,
           int* nproc_rows_or_cols);

    return_val = NUMROC(&order, &block_size, &my_process_row_or_col,
                 &first_process_row_or_col, &nproc_rows_or_cols);
    return return_val;
}  /* Get_dimension */
    

/*===================================================================
 * 
 * Allocate a list of ints or floats.  On error exit.  
 * datatype = 0 => int,  datatype = 1 => float.
 */
void Allocate(int my_rank, char* name, void* list, int size,
              int datatype) {
    int error = 0;

    if (datatype == 0) {
        *((int**)list) = (int*) malloc(size*sizeof(int));
        if (*((int**)list) == (int*) NULL) error = 1;
    } else {
        *((float**)list) = (float*) malloc(size*sizeof(float));
        if (*((float**)list) == (float*) NULL) error = 1;
    }

    if (error) {
        fprintf(stderr, "Process %d > Malloc failed for %s!\n", 
                my_rank, name); 
        fprintf(stderr, "Process %d > size = %d\n", my_rank, size);  
        fprintf(stderr, "Process %d > Quitting.\n", my_rank);
        MPI_Abort(MPI_COMM_WORLD, -1);
    }
}  /* Allocate */


/*===================================================================
 * 
 * Simplified wrapper for the ScaLAPACK routine descinit, which
 * initializes the descrip array associated to each distributed
 * matrix or vector.
 */
void Build_descrip(int my_rank, char* name, int* descrip, 
                   int m, int n, int row_block_size,
                   int col_block_size, int blacs_grid, 
                   int leading_dim) {
    int first_proc_row = 0;  /* Assume all distributed arrays begin */
    int first_proc_col = 0;  /* in process row 0, process col 0     */
    int error_info;

    extern void DESCINIT(int* descrip, int* m, int* n, 
                int* row_block_size, int* col_block_size, 
                int* first_proc_row, int* first_proc_col, 
                int* blacs_grid, int* leading_dim,
                int* error_info);

    DESCINIT(descrip, &m, &n, &row_block_size, &col_block_size,
              &first_proc_row, &first_proc_col, &blacs_grid,
              &leading_dim, &error_info);

    if (error_info != 0) {
        fprintf(stderr, "Process %d > Descinit for b failed.\n",
                my_rank);
        fprintf(stderr, "Process %d > error_info = %d\n", 
                my_rank, error_info);
        fprintf(stderr, "Process %d > Quitting.\n", my_rank);
        MPI_Abort(MPI_COMM_WORLD, -1);
    }
}  /* Build_descrip */


/*===================================================================
 *
 * Use LAPACK random number generator slarnv to initialize A.
 * Set exact[i] = 1.0, for all i.
 */
void Initialize(int p, int my_rank, float* A_local, int local_mat_rows, 
         int local_mat_cols, float* exact_local, 
         int exact_local_size) {
    int distribution_type = 2; /* uniform distribution over (-1,1) */
    int iseed[4];
    int i, j;
    int temp = 4;

    /* Generate a list of random floats */
    extern void SLARNV(int* distribution, int* iseed, 
                int* count, float* list);

    /* iseed[3] must be odd. */
    iseed[0] = iseed[1] = iseed[2] = iseed[3] = 2*my_rank+1;

    /* iseed is in/out. This call should give us a better set of
     * values for iseed for the actual matrix generation */
/*
    distribution_type = 1;
    SLARNV(&distribution_type, iseed, &temp, A_local);
    iseed[0] = ((int) (4096.0*A_local[0])) % 4096;
    iseed[1] = ((int) (4096.0*A_local[1])) % 4096;
    iseed[2] = ((int) (4096.0*A_local[2])) % 4096;
    iseed[3] = ((int) (4096.0*A_local[3])) % 4096;
    if ((iseed[3] % 2) == 0) iseed[3]++;
    printf("iseed = %d %d %d %d\n",iseed[0],iseed[1],iseed[2],iseed[3]);

    iseed[0] = my_rank;
    iseed[1] = my_rank*my_rank;
    iseed[2] = p - my_rank;
    iseed[3] = 2*my_rank + 1;

    distribution_type = 2;
*/
    for (j = 0; j < local_mat_cols; j++) {
        SLARNV(&distribution_type, iseed, 
                &local_mat_rows, A_local + (j*local_mat_rows));
        #ifdef DEBUG
        {
            int k;
            printf("Process %d > Column %d:",my_rank,j);
            for (k = 0; k < local_mat_rows; k++) 
                printf(" %f", A_local[j*local_mat_rows+k]);
            printf("\n");
            fflush(stdout);
        }
        #endif
    }  /*  for  */

    for (i = 0; i < exact_local_size; i++)
        exact_local[i] = 1.0;
}  /* Initialize */


/*===================================================================
 *
 * Simplified wrapper for the PBLAS routine psgemv. 
 * Compute y = A*x.
 */
void Mat_vect_mult(int m, int n, float* A_local, int* A_descrip, 
                  float* x_local, int* x_descrip, 
		  float* y_local, int* y_descrip) {
    
    char transpose = 'N';   /* Don't take the transpose of A */
    float alpha = 1.0;
    float beta = 0.0;
    int first_row_A = 1;    /* Don't use submatrices or subvectors */
    int first_col_A = 1;    /* Multiply all of x by A              */
    int first_row_x = 1;
    int first_col_x = 1;
    int first_row_y = 1;
    int first_col_y = 1;
    int x_increment = 1;    /* x and y are column vectors. So next */
    int y_increment = 1;    /* value is obtained by adding one to  */
                            /* current subscript. Remember fortran */
                            /* arrays are column major!            */

    /* Compute y = alpha*Op(A)*x + beta*y.  Op can be "do nothing" */
    /* or transpose. */
    extern void PSGEMV(char* trans, int* m, int* n, float* alpha, 
           float* A_local, int* ia, int* ja, int* A_descrip, 
           float *x_local, int* ix, int* jx, int* x_descrip, int* incx,
           float* beta,
	   float* y_local, int* iy, int* jy, int* y_descrip, int* incy);

    PSGEMV(&transpose, &m, &n, &alpha, 
        A_local, &first_row_A, &first_col_A, A_descrip,
        x_local, &first_row_x, &first_col_x, x_descrip, &x_increment, 
        &beta, 
        y_local, &first_row_y, &first_col_y, y_descrip, &y_increment);
}  /* Mat_vect_mult */


/*===================================================================
 *
 * Simplified wrapper for the ScaLAPACK routine psgesv.
 * Solve the system Ax = b.  Return solution in b.
 */
void Solve(int my_rank, int order, 
           float* A_local, int* A_descrip, int* pivot_list,
           float* b_local, int* b_descrip) {
    int rhs_count = 1;  
    int first_row_A = 1;  /* Use all of A and b */
    int first_col_A = 1;
    int first_row_b = 1;
    int first_col_b = 1;
    int error_info;
    
    /* Solve the system Ax = b.  Return solution in b */
    extern void PSGESV(int* order, int* rhs_count, 
           float* A_local, int* first_row_A, int* first_col_A, 
               int* A_descrip, 
           int* pivot_list, 
           float* b_local, int* first_row_b, int* first_col_b, 
               int* b_descrip,
           int* error_info);
    #ifdef DEBUG 
    {
        int i, j;
        printf("Process %d > In Solve:  order = %d\n",  
               my_rank, order);
        printf("Process %d > A_descrip:",my_rank);
        for ( i = 0; i < DESCRIPTOR_SIZE; i++) 
            printf(" %d",A_descrip[i]);
        printf("\n");
        printf("Process %d > b_descrip:",my_rank);
        for ( i = 0; i < DESCRIPTOR_SIZE; i++) 
            printf(" %d",b_descrip[i]);
        printf("\n");
        printf("Process %d > b_local:",my_rank);
        for (i = 0; i < b_descrip[DESCRIPTOR_SIZE - 1]; i++) 
            printf(" %f",b_local[i]);
        printf("\n");
        fflush(stdout);
    }
    #endif
    PSGESV(&order, &rhs_count, A_local, &first_row_A, 
           &first_col_A, A_descrip, pivot_list, b_local, &first_row_b, 
           &first_col_b, b_descrip, &error_info);

    if (error_info != 0) {
        fprintf(stderr,"Process %d > Psgesv failed!\n",my_rank);
        fprintf(stderr,"Process %d > Error_info = %d\n", 
                my_rank, error_info);
        fprintf(stderr,"Process %d > Quitting\n",my_rank);
        MPI_Abort(MPI_COMM_WORLD, -1);
    }
}  /* Solve */


/*===================================================================
 *
 * Use PBLAS routines psaxpy and psnrm2 to compute ||y - x||_2 
 */
float Norm_diff(int n, float* x_local, int* x_descrip, 
                float* y_local, int* y_descrip) {
    float alpha = -1.0;
    int first_row_x = 1;  /* Use all of x and y */
    int first_col_x = 1;
    int first_row_y = 1;
    int first_col_y = 1;
    int x_increment = 1;  /* x and y are column vectors */
    int y_increment = 1;
    float return_val;
    
    /* Compute y = alpha*x + y */
    extern void PSAXPY(int* n, float* alpha, 
           float* x_local, int* ix, int* jx, int* x_descrip, int* incx,
           float* y_local, int* iy, int* jy, int* y_descrip, int* incy);

    /* Compute norm2 = ||x||_2 */
    extern void PSNRM2(int* n, float* norm2, 
           float* x_local, int* ix, int* jx, int* x_descrip, int* incx);

    /* Compute y <- -x+y */
    PSAXPY(&n, &alpha, 
            x_local, &first_row_x, &first_col_x, 
              x_descrip, &x_increment, 
            y_local, &first_row_y, &first_col_y, 
              y_descrip, &y_increment);

    /* Now compute ||y||_2 */
    PSNRM2(&n, &return_val,
            y_local, &first_row_y, &first_col_y, 
              y_descrip, &y_increment);

    return return_val;
} /* Norm_diff */
