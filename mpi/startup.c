#include <mpi.h>
#include <stdlib.h>
#include <stdio.h>



double utc();
double utc() {
#include <time.h>
    struct timespec ts;
    timespec_get(&ts, TIME_UTC);
    return (double)ts.tv_sec+((double)ts.tv_nsec)*1e-9;
}

int main(int argc, char **argv, char *envp[])
{
	double t0,t1,dt;
	char version[MPI_MAX_LIBRARY_VERSION_STRING];
	char lname[MPI_MAX_PROCESSOR_NAME];
	int vlan;
	int numprocs,myid;

	struct { 
		double val; 
		int   rank; 
	} in, outmax,outmin;

	// We don't us MPI_Wtime because it might not work before MPI_Init
	t0=utc();
	MPI_Init(&argc, &argv);
	t1=utc();
	MPI_Comm_rank(MPI_COMM_WORLD, &myid);
	in.val=t1-t0;
	in.rank=myid;
	MPI_Get_processor_name(lname, &vlan);
	// printf("%d %g %s\n",in.rank,in.val,lname);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Get_library_version(version, &vlan);
	MPI_Reduce( &in, &outmax, 1, MPI_DOUBLE_INT, MPI_MAXLOC, 0, MPI_COMM_WORLD); 
	MPI_Reduce( &in, &outmin, 1, MPI_DOUBLE_INT, MPI_MINLOC, 0, MPI_COMM_WORLD);
	if (myid == 0 ){
		printf("%s\n",version);
		printf("# tasks %d\n",numprocs);
		printf("Max start time and rank  %g %d\n",outmax.val,outmax.rank);
		printf("Min start time and rank  %g %d\n",outmin.val,outmin.rank);
	}
	MPI_Finalize();
}


