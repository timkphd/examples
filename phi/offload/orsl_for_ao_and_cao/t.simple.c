#include <stdlib.h>
#include <stdio.h>

#include "omp.h"

#pragma offload_attribute(push, target(mic))
#include "mkl.h"
#pragma offload_attribute(pop)

int manual_sync;
omp_lock_t offload_lock;

__declspec(target(mic))
void local_dgemm(int N, int LD, double *A, double *B, double *C)
{
	cblas_dgemm(CblasColMajor, CblasNoTrans, CblasNoTrans,
			N, N, N, 1.0, A, LD, B, LD, 1.0, C, LD);
}

double offload_dgemm(int N, int LD, double *A, double *B, double *C)
{
	double t;
	static int first_run = 1;

	t = dsecnd();

	/* Allocate memory on the card only on the first offload to improve
	 * performance. The memory is released only when the process exits. This is
	 * only suitable for benchmarking. */
#pragma offload target(mic:0) in(N, LD) \
		in(A: length(N*LD) alloc_if(first_run) free_if(0)) \
		in(B: length(N*LD) alloc_if(first_run) free_if(0)) \
		inout(C: length(N*LD) alloc_if(first_run) free_if(0))
		{
			local_dgemm(N, LD, A, B, C);
		}
	t = dsecnd() - t;

	first_run = 0;
	return t;
}

double host_ao_dgemm(int N, int LD, double *A, double *B, double *C)
{
	double t = dsecnd();
	local_dgemm(N, LD, A, B, C);
	return dsecnd() - t;
}

void bench_dgemm(int use_offload, int N)
{
	/* Choose such leading dimension that there is no cache aliasing. */
	int LD = (N % 512) ? N : N + 128;

	/* Allocate memory using MKL function to make sure the addresses are
	 * properly aligned. */
	double *A = mkl_malloc(sizeof(double) * N * LD, 4096);
	double *B = mkl_malloc(sizeof(double) * N * LD, 4096);
	double *C = mkl_malloc(sizeof(double) * N * LD, 4096);

	/* Select DGEMM kind: offload or host/Automatic Offload. */
	double (*dgemm_func)(int, int, double *, double *, double *);
	dgemm_func = (use_offload) ? offload_dgemm : host_ao_dgemm;

#pragma omp barrier

	double t = 0.0;
	const int NITERS = 3;
	for (int i = 0; i < NITERS + 1; i++) {
		double t_tmp = dgemm_func(N, LD, A, B, C);
		/* Discard performance obtained on the warmup iteration. */
		if (i > 0) t += t_tmp;
	}

	mkl_free(A);
	mkl_free(B);
	mkl_free(C);

	const double NOPS = 2.0 * N * N * N;
	double gflops = NOPS / (t * 1E9 / NITERS);
	printf("%s %dx%d DGEMM: %8.2f GFlops\n",
			(use_offload) ? "Offload" : "Host/AO", N, N, gflops);
}

int main(int argc, char **argv)
{
	if (argc != 3) {
		printf("Usage: %s <concurrent coprocessor access=0|1> <N>\n", argv[0]);
		return -1;
	}

	int concurrent = atoi(argv[1]);
	int N = atoi(argv[2]);

	printf("Coprocessor access: %s\n", concurrent ? "concurrent" : "serial");
	printf("N: %d\n", N);

	if (concurrent) {
		/* The following settings will make MKL use OpenMP even when called
		 * from an OpenMP region. */
		mkl_set_dynamic(0);
		omp_set_nested(1);
		mkl_set_num_threads(omp_get_max_threads());
	}

#pragma omp parallel for num_threads(2) if (concurrent)
	for (int i = 0; i < 2; i++)
		bench_dgemm(i, N);

	return 0;
}

