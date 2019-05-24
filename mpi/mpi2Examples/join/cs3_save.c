
/* [peloton:~] tkaiser% cat small_client.c  */
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <unistd.h>
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
        for(i=0;i<100;i++) {
                DATA_S[i]=(char)0;
                reply[i]=0;
        }
        for(i=0;i<10;i++) {
                DATA_S[i]='i';
        }
        fgets(DATA_S,100,stdin);
        while(strlen(DATA_S) > 1) {
                DATA[0]=(char)15;
                DATA[1]=(char)strlen(DATA_S);
                strcpy(DATA+16,DATA_S);
                write(s, DATA, 16+strlen(DATA_S));
                read(s,abyte,1);
                nc=read(s,reply,(int)abyte[0]);
                printf("%d %d %s\n",(int)abyte[0],nc,reply);
                for(i=0;i<100;i++)
                        DATA_S[i]=(char)0;
                fgets(DATA_S,100,stdin);
        }
        close(s);
        exit(0);
}

