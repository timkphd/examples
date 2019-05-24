#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <mpi.h>
#include <math.h>
#define BUFSIZE 10000000
#define BSIZE 7
/*#define BSIZE 4*/
#define RCOUNT 10
 
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
#define TIMER MYCLOCK
/* define TIMER MPI_Wtime */

int main(int argc,char *argv[],char *env[])
{
  int myid, numprocs;
  int i;
  int tag;
  char *buffer;
  char *astr;
//  char myname[MPI_MAX_PROCESSOR_NAME];
  char *myname;
  MPI_Status status;
  double total[20],maxtime[20],mintime[20],st,et,dt;
  int is,ir,mysize,isize,resultlen,repeat;
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  myname=(char*)malloc(MPI_MAX_PROCESSOR_NAME);
  MPI_Get_processor_name(myname,&resultlen); 
  myname=strrchr(myname,(char)32)+1;
  printf("%d %s %e \n",myid,myname,MPI_Wtick());
/*  system("sleep 30"); */
  buffer=(char*)malloc((size_t)BUFSIZE);
  for(is=0;is<BUFSIZE;is++){
    buffer[is]=(char)0;
  }
if(myid == 0){
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
          isize=(int)exp(2.3025850929940459*(double)mysize);
          if(isize > BUFSIZE)isize=BUFSIZE;
          total[mysize]=0.0;
          mintime[mysize]=1e6;
          maxtime[mysize]=0.0;
          for (repeat=1;repeat<=RCOUNT;repeat++) {
            if(myid == is){
                st=TIMER();
                MPI_Send(buffer,isize,MPI_CHAR,ir,tag,MPI_COMM_WORLD);
                MPI_Recv(buffer,isize,MPI_CHAR,ir,tag,MPI_COMM_WORLD,&status);
                et=TIMER();
                dt=et-st;
                total[mysize]=total[mysize]+dt;
                if(dt > maxtime[mysize])maxtime[mysize]=dt;
                if(dt < mintime[mysize])mintime[mysize]=dt;
              }
            if(myid == ir){
                MPI_Recv(buffer,isize,MPI_CHAR,is,tag,MPI_COMM_WORLD,&status);
                MPI_Send(buffer,isize,MPI_CHAR,is,tag,MPI_COMM_WORLD);
            }
          }
        }
      }
      if (myid == is){
        for (mysize=0;mysize <=BSIZE; mysize++){
          isize=(int)exp(2.3025850929940459*(double)mysize);
          if(isize > BUFSIZE)isize=BUFSIZE;
          printf("%2d %2d %10d %e %e %e  s %15.4e\n",is,ir,isize,
                  mintime[mysize],total[mysize]/RCOUNT,
                  maxtime[mysize],(double)isize*2.0/mintime[mysize]);
          fflush(0);
        }
      }
    }
  }
  MPI_Finalize();
}

