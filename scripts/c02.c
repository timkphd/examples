/************************************************************
Hello world but here we add a subroutine that can take 
command line arguments and optionally sleep for some number
of seconds and create a file.
************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <time.h>
void dostuff(int myid,int argc,char *argv[]);
struct tm *ptr;
time_t tm;

int main(int argc,char *argv[])
{
    int myid, numprocs;
    FILE *f1;
    int i,resultlen;
    char myname[MPI_MAX_PROCESSOR_NAME];
    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    MPI_Get_processor_name(myname,&resultlen);
    tm = time(NULL);
	ptr = localtime(&tm);
    printf("C %4d of %4d says Hello from %s %s\n",
          myid, numprocs ,myname,asctime(ptr));
    dostuff(myid,argc,argv);
    MPI_Finalize();
}

#include <unistd.h>
#include <string.h>
void dostuff(int myid,int argc,char *argv[]) {
    int isleep;
    char aname[20];
    FILE *f;
    if(myid == 0) {
        if(argc > 1) {
            sscanf(argv[1],"%d",&isleep);
            sleep((unsigned int) isleep);
        }
        if(argc > 2) {
            strncpy(aname,argv[2],(size_t)19);
            f=fopen(aname,"w");
            tm = time(NULL);
            ptr = localtime(&tm);
            fprintf(f,"hello %s \n",asctime(ptr));
            fclose(f);
        }
    }
    MPI_Barrier(MPI_COMM_WORLD);
}
