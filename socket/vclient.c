#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <time.h>
/* https://www.codeconvert.ai/python-to-c-converter */
#define PORT 20000
#define COUNT 10

void server() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);
    char buffer[100] = {0};

    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed");
        exit(EXIT_FAILURE);
    }

    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
        perror("accept");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < COUNT; i++) {
        time_t now = time(NULL);
        char *time_str = asctime(localtime(&now));
        printf("SENDING %s\n",(char*)time_str);
        send(new_socket, time_str, strlen(time_str), 0);
        recv(new_socket, buffer, 100, 0);
        printf("on server: %s\n", buffer);
        sleep(1);
    }

    close(new_socket);
    close(server_fd);
}

void client(const char *host) {
    int sock = 0;
    struct sockaddr_in serv_addr;
    char buffer[100] = {0};

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        return;
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(PORT);
    serv_addr.sin_addr.s_addr = inet_addr(host);

    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection Failed \n");
        return;
    }

    for (int i = 0; i < COUNT; i++) {
        recv(sock, buffer, 100, 0);
        sleep(1);
        time_t now = time(NULL);
        char *time_str = asctime(localtime(&now));
        printf("SENDING %s\n",(char*)time_str);
        send(sock, time_str, strlen(time_str), 0);
        printf("on client: %s\n", buffer);
    }

    close(sock);
}

int main(int argc, char *argv[]) {

    if (strstr(argv[1], "serv") != NULL) {
        server();
    } else if (strstr(argv[1], "clie") != NULL && argc == 3) {
        client(argv[2]);
    } else {
        fprintf(stderr, "server\n");
        fprintf(stderr, "client address\n");
        return EXIT_FAILURE;
    }

    return 0;
}
