/* cc  -lm t4.c -qsmp */
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#define FLT double

/* utility routines */
void my_bar();
void explain(char astr[]);
FLT system_clock(FLT *x);
void start_time();
FLT end_time();

/* array used to determine how much work each thread performs */
int *dist,idid;
FLT st;

/* routine to reset dist */
void zero(int j);

/* work routines */
void all_fast();
void zero_slow();
void a_slow(int i);


void all_fast() {
  int k;
  k=omp_get_thread_num();
  dist[k]++;
}

void zero_slow() {
  int k;
  FLT x,y;
  k=omp_get_thread_num();
  dist[k]++;
  if(k == 0) {
  	x=system_clock((FLT*)0);
  	y=x+1;
  	while(x < y) {
  		x=system_clock((FLT*)0);
  	}
  }
}

void imbalance (int i) {
  int k;
  FLT x,y;
  k=omp_get_thread_num();
  dist[k]++;
  if(i == 1) {
    idid=k;
  	x=system_clock((FLT*)0);
  	y=x+1;
  	while(x < y) {
  		x=system_clock((FLT*)0);
  	}
  }
  else {
  	x=system_clock((FLT*)0);
  	y=x+0.01;
  	while(x < y) {
  		x=system_clock((FLT*)0);
  	}
  }
}

main() {
int  i,k,max_threads,total;
max_threads=omp_get_max_threads();
printf("max threads = %d\n",max_threads);
dist=(int*)malloc(max_threads*sizeof(int));
zero(max_threads);
total=0;
explain("report the % of iterations for each thread");
explain("for a set of loops");
explain("******");
explain("default scheduling");
explain("for a subroutine with little work");
k=max_threads*100;
start_time();
#pragma omp parallel for
    for( i=1;i<=k;i++) {
		all_fast();
    }
my_bar();
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);
explain("default scheduling");
explain("for a subroutine with thread 0 given 1 second of work");
k=max_threads*4;
start_time();
#pragma omp parallel for
    for( i=1;i<=k;i++) {
		zero_slow();
    }
my_bar();
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);
explain("schedule(static,1)");
explain("for a subroutine with thread 0 given 1 second of work");
start_time();
#pragma omp parallel for schedule(static,1)
    for( i=1;i<=k;i++) {
		zero_slow();
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);
explain("schedule(static,2)");
explain("for a subroutine with thread 0 given 1 second of work");
start_time();
#pragma omp parallel for schedule(static,2)
    for( i=1;i<=k;i++) {
		zero_slow();
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);
explain("schedule(dynamic,1)");
explain("for a subroutine with thread 0 given 1 second of work");
start_time();
#pragma omp parallel for schedule(dynamic,1)
    for( i=1;i<=k;i++) {
		zero_slow();
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);
explain("schedule(dynamic,2)");
explain("for a subroutine with thread 0 given 1 second of work");
start_time();
#pragma omp parallel for schedule(dynamic,2)
    for( i=1;i<=k;i++) {
		zero_slow();
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);
explain("schedule(dynamic,4)");
explain("for a subroutine with thread 0 given 1 second of work");
start_time();
#pragma omp parallel for schedule(dynamic,2)
    for( i=1;i<=k;i++) {
		zero_slow();
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n\n",total, end_time());
total=0;
zero(max_threads);

explain("default scheduling");
explain("for an imbalanced subroutine");
k=max_threads*100;
start_time();
#pragma omp parallel for
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
my_bar();
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
zero(max_threads);
explain("default scheduling");
explain("for an imbalanced subroutine");
start_time();
#pragma omp parallel for
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
my_bar();
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
zero(max_threads);
explain("schedule(static,1)");
explain("for an imbalanced subroutine");
start_time();
#pragma omp parallel for schedule(static,1)
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
zero(max_threads);
explain("schedule(static,2)");
explain("for an imbalanced subroutine");
start_time();
#pragma omp parallel for schedule(static,2)
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
zero(max_threads);
explain("schedule(dynamic,1)");
explain("for an imbalanced subroutine");
start_time();
#pragma omp parallel for schedule(dynamic,1)
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
zero(max_threads);
explain("schedule(dynamic,2)");
explain("for an imbalanced subroutine");
start_time();
#pragma omp parallel for schedule(dynamic,2)
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
zero(max_threads);
explain("schedule(dynamic,4)");
explain("for an imbalanced subroutine");
start_time();
#pragma omp parallel for schedule(dynamic,2)
    for( i=1;i<=k;i++) {
		imbalance(i);
    }
for( i=0;i<max_threads;i++) {
		printf("%d %6.2f %%\n",i,100.0*(FLT)dist[i]/((FLT)k));
		total=total+dist[i];
    }
printf(" total iterations: %d time %10.2f\n",total, end_time());
printf(" thread %d did the slow iteration\n\n",idid);
total=0;
my_bar();
}


void my_bar() {
#pragma omp barrier
	fflush(stdout);
#pragma omp barrier
}

void explain(char astr[]){
	printf("******  %s\n",astr);
}

FLT system_clock(FLT *x) {
	FLT t;
	FLT six=1.0e-6;
	struct timeval tb;
	struct timezone tz;
	gettimeofday(&tb,&tz);
	t=(FLT)tb.tv_sec+((FLT)tb.tv_usec)*six;
 	if(x){
 		*x=t;
 	}
 	return(t);
}

void zero(int j) {
int i;
    for( i=0;i<j;i++) {
		dist[i]=0;
    }
}

void start_time() {
	st=system_clock((FLT*)0);
}

FLT end_time() {
	return (system_clock((FLT*)0)-st);
}