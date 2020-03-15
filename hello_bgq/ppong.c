#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <mpi.h>
#include <math.h>

/************************************************************
This is a simple send/receive program in MPI. It loops over
all processor pairs.

Note: You should replace MPI_Wtime with Papi timers if
available.
************************************************************/

// Max buffer size, actual size determined by BSIZE,
// optionally read in from the file "BSIZE".  The
// max size will be 4**BSIZE.  BSIZE defaluts to 15.
// 4**15=1,073,741,824
#define BUFSIZE 1073741824

// Max times to do the send/rec loop for a processor pair
#define RCOUNT 200

// Number of send/rec per loop
#define repcount 10

// Min time to spend in the send/rec loop
#define TMAX 0.5

// Compile line:
//      mpicc -DDOSAVE ppong.c -o ppong
// If DOSAVE is defined then every loop
// time will be recorded to binary files.

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
// #define TIMER MYCLOCK
#define TIMER MPI_Wtime

int main(int argc,char *argv[],char *env[])
{
  int myid, numprocs;
  int i,vlan;
  int tag;
  char *buffer;
  char *astr;
  char *myname,*yours;
  MPI_Status status;
  double total[20],maxtime[20],mintime[20],st,et,dt;
  double t1,t2;
  double **times;
  char fname[256];
  int count[20];
  int is,ir,mysize,isize,resultlen,repeat;
  double logs;
  int step;
  int BSIZE;
  step=4;
  FILE *file,*F;
  char filename[32];
  FILE *output;
  logs=log((double)step);

#ifdef MPI_MAX_LIBRARY_VERSION_STRING
    char version[MPI_MAX_LIBRARY_VERSION_STRING] ;
#else
    char version[256];
#endif
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  BSIZE=15;
  if (file=fopen("BSIZE","r")){
      fscanf(file,"%d",&BSIZE);
      fclose(file);
 }
    
  // printf("%d %d\n",myid,BSIZE);

  myname=(char*)malloc(MPI_MAX_PROCESSOR_NAME);
  MPI_Get_processor_name(myname,&resultlen); 
  st=TIMER();
  et=TIMER();
  /*****
  sprintf(fname,"%s_%4.4d",argv[0],myid);
  F=fopen(fname,"w");
  fprintf(F,"%d %s %e %e\n",myid,myname,MPI_Wtick(),et-st);
  fclose(F);
  *****/
  
  if(myid == 0){
#ifdef MPI_MAX_LIBRARY_VERSION_STRING
    MPI_Get_library_version(version,&vlan);
#else
    sprintf(version,"%s","UNDEFINED - consider upgrading");
#endif
   printf("MPI VERSION %s\n",version);
}
  if(myid == 0){
    yours=(char*)malloc(MPI_MAX_PROCESSOR_NAME);
    printf("%d %s %e %e\n",myid,myname,MPI_Wtick(),et-st);
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
  buffer=(char*)malloc((size_t)BUFSIZE);
  for(is=0;is<BUFSIZE;is++){
    buffer[is]=(char)0;
  }
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
  for (is=0; is < numprocs-1 ; is++) {
    for (ir=is+1 ; ir < numprocs ; ir ++ ) {
      MPI_Barrier(MPI_COMM_WORLD);
      if (myid == is || myid == ir) {
#ifdef DOSAVE
        if(myid == is){
          for (mysize=0;mysize <=BSIZE; mysize++)
            for (repeat=1;repeat<=RCOUNT;repeat++)
              times[mysize][repeat]=-1.0;              
        }
#endif
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
            	if (total[mysize] > TMAX) buffer[0]='b';
				count[mysize]=count[mysize]+1;
                st=TIMER();
                for(int irep=0; irep<repcount;irep++ ){
                  MPI_Send(buffer,isize,MPI_CHAR,ir,tag,MPI_COMM_WORLD);
                  MPI_Recv(buffer,isize,MPI_CHAR,ir,tag,MPI_COMM_WORLD,&status);
                }
                et=TIMER();
                dt=et-st;
                dt=dt/repcount;
#ifdef DOSAVE
                times[mysize][repeat]=dt;
#endif
                total[mysize]=total[mysize]+dt;
                if(dt > maxtime[mysize])maxtime[mysize]=dt;
                if(dt < mintime[mysize])mintime[mysize]=dt;
              }
            if(myid == ir){
                for(int irep=0; irep<repcount;irep++ ){
                  MPI_Recv(buffer,isize,MPI_CHAR,is,tag,MPI_COMM_WORLD,&status);
                  MPI_Send(buffer,isize,MPI_CHAR,is,tag,MPI_COMM_WORLD);
                }
            }
            if (buffer[0] == 'b') break;
          }
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
  MPI_Finalize();
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
