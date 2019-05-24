/*      parallel fft compile and run commands
    module load PrgEnv/libs/fftw/mkl
    mpicc  ex2.c -o mpi_ex2 -L/opt/intel/mkl/lib/intel64/ \
    -lfftw3x_cdft_lp64 -lmkl_cdft_core -lfftw3xc_intel  \
    -lmkl_blacs_openmpi_lp64 -mkl

    export LD_LIBRARY_PATH=/opt/intel/mkl/lib/intel64/:$LD_LIBRARY_PATH

    srun -n 16 -p debug ./mpi_ex2
*/
#include <fftw3-mpi.h>
#include <stdio.h>
int main(int argc, char **argv){
	const ptrdiff_t N0 = 64, N1 = 64;
	int myid;
        char myname[16];
	FILE *file;
	fftw_plan plan;
	fftw_complex *data; //local data of course
	ptrdiff_t alloc_local, local_n0, local_0_start, i, j;
	MPI_Init(&argc, &argv);
	MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	fftw_mpi_init();
/* get local data size and allocate */
	alloc_local = fftw_mpi_local_size_2d(N0, N1, MPI_COMM_WORLD,&local_n0, &local_0_start);
	data = (fftw_complex *) fftw_malloc(sizeof(fftw_complex) * alloc_local);
	printf("%i\n", (int)local_n0);
/* create plan for forward DFT */
	plan = fftw_mpi_plan_dft_2d(N0, N1, data, data, MPI_COMM_WORLD,
	FFTW_FORWARD, FFTW_ESTIMATE);
/* initialize data to some function my_function(x,y) */
	for (i = 0; i < local_n0; ++i) for (j = 0; j < N1; ++j){
		data[i*N1 + j][0]=local_0_start;
		data[i*N1 + j][1]=i;
	}
/* compute transforms, in-place, as many times as desired */
	fftw_execute(plan);
/* each task prints its data */
	if ( myid  > -1 ){
        	sprintf(myname,"fftout.%4.4d",myid);
        	file=fopen(myname,"w");
		for (i = 0; i < local_n0; ++i) for (j = 0; j < N1; ++j){
			fprintf(file,"%d %d %g,%g\n",(int)i,(int)j,data[i*N1 + j][0],data[i*N1 + j][1]);
		}
		fclose(file);
	}
	fftw_destroy_plan(plan);
	fftw_free(data);
	MPI_Finalize();
	printf("finalize %d\n",myid);
	return 0;
}

