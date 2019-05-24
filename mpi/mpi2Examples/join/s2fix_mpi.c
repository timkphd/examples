/* [tkaiser@slic15 ~]$ cat small_server.c  */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <unistd.h>
#ifdef DO_MPI
#include <mpi.h>
#endif

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


int main(int argc, char *argv[]) {

  struct sockaddr_in src;                  /* socket address for this server */
  int socksize, val=1;                     /* the size of the socket address */
  int portnumber=0;                    /* portnumber server listens on   */
  int server, client;                      /* socket ids for server & client */
  Message *message=NULL;
  int len;
  FLT **m1;
#ifdef DO_MPI
	int myid, numprocs;
	int resultlen;
	char myname[MPI_MAX_PROCESSOR_NAME];
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	MPI_Get_processor_name(myname,&resultlen);
	printf("C says Hello from %4d on %s\n",myid,myname);
#endif
  int ptemp,test;
  char pname[128],abyte[1];
  #define reply "GOT IT"
  int n,i,j,mcount;
  int a1,a2,a3,a4;
  n=4;
  m1=matrix(1,n,1,n);
  mcount=0;

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

  /* Service the needs of this client. */
  while (1) {

    /* The client is sending us a message or has exited. */
    if ((message = read_msg(client)) == NULL)
      { close(client); close(server); exit(1); }

    if (message->type == 15) {
    			mcount++;
                printf("%s\n",message->args);
                sscanf(message->args,"%d %d %d %d",&a1,&a2,&a3,&a4);
                m1[1][mcount]=a1;
                m1[2][mcount]=a2;
                m1[3][mcount]=a3;
                m1[4][mcount]=a4;
                if(mcount == 4){
     				for (i=1;i<=4;i++) {
    					for (j=1;j<=4;j++) 
    						printf(" %g",m1[i][j]);
        			printf("\n");
	}
   				over(m1,n);
    				for (i=1;i<=4;i++) {
    					for (j=1;j<=4;j++) 
    						printf(" %g",m1[i][j]);
        			printf("\n");
	}
}                
                abyte[0]=(char)strlen(reply);
                write(client,abyte,1);
                write(client, reply, strlen(reply));
        }
    free_msg(&message, ALL);
  }
#ifdef DO_MPI
      MPI_Finalize();
#endif
}

/*****************************************************************************/
/*                                                                           */
/*  This routine reads a message coming in over a socket.  The format of a   */
/*  message looks like:                                                      */
/*                                                                           */
/*   *  1-byte value denoting the type of the message payload                */
/*   * 15-byte character string representing the size of the message body    */
/*   *  n-byte character string representing the message body itself         */
/*                                                                           */
/*  This message format was selected in an attempt to make it as portable    */
/*  as possible (thereby avoiding problems such as different byte-orderings  */
/*  on different platforms, different floating point representations, etc.)  */
/*                                                                           */
Message *read_msg(int sock_hndl) {

  char head[16];                           /* string form of message header  */
  Message *incoming;                       /* storage for incoming message   */
  int rcvd, count, size;


  /* Make space for the incoming message header and check for error. */
  if ((incoming = (Message *)malloc(sizeof(Message))) == NULL) {
    fprintf(stderr, "  unable to get enough memory.\n");
    return NULL;
  }

  /* Read in the message header. */
  rcvd = 0; count = 0; size = 16;
  while (rcvd < size) {
    rcvd += read(sock_hndl, head + rcvd, size - rcvd); count++;
    if (count > 256) { free_msg(&incoming, HEADER); return NULL; }
  }

  /* Determine the type and size of message payload. */
  incoming->type   = (int) head[0];
  incoming->nbytes = (int)(head[1]);
   printf("type %d bytes %d\n",incoming->type,incoming->nbytes);

  /* Make space for the incoming message body and check for error. */
  if ((incoming->args = (char *)malloc(incoming->nbytes)) == NULL)
    { free_msg(&incoming, HEADER); return NULL; }

  /* Read in the message body. */
  rcvd = 0; count = 0; size = incoming->nbytes;
  while (rcvd < size) {
    rcvd += read(sock_hndl, incoming->args + rcvd, size - rcvd); count++;
    if (count > 256) { free_msg(&incoming, ALL); return NULL; }
  }

  /* Return our shiny new message. */
  return incoming;

}

/*  This routine frees memory occupied by the specified message.             */
void free_msg(Message **message, int how_much) {

  if (how_much == ALL) { free((*message)->args); (*message)->args = NULL; }
  free(*message); *message = NULL;

}
/* void catch(int signo) { } */

/*
[tkaiser@slic15 ~]$


The deal is that the byte order is being switched when getting passed to the socket routines

Note:

44975 afaf  (this works)
44000 abe0   57515 e0ab (this is the mapping)

solution is call htons on port number
*/






void mset(FLT **m, int n, int in) {
	int i,j;
    for(i=1;i<=n;i++) 
       for(j=1;j<=n;j++) {
           if(i == j) {
               m[i][j]=in; 
           } else {
               m[i][j]=i+j; 
           }
       }
   
}

/*
The routine matrix was  adapted from
Numerical Recipes in C The Art of Scientific Computing
Press, Flannery, Teukolsky, Vetting
Cambridge University Press, 1988.
*/
FLT **matrix(int nrl,int nrh,int ncl,int nch)
{
    int i;
        FLT **m;
        m=(FLT **) malloc((unsigned) (nrh-nrl+1)*sizeof(FLT*));
        if (!m){
             printf("allocation failure 1 in matrix()\n");
             exit(1);
        }
        m -= nrl;
        for(i=nrl;i<=nrh;i++) {
            if(i == nrl){
                    m[i]=(FLT *) malloc((unsigned) (nrh-nrl+1)*(nch-ncl+1)*sizeof(FLT));
                    if (!m[i]){
                         printf("allocation failure 2 in matrix()\n");
                         exit(1);
                    }
                    m[i] -= ncl;
            }
            else {
                m[i]=m[i-1]+(nch-ncl+1);
            }
        }
        return m;
}

void over(FLT ** mat,int size)
{
        int k, jj, kp1, i, j, l, krow, irow;
        FLT pivot, temp;
        FLT sw[2000][2];
        for (k = 1 ;k<= size ; k++)
        {
                jj = k;
                if (k != size)
                {
                        kp1 = k + 1;
                        pivot = fabs(mat[k][k]);
                        for( i = kp1;i<= size ;i++)
                        {
                                temp = fabs(mat[i][k]);
                                if (pivot < temp)
                                {
                                        pivot = temp;
                                        jj = i;
                                }
                        }
                }
                sw[k][0] =k;
                sw[k][1] = jj;
                if (jj != k)
                        for (j = 1 ;j<= size; j++)
                        {
                                temp = mat[jj][j];
                                mat[jj][j] = mat[k][ j];
                                mat[k][j] = temp;
                        }
                for (j = 1 ;j<= size; j++)
                        if (j != k)
                                mat[k][j] = mat[k][j] / mat[k][k];
                mat[k][k] = 1.0 / mat[k][k];
                for (i = 1; i<=size; i++)
                        if (i != k)
                                for (j = 1;j<=size; j++)
                                        if (j != k)
                                                mat[i][j] = mat[i][j] - mat[k][j] * mat[i][k];
                for (i = 1;i<=size;i++)
                        if (i != k)
                                mat[i][k] = -mat[i][k] * mat[k][k];
        }
        for (l = 1; l<=size; ++l)
        {
                k = size - l + 1;
                krow = sw[k][0];
                irow = sw[k][1];
                if (krow != irow)
                        for (i = 1; i<= size; ++i)
                        {
                                temp = mat[i][krow];
                                mat[i][krow] = mat[i][irow];
                                mat[i][irow] = temp;
                        }
        }
}

FLT system_clock(FLT *x) {
	FLT t;
	FLT six=1.0e-6;
	struct timeval tb;
	struct timezone tz;
	gettimeofday(&tb,&tz);
	t=(FLT)tb.tv_sec+((FLT)tb.tv_usec)*six;
 	if(x){
 		*x=t;
 	}
 	return(t);
}

