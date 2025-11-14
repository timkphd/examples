// mpicc  -O3 -mcmodel=large htest.c
#define _GNU_SOURCE
#include <assert.h> 
#include <ctype.h>
#include <inttypes.h>
#include <math.h>
#include <mpi.h>
#include <omp.h>
#include <sched.h> 
#include <stdbool.h>
#include <stdio.h>
#include <stdio.h> 
#include <stdlib.h>
#include <stdlib.h> 
#include <string.h>
#include <strings.h>
#include <sys/time.h>
#include <sys/types.h> 
#include <time.h>
#include <unistd.h> 
#include <utmpx.h>


#ifndef STREAM_ARRAY_SIZE
#define STREAM_ARRAY_SIZE 1000000000
#endif
#ifndef NT
#define NT 20
#endif

void triad(int NTIMES, int val);
int ic;

int FINDCORE() { 
  int mc;
  mc=0;
  mc=(int)sched_getcpu(); 
  return (mc);
} 


void FORCECORE (int *core) {
        int bonk;
        cpu_set_t set;
        bonk=*core;
        bonk=abs(bonk) ;
        CPU_ZERO(&set);        // clear cpu mask
        CPU_SET(bonk, &set);      // set cpu 0
        if (*core < 0 ){
                sched_setaffinity(0, sizeof(cpu_set_t), &set);
        }else{
                sched_setaffinity(getpid(), sizeof(cpu_set_t), &set);
        }
}
double mysecond()
{
        struct timeval tp;
        struct timezone tzp;
        int i;

        i = gettimeofday(&tp,&tzp);
        return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}


int main(int argc, char **argv, char *envp[])
{
  int myid, numprocs, resultlen;
  int mycolor, new_id, new_nodes;
  int core0,core1,c0,c1;
  MPI_Comm node_comm;
  int vlan,got;
  FILE *f18;
  char lname[MPI_MAX_PROCESSOR_NAME];
  char version[MPI_MAX_LIBRARY_VERSION_STRING];
  pid_t pid; // pid_t is a type defined for process IDs


  MPI_Init(&argc, &argv);
  MPI_Get_library_version(version, &vlan);
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
  MPI_Get_processor_name(lname, &resultlen);
  pid = getpid();
long num_cores = sysconf(_SC_NPROCESSORS_ONLN);
  fprintf(stderr,"task %d is pid %d, GB/task %8.3f on %s with %ld cores\n",myid,pid,3*8*(double)(STREAM_ARRAY_SIZE)*1e-9,lname,num_cores);
  if (numprocs >2 ){
	if (myid == 0)printf("should be run on 2 tasks\n");
	MPI_Finalize();
	exit(1);
  }
  
  if (myid == 0){
  	f18=fopen("mappings","r");
  	
  }
  if (myid == 0 )fprintf(stderr,"TASK   Function    Best Rate MB/s  Avg time     Min time     Max time  Called\n");
  ic=0;
  core0=-1;
  core1=-1;

  while (true) {
  	if (myid == 0){
  	 if (numprocs == 1)
		got=fscanf(f18,"%d",&c0);
	 else
  	 	got=fscanf(f18,"%d %d",&c0,&c1);
  	 if (got < numprocs) {
  	    core0=-1;
  	    core1=-1;
  	    }
  	  else {
  	    core0=c0;
  	    core1=c1;
  	    fprintf(stderr,"%d %d\n",core0,core1);
  	    }
  	  }
  	  MPI_Bcast(&core0,1,MPI_INT,0,MPI_COMM_WORLD);
  	  MPI_Bcast(&core1,1,MPI_INT,0,MPI_COMM_WORLD);
  	  if (core0 < 0) break;
  	  if (myid == 0) {
  	  	FORCECORE(&core0);
  	  }
  	  else {
  	  	FORCECORE(&core1);
  	  }
	MPI_Barrier(MPI_COMM_WORLD);
	triad(NT, -1); 	    
	MPI_Barrier(MPI_COMM_WORLD);
  }
  MPI_Finalize();
  exit(0);
}


void triad(int NTIMES, int val) {
#include <float.h>

static double	avgtime, maxtime,mintime;
size_t bytes;
int myid;
size_t j,k;
# ifndef MIN
# define MIN(x,y) ((x)<(y)?(x):(y))
# endif
# ifndef MAX
# define MAX(x,y) ((x)>(y)?(x):(y))
# endif


#ifndef OFFSET
#   define OFFSET	0
#endif
#ifndef STREAM_TYPE
#define STREAM_TYPE double
#endif
STREAM_TYPE atot;
STREAM_TYPE scalar;
if (val >= 0)
    scalar=(STREAM_TYPE)val;
else
    scalar=3.0;

double		t,*times;
times=(double*)malloc(NTIMES*sizeof(double));

static STREAM_TYPE	a[STREAM_ARRAY_SIZE+OFFSET],
			b[STREAM_ARRAY_SIZE+OFFSET],
			c[STREAM_ARRAY_SIZE+OFFSET];

avgtime= 0; 
maxtime = 0;
mintime= FLT_MAX;
#pragma omp parallel for
    for (j=0; j<STREAM_ARRAY_SIZE; j++) {
	    a[j] = 1.0;
	    b[j] = 2.0;
	    c[j] = 0.0;
	}

    for (k=0; k<NTIMES; k++)
	{
	times[k] = mysecond();
#pragma omp parallel for
	for (j=0; j<STREAM_ARRAY_SIZE; j++)
	    a[j] = b[j]+scalar*c[j];
	times[k] = mysecond() - times[k];
	}
    atot=0;
    for (j=0; j<STREAM_ARRAY_SIZE; j++) atot=atot+a[j];
    if (atot < 0)printf("%g\n",(double)atot);

    for (k=1; k<NTIMES; k++) /* note -- skip first iteration */
	{
	    avgtime= avgtime + times[k];
	    mintime= MIN(mintime, times[k]);
	    maxtime= MAX(maxtime, times[k]);
	}
        avgtime=avgtime;
	mintime=mintime;
	maxtime=maxtime;
	avgtime = avgtime/(double)(NTIMES-1);
	MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	bytes=3 * sizeof(STREAM_TYPE) * STREAM_ARRAY_SIZE;
	ic++;
	
	if (val == -1){
	fprintf(stderr,"%6d %s  %12.1f      %11.6f  %11.6f  %11.6f  %6d %6d\n", myid,"triad",
	       1.0E-06 * bytes/mintime,
	       avgtime,
	       mintime,
	       maxtime,
	       ic,FINDCORE());
	}
	free(times);

}
