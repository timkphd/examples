#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mpi.h"
#define MAX_DATA 256
int main( int argc, char **argv )
{
    MPI_Comm server;
    double buf[MAX_DATA];
    char port_name[MPI_MAX_PORT_NAME];
    int done,n,tag;
    MPI_Init( &argc, &argv );
    strcpy(port_name, argv[1] );
    /* assume server's name is cmd-line arg */
    MPI_Comm_connect( port_name, MPI_INFO_NULL, 0, MPI_COMM_WORLD,&server );
    printf("did connect\n");
    done=1;
    n=1;
    buf[0]=1234;
    tag = 2; 
    printf("/* Action to perform */\n");
    MPI_Send( buf, n, MPI_DOUBLE, 0, tag, server );
    done=0;
    printf("/* etc */\n");
    buf[0]=-1234;
    MPI_Send( buf, 1, MPI_DOUBLE, 0, 1, server );
    MPI_Comm_disconnect( &server );
    MPI_Finalize();
    return 0;
}
