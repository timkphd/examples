/* [tkaiser@slic15 ~]$ cat small_server.c  */
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
#define FLT double

/* utility routines */
FLT system_clock(FLT *x);
FLT **matrix(int nrl,int nrh,int ncl,int nch);

/* work routines */
void mset(FLT **m, int n, int in);
FLT mcheck(FLT **m, int n, int in);
void over(FLT ** mat,int size);


#define  HEADER            16       /* which fields in a message to discard  */
#define  ALL               32


typedef struct {
  int   nbytes;                     /* number of bytes in the argument list  */
  int   type;                       /* message type (filename / line number) */
  char *args;                       /* string form of the list of arguments  */
} Message;

Message *read_msg(int sock_hndl);
void free_msg(Message **message, int how_much);

#define COUNT 1024

int main(int argc, char *argv[]) {

  struct sockaddr_in src;                  /* socket address for this server */
  int socksize, val=1;                     /* the size of the socket address */
  int portnumber=0;                    /* portnumber server listens on   */
  int server, client;                      /* socket ids for server & client */
  Message *message=NULL;
  int len;
  int ierr;
  FLT **m1;
	int myid, numprocs;
	int resultlen;
	char myname[MPI_MAX_PROCESSOR_NAME];
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	MPI_Get_processor_name(myname,&resultlen);
	printf("C says Hello from %4d on %s\n",myid,myname);
  int ptemp,test;
  int x,y;
  int sendbuf[COUNT], recvbuf[COUNT], i;
  MPI_Comm bluem;
  char pname[128],abyte[1];
  #define reply "GOT IT"
  int n,j,mcount;
  int a1,a2,a3,a4;

  if(argc > 1)sscanf(argv[1],"%d",&portnumber);
  len = sizeof(src);
   bzero((char *)&src, len);

    /* Set up address structure: any host, wildcard port */
    src.sin_family = AF_INET;
    if(portnumber != 0) {
       src.sin_port = ntohs(portnumber);
       src.sin_addr.s_addr = 0;
    }
    else {
       src.sin_addr.s_addr = INADDR_ANY;
       src.sin_port = 0;
    }

  if ((server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    { fprintf(stderr, "\n Unable to open a socket.\n"); exit(1); }

  /* Declare that this socket address may be reused. */
  setsockopt(server, SOL_SOCKET, SO_REUSEADDR, (void *) &val, sizeof(val));

  /* Bind to the socket. */
  if (bind(server, (struct sockaddr *) &src, sizeof(src)) < 0) {

    fprintf(stderr, "\n Unable to bind to this port number.");
    exit(1);
  }

  /* Indicate a willingness to accept connections on this socket. */
  listen(server, 5);

    /* get some socket info (including what port the system gave us */
    if (getsockname(server, (struct sockaddr *)&src, (socklen_t *)&len) < 0)
        return -1;

    printf("Listening on port %d %d\n", portnumber,ntohs(src.sin_port));

  /* We have been contacted by a client. */
  socksize = sizeof(src);
  client = accept(server, (struct sockaddr *) &src, (socklen_t*)&socksize);
//  write(client, "conn", 4);
          ierr=MPI_Comm_join(client,&bluem);
        printf("MPI_Comm_join returned %d\n",ierr);
        if (ierr != 0) {
                 close(client);
                perror("MPI_Comm_join failed");
                exit(1);
        }
        MPI_Comm_set_errhandler( bluem, MPI_ERRORS_RETURN );
        MPI_Comm_size(bluem,&numprocs);
        MPI_Comm_rank(bluem,&myid);
        printf("new size %d  new rank %d\n",numprocs,myid);
            for (i=0; i<COUNT; i++) {
        recvbuf[i] = -1;
        sendbuf[i] = i ;
    }

    ierr = MPI_Sendrecv(sendbuf, COUNT, MPI_INT, 0, 0, recvbuf, COUNT, MPI_INT, 0, 0, bluem, MPI_STATUS_IGNORE);
    printf("did  MPI_Sendrecv %d %d %d %d\n",ierr,MPI_SUCCESS,recvbuf[0],recvbuf[1]); fflush(stdout);

        MPI_Finalize(); 
        close(client);
    }
