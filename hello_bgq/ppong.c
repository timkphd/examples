#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <mpi.h>
#include <math.h>
#define BUFSIZE 1073741824
// #define BSIZE 15
#define RCOUNT 200
#define TMAX 0.5
#define repcount 10
 
/************************************************************
This is a simple send/receive program in MPI
************************************************************/

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
  char *myname;
  MPI_Status status;
  double total[20],maxtime[20],mintime[20],st,et,dt;
  int count[20];
  int is,ir,mysize,isize,resultlen,repeat;
  double logs;
  int step;
  int BSIZE;
  step=4;
  FILE *file;
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
    
  printf("%d %d\n",myid,BSIZE);

  myname=(char*)malloc(MPI_MAX_PROCESSOR_NAME);
  MPI_Get_processor_name(myname,&resultlen); 
  st=TIMER();
  et=TIMER();
  printf("%d %s %e %e\n",myid,myname,MPI_Wtick(),et-st);
  if(myid > -1){
#ifdef MPI_MAX_LIBRARY_VERSION_STRING
    MPI_Get_library_version(version,&vlan);
#else
    sprintf(version,"%s","UNDEFINED - consider upgrading");
#endif
   printf("MPI VERSION %s\n",version);
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
  for (is=0; is < numprocs-1 ; is++) {
    for (ir=is+1 ; ir < numprocs ; ir ++ ) {
      MPI_Barrier(MPI_COMM_WORLD);
      if (myid == is || myid == ir) {
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
      }
    }
  }
  MPI_Finalize();
}

