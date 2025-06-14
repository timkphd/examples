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
char buff[100];
void getit();
void getit() {
   time_t now = time(NULL) ;
   struct tm tm_now ;
   localtime_r(&now, &tm_now) ;
   strftime(buff, sizeof(buff), "%Y-%m-%d, time is %H:%M:%S", &tm_now) ;
}
#ifndef COUNT
#define COUNT 10
#endif
#ifdef SERVER
#include <netinet/in.h> //structure for storing address information
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h> //for socket APIs
#include <sys/types.h>
#include <arpa/inet.h>
int main(int argc, char const* argv[])
{

    // create server socket similar to what was done in
    // client program
    int servSockD = socket(AF_INET, SOCK_STREAM, 0);


    // define server address
    struct sockaddr_in servAddr;

    servAddr.sin_family = AF_INET;
    servAddr.sin_port = htons(9001);
    if (argc > 1)
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
    send(clientSocket, buff, sizeof(buff), 0);
    recv(clientSocket, buff, sizeof(buff), 0);
    printf("From client: %s\n",buff);
    sleep(1);
    }

    return 0;
}

#else

#include <netinet/in.h> //structure for storing address information
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h> //for socket APIs
#include <sys/types.h>
#include <arpa/inet.h>
#include <string.h>

int main(int argc, char const* argv[])
{
    int sockD = socket(AF_INET, SOCK_STREAM, 0);

    struct sockaddr_in servAddr;

    servAddr.sin_family = AF_INET;
    servAddr.sin_port
        = htons(9001); // use some unused port number
    if (argc > 1)
    	servAddr.sin_addr.s_addr = inet_addr(argv[1]);
    else
    	servAddr.sin_addr.s_addr = INADDR_ANY;

    int connectStatus
        = connect(sockD, (struct sockaddr*)&servAddr,
                  sizeof(servAddr));

    if (connectStatus == -1) {
        printf("Error...\n");
    }

    else {
    for (int ic=0 ; ic<COUNT; ic++) {
    recv(sockD, buff, sizeof(buff), 0);
    printf("From server: %s\n",buff);
    sleep(1);
    getit();
    send(sockD, buff, sizeof(buff), 0);
    }
    }

    return 0;
}

#endif
