#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <math.h>
 
/************************************************************
This is a simple hello world program. Each processor prints
name, rank, and total run size.
************************************************************/
double st[2];
// a timer can't use the MPI timer becasue it does not work before MPI_init
double utc() {
#include <time.h>
    struct timespec ts;
    timespec_get(&ts, TIME_UTC);
    return (double)ts.tv_sec+((double)ts.tv_nsec)*1e-9;
}

// gather the start times to task 0 and print
void treport() {
        double *allst;
        double s,e;
        int numprocs,i,myid;
        MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
        MPI_Comm_rank(MPI_COMM_WORLD, &myid);
        allst=(double*)(malloc(2*numprocs*sizeof(double)));
        MPI_Gather(st,2,MPI_DOUBLE, allst,2,MPI_DOUBLE,0,MPI_COMM_WORLD);
        if (myid == 0 ) {
                for (i=0; i<numprocs ; i++ ) {
                  s=allst[i*2];
                  e=allst[i*2+1];
                  printf("mpi_init %d %12.4f %12.4f %12.4f\n",i,s,e,e-s);
                  }
        }
}
// gather and print what each node / task thinks the time is 
// adduming that barrier will sync the tasks.
void drift() { 
	double now,nowmin,nowmax,dt;
        int numprocs,i,myid;
        MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
        MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	MPI_Barrier(MPI_COMM_WORLD);
	now=utc();
	MPI_Reduce(&now,&nowmin,1,MPI_DOUBLE,MPI_MIN,0,MPI_COMM_WORLD);
	MPI_Reduce(&now,&nowmax,1,MPI_DOUBLE,MPI_MAX,0,MPI_COMM_WORLD);
	if (myid == 0) {
  		printf(" min UTC            task 0 UTC         max UTC            Delta\n");
		printf("%18.6f %18.6f %18.6f %g\n",nowmin,now,nowmax,nowmax-nowmin);
	}
}



int main(int argc, char **argv)
{
    int myid,numprocs,resultlen;
    char version[MPI_MAX_LIBRARY_VERSION_STRING];
    char myname[MPI_MAX_PROCESSOR_NAME] ;
    int vlan;
    st[0]=utc();
    MPI_Init(&argc,&argv);
    st[1]=utc();
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen); 
    printf("Hello from %s %d %d\n",myname,myid,numprocs);
    if (myid == 0 ) {
	    MPI_Get_library_version(version, &vlan);
	    printf("%s\n",version);
    }
    drift();
    treport();
    MPI_Finalize();
}

