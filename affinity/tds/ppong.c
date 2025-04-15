#define _GNU_SOURCE
#include <sched.h>
#include <inttypes.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <assert.h>
#include <sys/time.h>
#include <string.h>
#include <math.h>
#include <mpi.h>
#include <ctype.h>

// test keys
//int sched_getcpu(void);
#ifdef USEFAST
extern inline __attribute__((always_inline)) int get_core_number() {
   unsigned long a, d, c;
   __asm__ volatile("rdtscp" : "=a" (a), "=d" (d), "=c" (c));
   return ( c & 0xFFFUL );
}
#else
int sched_getcpu();
#endif


int findcore()
{
  int cpu;

#ifdef __APPLE__
  cpu = -1;
#else
#ifdef USEFAST
  cpu = get_core_number();
#else
  cpu = sched_getcpu();
#endif
#endif
  return cpu;
}

/************************************************************
This is a simple send/receive program in MPI. It loops over
all processor pairs.

Note: You should replace MPI_Wtime with PAPI timers if
available.
************************************************************/

// Max buffer size, actual size determined by BSIZE,
// optionally read in from the file "BSIZE".  The
// max size will be 4**BSIZE.  BSIZE defaluts to 15.
// 4**15=1,073,741,824
#define BUFSIZE 1073741824

// Max times to do the send/rec loop for a processor pair
#ifndef RCOUNT
#define RCOUNT 200
#endif

// Number of send/rec per loop
#ifndef REPCOUNT
#define REPCOUNT 10
#endif

// Max time to spend in the send/rec loop
#ifndef TMAX
#define TMAX 0.5
#endif

// Compile line:
//      mpicc -DDOSAVE ppong.c -o ppong
// If DOSAVE is defined then every loop
// time will be recorded to binary files.
// Note RCOUNT, REPCOUNT, and TMAX can also
// be defined on the compile line.

// Reports: 
// MPI version
// Nodes used for run , MPI_Wtick and timer call delta t 
// to/from processor
// message size 
// mintime for loop
// avetime for loop
// maxtime for loop
// bandwidth
// # of loops
// NOTE: times are round trip not one way; so bandwidth
// might be half of what is expected.
 
#ifdef DOSAVE
#define FLT double
#define INT int
FLT **matrix(INT nrl,INT nrh,INT ncl,INT nch);
void free_matrix(FLT **m, INT nrl, INT nrh, 
                          INT ncl, INT nch);
#endif
double MYCLOCK()
{
        struct timeval timestr;
        void *Tzp=0;
        gettimeofday(&timestr, Tzp);
        return ((double)timestr.tv_sec + 1.0E-06*(double)timestr.tv_usec);
}
// #define MYCLOCK MPI_Wtime
#ifdef PAPI
long PAPI_get_real_cyc(void);
#define TIMER ((double)PAPI_get_real_cyc()*(double)1.0E-06)
#endif

// #define TIMER MYCLOCK
#ifndef TIMER
#define TIMER MPI_Wtime()
#endif

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


int main(int argc,char *argv[],char *env[])
{
  int core;
  int myid, numprocs;
  int i,vlan;
  int tag;
  char *buffer,*get;
  int iv;
  char *astr;
  char *myname,*yours;
  MPI_Status status;
  double total[20],maxtime[20],mintime[20],st,et,dt;
  float ibar;
  int *cores;
  int *todo;
  int mapit,packed,iarg;
  double t1,t2;
#ifdef DOSAVE
  double **times;
  FILE *output;
  char filename[32];
  char fname[256];
  FILE *F;
#endif
  int count[20];
  int is,ir,mysize,isize,resultlen,repeat;
  int rc_calls;
  double logs;
  int step;
  int BSIZE;
  step=4;
  FILE *file;
  logs=log((double)step);

    char version[MPI_MAX_LIBRARY_VERSION_STRING] ;
    buffer=NULL;
    get=NULL;
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  BSIZE=15;
  if ((file=fopen("BSIZE","r"))){
      fscanf(file,"%d",&BSIZE);
      fclose(file);
 }
    
  // printf("%d %d\n",myid,BSIZE);

  myname=(char*)malloc(MPI_MAX_PROCESSOR_NAME);
  MPI_Get_processor_name(myname,&resultlen); 
  st=TIMER;
  et=TIMER;
  /*****
  sprintf(fname,"%s_%4.4d",argv[0],myid);
  F=fopen(fname,"w");
  fprintf(F,"%d %s %e %e\n",myid,myname,MPI_Wtick(),et-st);
  fclose(F);
  *****/
  
  if(myid == 0){
	MPI_Get_library_version(version,&vlan);
	printf("MPI VERSION %s\n",version);
	mapit=-1;
	packed=-1;
	if ( argc > 1) {
		for (iarg=1;iarg< argc;iarg++) {
			printf("%s\n",argv[iarg]);
			if( isdigit(argv[iarg][0]) == 0) mapit=atoi(argv[iarg]);
			if( strncmp(argv[iarg] ,"SR",2) == 0 ) packed=1;
		}
	}
	if(packed == 1) {
		printf("calling MPI_Sendrecv\n");
	}
	else {
		printf("calling MPI_Send - MPI_Recv\n");
	}

}
    todo=(int*)malloc(4*numprocs);
  if(myid == 0){
    FILE * file;
    file = fopen("todo", "r");
    if (file) {
	    printf("got file\n");
    for (is=0 ;is < numprocs;is++) { todo[is]=0; }
	    char *line = NULL;
	    int gettodo;
	    size_t len = 0;
	    while(getline(&line, &len, file) != -1) {
		sscanf(line,"%d",&gettodo);
		if (gettodo >= numprocs) gettodo=numprocs-1;
		todo[gettodo]=1;
		printf("%d\n",gettodo);
	}
    }else {
    for (is=0 ;is < numprocs;is++) todo[is]=1;
    }

    cores=(int*)malloc(4*numprocs);
    yours=(char*)malloc(MPI_MAX_PROCESSOR_NAME);
    t1=MPI_Wtick();
    t2=et-st;
    printf("%d %s %e %e\n",0,myname,t1,t2);
    for(ir=1;ir<numprocs;ir++) {
		MPI_Recv(yours,MPI_MAX_PROCESSOR_NAME,MPI_CHAR,ir,345,MPI_COMM_WORLD,&status);
		MPI_Recv(&t1,1,MPI_DOUBLE,ir,456,MPI_COMM_WORLD,&status);
		MPI_Recv(&t2,1,MPI_DOUBLE,ir,789,MPI_COMM_WORLD,&status);
		printf("%d %s %e %e\n",ir,yours,t1,t2);
    }
     printf(" S  R       Size     Min Time     Ave Time     Max Time       Bandwidth    #\n");
  } else {
        t1=MPI_Wtick();
        t2=et-st;
		MPI_Send(myname,MPI_MAX_PROCESSOR_NAME,MPI_CHAR,0,345,MPI_COMM_WORLD);
		MPI_Send(&t1,1,MPI_DOUBLE,0,456,MPI_COMM_WORLD);
		MPI_Send(&t2,1,MPI_DOUBLE,0,789,MPI_COMM_WORLD);
    }
    //printf("bcast %d",myid);
  MPI_Bcast(todo,numprocs,MPI_INT,0,MPI_COMM_WORLD);
  MPI_Bcast(&mapit,1,MPI_INT,0,MPI_COMM_WORLD);
  MPI_Bcast(&packed,1,MPI_INT,0,MPI_COMM_WORLD);

 // MPI_Abort(MPI_COMM_WORLD,0); exit(0);
//
//  buffer=(char*)malloc((size_t)BUFSIZE);
//  get=(char*)malloc((size_t)BUFSIZE);
//  for(is=0;is<BUFSIZE;is++){
//    buffer[is]=(char)0;
//  }
//
// edit next line to print your environment
if(myid == -1){
	i=0;
	astr=env[i];
	while(astr) {
		printf("%s\n",astr);
		i++;
		astr=env[i];
	}
}
  tag=1234;
#ifdef DOSAVE
  times=matrix(0,BSIZE,1,RCOUNT);
#endif

int mone;
if(mapit > 0){
	mone=myid % mapit;
        mone=mone*(-1);
        FORCECORE(&mone);
}
buffer=(char*)malloc((size_t)64);
get=(char*)malloc((size_t)64);
rc_calls=0;

  for (is=0; is < numprocs-1 ; is++) if (todo[is] ==1) {
    for (ir=is+1 ; ir < numprocs ; ir ++ ) if (todo[ir] ==1){
      MPI_Barrier(MPI_COMM_WORLD);
      if (myid == is || myid == ir ) {
#ifdef DOSAVE
        if(myid == is){
          for (mysize=0;mysize <=BSIZE; mysize++)
            for (repeat=1;repeat<=RCOUNT;repeat++)
              times[mysize][repeat]=-1.0;              
        }
#endif
  free((char*)buffer);
  // printf("%d %d %d\n",myid,is,ir);
  buffer=(char*)malloc((size_t)BUFSIZE);
  for(iv=0;iv<BUFSIZE;iv++){
    buffer[iv]=(char)0;
  }
  //printf("%d allocated buffer\n",myid);
if(packed == 1) {
  free(get);
  get=(char*)malloc((size_t)BUFSIZE);
  //printf("%d allocated get\n",myid);
}
                int irep;
        
        for (mysize=0;mysize <=BSIZE; mysize++){
          isize=round(exp(logs*(double)mysize));
          buffer[0]=(char)0;
          if(isize > BUFSIZE)isize=BUFSIZE;
          total[mysize]=0.0;
          mintime[mysize]=1e6;
          maxtime[mysize]=0.0;
          count[mysize]=0;
          for (repeat=1;repeat<=RCOUNT;repeat++) {
            if(myid == is){
            	if (total[mysize] > TMAX) { buffer[0]='b'; }
				count[mysize]=count[mysize]+1;
                st=TIMER;
                for(irep=0; irep<REPCOUNT;irep++ ){
if(packed == 1) {

                  MPI_Sendrecv(buffer,isize,MPI_CHAR,ir,tag,
                                  get,isize,MPI_CHAR,ir,tag,
                                  MPI_COMM_WORLD,&status);
                                  rc_calls=rc_calls-1;

}else{
                  MPI_Send(buffer,isize,MPI_CHAR,ir,tag,MPI_COMM_WORLD);
                  MPI_Recv(buffer,isize,MPI_CHAR,ir,tag,MPI_COMM_WORLD,&status);
                  rc_calls=rc_calls+1;
}
                }
                et=TIMER;
                dt=et-st;
                dt=dt/REPCOUNT;
#ifdef DOSAVE
                times[mysize][repeat]=dt;
#endif
                total[mysize]=total[mysize]+dt;
                if(dt > maxtime[mysize])maxtime[mysize]=dt;
                if(dt < mintime[mysize])mintime[mysize]=dt;
              }
            if(myid == ir){
                for(irep=0; irep<REPCOUNT;irep++ ){
if(packed == 1) {

                  MPI_Sendrecv(   get,isize,MPI_CHAR,is,tag,
                               buffer,isize,MPI_CHAR,is,tag,
                                  MPI_COMM_WORLD,&status);
                                  rc_calls=rc_calls-1;

}else{
                  MPI_Recv(buffer,isize,MPI_CHAR,is,tag,MPI_COMM_WORLD,&status);
                  MPI_Send(buffer,isize,MPI_CHAR,is,tag,MPI_COMM_WORLD);
                  rc_calls=rc_calls+1;
}
                }
            }
            if (buffer[0] == 'b') break;
          }
        }
      if (myid == is){
        for (mysize=0;mysize <=BSIZE; mysize++){
          isize=round(exp(logs*(double)mysize));
          if(isize > BUFSIZE)isize=BUFSIZE;
          printf("%2d %2d %10d %e %e %e %15.4e %4d\n",is,ir,isize,
                  mintime[mysize],total[mysize]/count[mysize],
                  maxtime[mysize],(double)isize*2.0/mintime[mysize],count[mysize]);
          fflush(0);
        }
#ifdef DOSAVE
        sprintf(filename,"%4.4d_%4.4d",is,ir);
        output=fopen(filename,"wb");
        fwrite(&times[0][1],8,(size_t)((BSIZE+1)*RCOUNT),output);
        fclose(output);
#endif        
      }
      }
    }
  }
  core=findcore();
  MPI_Gather(&core,1,MPI_INT,cores,1,MPI_INT,0,MPI_COMM_WORLD);
  if (myid == 0){
    for (is=0; is < numprocs ; is++) {
	printf("%4d core %4d\n",is,cores[is] % 64);
    }
}
  MPI_Gather(&rc_calls,1,MPI_INT,cores,1,MPI_INT,0,MPI_COMM_WORLD);
  if (myid == 0){
    for (is=0; is < numprocs ; is++) {
	if (cores[is] > 0 )printf("%4d calls to MPI_Send / MPI_Recv %10d\n",is,cores[is] );
	if (cores[is] < 0 )printf("%4d calls to MPI_Sendrecv %10d\n",is,-cores[is] );
    }
}
  MPI_Barrier(MPI_COMM_WORLD);
  st=TIMER;
  et=st+1.0;
  ibar=0;
#define BC 1000
//while (TIMER < et) {
  while (ibar < 100) {
	  for (repeat=1;repeat<=BC;repeat++) {
		  MPI_Barrier(MPI_COMM_WORLD);
	  }
	  ibar=ibar+BC;
  }
 dt=TIMER-st;
 if (myid == 0){
	 printf("Barriers/Second %g\n",(float)ibar/dt);
 }
  MPI_Finalize();
  fflush(stdout);
}

#ifdef DOSAVE
// Following based on:
// Numerical recipes in C : the art of scientific computing 
// William H. Press ... [et al.]. – 2nd ed.
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

void free_matrix(FLT **m, INT nrl, INT nrh, 
                          INT ncl, INT nch) 
/* free a float matrix allocated by matrix() */
{
  m[nrl] += ncl;
  free((char*) (m[nrl]));
  m += nrl; 
  free((char*) (m)); 
}
#endif
