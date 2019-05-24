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
#include <mpi.h>


#define  HEADER            16       /* which fields in a message to discard  */
#define  ALL               32


typedef struct {
  int   nbytes;                     /* number of bytes in the argument list  */
  int   type;                       /* message type (filename / line number) */
  char *args;                       /* string form of the list of arguments  */
} Message;

Message *read_msg(int sock_hndl);
void free_msg(Message **message, int how_much);


int s2(int argc, char *argv[]) {

  struct sockaddr_in src;                  /* socket address for this server */
  int socksize, val=1;                     /* the size of the socket address */
  int portnumber=0;
  int server, client;                      /* socket ids for server & client */
  Message *message=NULL;
  int len;

  int ptemp,test;
  char pname[128],abyte[1];
  #define reply "GOT IT"
  if(argc > 1)sscanf(argv[1],"%d",&portnumber);
  len = sizeof(src);
   bzero((char *)&src, len);

    /* Set up address structure: any host, wildcard port */
    src.sin_family = AF_INET;
    if(portnumber != 0) {
       src.sin_port = portnumber;
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

    printf("Listening on port %d %d\n", src.sin_port, ntohs(src.sin_port));
    portnumber=ntohs(src.sin_port);
    MPI_Send(&portnumber,1,MPI_INT,0,1234,MPI_COMM_WORLD);

  /* We have been contacted by a client. */
  socksize = sizeof(src);
  client = accept(server, (struct sockaddr *) &src, (socklen_t*)&socksize);

  /* Service the needs of this client. */
  while (1) {

    /* The client is sending us a message or has exited. */
    if ((message = read_msg(client)) == NULL)
      { close(client); close(server); exit(1); }

    if (message->type == 15) {
                printf("%s\n",message->args);
                abyte[0]=(char)strlen(reply);
                write(client,abyte,1);
                write(client, reply, strlen(reply));
        }
    free_msg(&message, ALL);
  }
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

