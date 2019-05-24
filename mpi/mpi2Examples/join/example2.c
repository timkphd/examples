#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
//#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <unistd.h>
#include <mpi.h>

#include <math.h>
#include <sys/time.h>
#include <unistd.h>

#define COUNT 1024

int main( int argc, char *argv[] )
{
    int sendbuf[COUNT], recvbuf[COUNT], i;
    int err=0, rank, nprocs, errs=0;
    MPI_Comm intercomm;
    int listenfd, connfd, port, namelen;
    struct sockaddr_in cliaddr, servaddr;
    struct hostent *h;
    char hostname[MPI_MAX_PROCESSOR_NAME];
    socklen_t len, clilen;
    int split;

    MPI_Init( &argc, &argv );
    MPI_Comm_size(MPI_COMM_WORLD,&nprocs); 
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    split=0;
    if (nprocs != 2) {
        printf("Running this program with 1 processes\n");fflush(stdout);
        // MPI_Abort(MPI_COMM_WORLD,1);
        split=1;
        rank=atoi(argv[1]);
    }
    if (rank == 1) {
        /* server */
        listenfd = socket(AF_INET, SOCK_STREAM, 0);
        if (listenfd < 0) {
            printf("server cannot open socket\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD,1);
        }

        memset(&servaddr, 0, sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        servaddr.sin_port = 0;
        err = bind(listenfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
        if (err < 0) {
            errs++;
            printf("bind failed\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD,1);
        }
        len = sizeof(servaddr);
        err = getsockname(listenfd, (struct sockaddr *) &servaddr, &len);
        if (err < 0) {
            errs++;
            printf("getsockname failed\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD,1);
        }
        port = ntohs(servaddr.sin_port);
        MPI_Get_processor_name(hostname, &namelen);
        if (split == 0 ) {
        	MPI_Send(hostname, namelen+1, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
        	MPI_Send(&port, 1, MPI_INT, 0, 1, MPI_COMM_WORLD);
        }
        else {
        	printf("%s %d\n",hostname,port);
        }
        err = listen(listenfd, 5);
        if (err < 0) {
            errs++;
            printf("listen failed\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        clilen = sizeof(cliaddr);
        connfd = accept(listenfd, (struct sockaddr *) &cliaddr, &clilen);
        if (connfd < 0) {
            printf("accept failed\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }
    else {
        /* client */
        if (split == 0) {
        	MPI_Recv(hostname, MPI_MAX_PROCESSOR_NAME, MPI_CHAR, 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        	MPI_Recv(&port, 1, MPI_INT, 1, 1, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }
        else {
        	strcpy(hostname,argv[2]);
        	port=atoi(argv[3]);
        }
        h = gethostbyname(hostname);
        if (h == NULL) {
            printf("gethostbyname failed\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        servaddr.sin_family = h->h_addrtype;
        memcpy((char *) &servaddr.sin_addr.s_addr, h->h_addr_list[0], h->h_length);
        servaddr.sin_port = htons(port);
        /* create socket */
        connfd = socket(AF_INET, SOCK_STREAM, 0);
        if (connfd < 0) {
            printf("client cannot open socket\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
        /* connect to server */
        err = connect(connfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
        if (err < 0) {
            errs++;
            printf("client cannot connect\n");fflush(stdout);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }

    MPI_Barrier(MPI_COMM_WORLD);
    /* To improve reporting of problems about operations, we change the error handler to errors return */
    printf("ready to try join %d\n",rank);
    /* MPI_Comm_set_errhandler( MPI_COMM_WORLD, MPI_ERRORS_RETURN ); */
    err = MPI_Comm_join(connfd, &intercomm);
    int numprocs,myid;
    MPI_Comm_size(intercomm,&numprocs);
    MPI_Comm_rank(intercomm,&myid);

    printf("did join %d %d %d\n",numprocs,myid,err);
    if (err)
    {
        errs++;
        printf("Error in MPI_Comm_join %d\n", err); fflush(stdout);
    }
    /* To improve reporting of problems about operations, we change the error handler to errors return */
    MPI_Comm_set_errhandler( intercomm, MPI_ERRORS_RETURN );
    for (i=0; i<COUNT; i++) {
        recvbuf[i] = -1;
        sendbuf[i] = i + COUNT*rank;
    }
    err = MPI_Sendrecv(sendbuf, COUNT, MPI_INT, 0, 0, recvbuf, COUNT, MPI_INT, 0, 0, intercomm, MPI_STATUS_IGNORE);
    printf("did  MPI_Sendrecv %d %d %d %d\n",err,MPI_SUCCESS,recvbuf[0],recvbuf[1]); fflush(stdout);

    if (err != MPI_SUCCESS) {
        errs++;
        printf( "Error in MPI_Sendrecv on new communicator\n" );fflush(stdout);
    }
    for (i=0; i<COUNT; i++) {
        if (recvbuf[i] != ((rank+1)%2) * COUNT + i)
            errs++;
    }
    MPI_Barrier(MPI_COMM_WORLD);
    printf("errs=%d\n",errs);
    err = MPI_Comm_disconnect(&intercomm);
    if (err != MPI_SUCCESS) {
        errs++;
        printf( "Error in MPI_Comm_disconnect\n" );fflush(stdout);
    }
    MPI_Finalize();
    return errs;
}
