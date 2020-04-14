#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>
#include <time.h>
int cumain(int myid, int gx, int gy,int bx, int by, int bz);
void ptime(){
  time_t rawtime;
  struct tm * timeinfo;
  char buffer [80];
  time (&rawtime);
  timeinfo = localtime (&rawtime);
  strftime (buffer,80,"%c",timeinfo);
  //puts (buffer);
  printf("%s\n",buffer);
  }
  
#define GPUS 2
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
int main(int argc, char **argv)
{
    int myid,numprocs,resultlen;
	int gx,gy;
	int bx,by,bz;
        char myname[256];
        gethostname(myname,255);      
        myid=0;
        numprocs=1;
    printf("C-> Hello from %s # %d of %d\n",myname,myid,numprocs);
    if (myid == 0) {
		ptime();
		scanf("%d %d",&gx,&gy);
		scanf("%d %d %d",&bx,&by,&bz);
	}


    for (int ic=0; ic<30; ic++ ){
	cumain(myid % GPUS ,gx,gy,bx,by,bz);
    	sleep(1);
    }
    if(myid == 0) {
                ptime();
    }
}
