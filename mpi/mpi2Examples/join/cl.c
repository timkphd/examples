#include "mpi.h"
#include <stdio.h>
#define MAX_DATA 256
int main( int argc, char **argv ) {

MPI_Comm client;
MPI_Status status;
char port_name[MPI_MAX_PORT_NAME];
double buf[MAX_DATA];
int    size, again,IERROR;
MPI_Init( &argc, &argv );
MPI_Comm_size(MPI_COMM_WORLD, &size);
if (size != 1){
  printf("Server too big");
  MPI_Abort(MPI_COMM_WORLD, 99);
}
MPI_Open_port(MPI_INFO_NULL, port_name);
printf("server available at %s\n",port_name);
//while (1) {
    MPI_Comm_accept( port_name, MPI_INFO_NULL, 0, MPI_COMM_WORLD,
                     &client );
    MPI_Comm_size(client, &size);
    printf("did accept size= %d\n",size);
    again = 1;
    while (again) {
        MPI_Recv( buf, MAX_DATA, MPI_DOUBLE,
                  MPI_ANY_SOURCE, MPI_ANY_TAG, client, &status );
        printf("%g\n",buf[0]);
        if (buf[0] < 0.0) again=0;
			}
//	}
    MPI_Comm_disconnect(&client);
    MPI_Finalize();
    return 0;

}

