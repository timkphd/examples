#include <stdio.h>
#include <omp.h>
int sched_getcpu();
int main(int argc,char *argv[]) {
int core,nt,j;
#pragma omp parallel
  {
#pragma omp critical
    {
      j=omp_get_thread_num();
      nt = omp_get_num_threads();
      core=sched_getcpu();
      printf("%4d %4d %4d\n",j,nt,core);
    }
  }
}

