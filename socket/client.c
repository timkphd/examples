/*
1161  cc  cs.c -o theclient
1162  cc -DSERVER cs.c -o theserver
1163  ./theclient 10.15.0.161

 594  cc  cs.c -o theclient
 595  cc -DSERVER cs.c -o theserver
 596  ./theserver
*/

#include <stdio.h>
#include <time.h>
#include <unistd.h>
char rbuff[100];
char sbuff[100];

void getit();
void getit() {
  time_t now;
  struct tm *timeinfo;
  time(&now);
  timeinfo = localtime(&now);
  for (int i=0 ; i<100; i++ )sbuff[i]=(char)0;
  strftime(sbuff, sizeof(sbuff), "Today is %A, %B %d, %Y. Time: %I:%M:%S %p", timeinfo);

}
#ifndef COUNT
#define COUNT 10
#endif
#ifndef PORT
#define PORT 20000
#endif

#include <netinet/in.h> //structure for storing address information
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h> //for socket APIs
#include <sys/types.h>
#include <arpa/inet.h>
#include <string.h>

int main(int argc, char const* argv[]) {

if (strstr(argv[1], "serv") != NULL) 
{
/* Server code */

    // printf(" create server socket similar to what was done in client program\n");
    int servSockD = socket(AF_INET, SOCK_STREAM, 0);


    // define server address
    struct sockaddr_in servAddr;

    servAddr.sin_family = AF_INET;
    servAddr.sin_port = htons(PORT);
    if (argc > 2)
    	servAddr.sin_addr.s_addr = inet_addr(argv[1]);
    else
    	servAddr.sin_addr.s_addr = INADDR_ANY;

    // bind socket to the specified IP and port
    bind(servSockD, (struct sockaddr*)&servAddr,
         sizeof(servAddr));

    // listen for connections
    listen(servSockD, 1);

    // integer to hold client socket.
    int clientSocket = accept(servSockD, NULL, NULL);

    // send's messages to client socket
    for (int ic=0 ; ic<COUNT; ic++) {
    getit();
    printf("SENDING %s\n",sbuff);
    send(clientSocket, sbuff, sizeof(sbuff), 0);
    recv(clientSocket, rbuff, sizeof(rbuff), 0);
    printf("From client: %s\n",rbuff);
    sleep(1);
    }

    return 0;
}

else

{
/* Client code */

    int sockD = socket(AF_INET, SOCK_STREAM, 0);

    struct sockaddr_in servAddr;

    servAddr.sin_family = AF_INET;
    servAddr.sin_port = htons(PORT); // use some unused port number
    if (argc > 2)
    	servAddr.sin_addr.s_addr = inet_addr(argv[2]);
    else {
    	//servAddr.sin_addr.s_addr = INADDR_ANY;
	fprintf(stderr, "client requires server address\n");
	exit(1);
   }

    int connectStatus
        = connect(sockD, (struct sockaddr*)&servAddr,
                  sizeof(servAddr));

    if (connectStatus == -1) {
        printf("Error...\n");
    }

    else {
    for (int ic=0 ; ic<COUNT; ic++) {
    recv(sockD, rbuff, sizeof(rbuff), 0);
    printf("From server: %s\n",rbuff);
    sleep(1);
    getit();
    printf("SENDING %s\n",sbuff);
    send(sockD, sbuff, sizeof(sbuff), 0);
    }
    }

    return 0;
}
}
