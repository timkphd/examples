#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <omp.h> 
#include <mpix.h>

 
/************************************************************
 * This is a simple hello world program in OpenMP and MPI
 * with some BGQ specific additions to return additional
 * node information by calling MPIX_Rank2torus
 * ************************************************************/
int main(int argc,char **argv)
{
    int myid, numprocs;
    FILE *f1;
    int i,resultlen;
    int tn;
    MPIX_Hardware_t hw;
    int tid[6];
    char myname[MPI_MAX_PROCESSOR_NAME];
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
#pragma omp parallel
#pragma omp critical 
{
	tn=omp_get_thread_num();
    printf("hybrid mpi/openmp says Hello from %6d:%2.2d on %s\n",myid,tn,myname);

MPIX_Rank2torus(myid,tid);
printf("%6d:%2.2d;%3d%3d%3d%3d%3d%3d  %s\n",myid,tn,tid[0],tid[1],tid[2],tid[3],tid[4],tid[5]," coords");
MPIX_Hardware(&hw);
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.prank," Physical rank of the node (irrespective of mapping)");
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.psize," Size of the partition (irrespective of mapping) ");
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.ppn," Processes per node ");
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.coreID," Process id; values monotonically increase from 0..63 ");
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.clockMHz," Frequency in MegaHertz ");
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.memSize," Size of the core memory in MB ");
printf("%6d:%2.2d;%15u  %s\n",myid,tn,hw.torus_dimension," Actual dimension for the torus");
printf("%6d:%2.2d;%3u%3u%3u%3u%3u  %s\n",myid,tn,hw.Size[0],hw.Size[1],hw.Size[2],hw.Size[3],hw.Size[4]," Max coordinates on the torus");
printf("%6d:%2.2d;%3u%3u%3u%3u%3u  %s\n",myid,tn,hw.Coords[0],hw.Coords[1],hw.Coords[2],hw.Coords[3],hw.Coords[4]," This node's coordinates");
printf("%6d:%2.2d;%3u%3u%3u%3u%3u  %s\n",myid,tn,hw.isTorus[0],hw.isTorus[1],hw.isTorus[2],hw.isTorus[3],hw.isTorus[4]," Do we have wraparound links");

}
    MPI_Finalize();
    
}



