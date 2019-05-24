#include <stdio.h>
#include "mpi.h"
#include <math.h>
 
void lam_darwin_malloc_linker_hack(){};
void timestmp(char *timestr);

int main(argc,argv)
int argc;
char *argv[];
{
    int myid, numprocs;
    FILE *f1;
    int i;
    int ierr;
    MPI_Comm  parent;
    char fname[10];
    char stamp[11];
 
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Comm_get_parent(&parent);
 
    sprintf(fname,"%s%2.2d",argv[1],myid);

    printf("Hello from c worker %d writing to %s\n",myid,fname);
    f1=fopen(fname,"w");
    timestmp(stamp);
    fprintf(f1,"%s\n",stamp);
    fclose(f1);
    sleep(10);
    MPI_Comm_free(&parent);
    MPI_Finalize();
    
}


#include <time.h>
#include <sys/time.h>
#include <string.h>
void timestmp(char *timestr) {
/*	char timestr[11]; */
	struct timeval tp;
	struct timezone tzp;
	struct tm *tmstruct;
	time_t tod;
	gettimeofday(&tp,&tzp);
	tod=tp.tv_sec;
	tmstruct=gmtime(&tod);
/*	tmstruct=localtime(&tod); */
	sprintf(timestr,"%2.2d%2.2d%2.2d%2.2d%2.2d",tmstruct->tm_mon+1,
	                                            tmstruct->tm_mday,
	                                            tmstruct->tm_hour,
	                                            tmstruct->tm_min,
	                                            tmstruct->tm_sec);
	timestr[10]=(char)0;
}

