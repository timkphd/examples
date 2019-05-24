#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <netdb.h>
#include <unistd.h>
#define COUNT 1024
/*      in in.h is this socket structure
*       Socket address, internet style.
*       struct sockaddr_in {
*          short   sin_family;
*          u_short sin_port;
*          struct  in_addr sin_addr;
*          char    sin_zero[8];
*      };
*/
int main(int argc, char *argv[]){
        char DATA[128],DATA_S[100],reply[128],abyte[1];

        int s,i,nc;
        struct sockaddr_in dest;          /* destination socket address */
        struct hostent *hp;               /* host structure pointer */
        int portnumber=18482;
        #define HOST "slic15.sdsc.edu"
        int ierr,x,y;
int sendbuf[COUNT], recvbuf[COUNT];
  MPI_Comm bluem;
  char astr[9];


	int myid, numprocs;
    int resultlen;
	char myname[MPI_MAX_PROCESSOR_NAME];
	MPI_Init(&argc,&argv);
	MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&myid);
	MPI_Get_processor_name(myname,&resultlen);
	printf("C says Hello from %4d on %s\n",myid,myname);

        /* Converts host name into network address. */
        if(argc > 1) {
                hp = gethostbyname(argv[1]);
        }
        else {
                hp = gethostbyname(HOST);
        }
        dest.sin_family = hp->h_addrtype; /* addr type (AF_INET) */
        bcopy(hp->h_addr_list[0], &dest.sin_addr, hp->h_length);
        if(argc > 2) {
                dest.sin_port = htons(atoi(argv[2]));
        }
        else {
                dest.sin_port = htons(portnumber);
        }
        /* create port */
        if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
                perror("client, cannot open socket");
                exit(1);
        }
        if (connect (s, (struct sockaddr *) &dest, sizeof(dest)) < 0) {
                close(s);
                perror("client, connect failed");
                exit(1);
        }
        //read(s,astr,4);
        //printf("%s\n",astr);
        ierr=MPI_Comm_join(s,&bluem);
        printf("MPI_Comm_join returned %d\n",ierr);
        if (ierr != 0) {
                 close(s);
                perror("MPI_Comm_join failed");
                exit(1);
        }

        MPI_Comm_size(bluem,&numprocs);
        MPI_Comm_rank(bluem,&myid);
        MPI_Comm_set_errhandler( bluem, MPI_ERRORS_RETURN );
        printf("new size %d  new rank %d\n",numprocs,myid);
            for (i=0; i<COUNT; i++) {
        recvbuf[i] = -2;
        sendbuf[i] = i + COUNT;
    }

    ierr = MPI_Sendrecv(sendbuf, COUNT, MPI_INT, 0, 0, recvbuf, COUNT, MPI_INT, 0, 0, bluem, MPI_STATUS_IGNORE);
    printf("did  MPI_Sendrecv %d %d %d %d\n",ierr,MPI_SUCCESS,recvbuf[0],recvbuf[1]); fflush(stdout);
        MPI_Finalize(); 
        close(s);
    }
