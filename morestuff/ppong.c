#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>
#include <mpi.h>
#include <math.h>
#define BUFSIZE 16777216
#define BSIZE 24
/*#define BSIZE 4*/
#define RCOUNT 10
 
/************************************************************
This is a simple send/receive program in MPI
************************************************************/

#define NINT(a) ((a) >= 0.0 ? (int)((a)+0.5) : (int)((a)-0.5))
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
  int i;
  int tag;
  char *buffer;
  char *astr;
  char myname[MPI_MAX_PROCESSOR_NAME];
  MPI_Status status;
  double total[BSIZE],maxtime[BSIZE],mintime[BSIZE],st,et,dt;
  int is,ir,mysize,isize,resultlen,repeat;
  MPI_Init(&argc,&argv);
  MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD,&myid);
  MPI_Get_processor_name(myname,&resultlen); 
  printf("%d %s %e \n",myid,myname,MPI_Wtick());
/*  system("sleep 30"); */
  buffer=(char*)malloc((size_t)BUFSIZE);
  for(is=0;is<BUFSIZE;is++){
    buffer[is]=(char)0;
  }
if(myid == -1){  /* command line arguments is broken so we turn it off */
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
          // isize=NINT(exp(2.3025850929940459*(double)mysize));
          isize=NINT(exp(0.6931471805599453*(double)mysize));
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
	printf("  tasks       size     min time     ave time     max time  round trip b/s\n");
        for (mysize=0;mysize <=BSIZE; mysize++){
          // isize=NINT(exp(2.3025850929940459*(double)mysize));
          isize=NINT(exp(0.6931471805599453*(double)mysize));
          if(isize > BUFSIZE)isize=BUFSIZE;
          printf("%3d %3d %10d %e %e %e %15.0f\n",is,ir,isize,
                  mintime[mysize],total[mysize]/RCOUNT,
                  maxtime[mysize],(double)isize/mintime[mysize]);
          fflush(0);
        }
      }
    }
  }
  MPI_Finalize();
}

