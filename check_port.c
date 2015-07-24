#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>

void ConnectServer(struct sockaddr_in server){
	char ip[INET_ADDRSTRLEN];
	int sock=socket(AF_INET, SOCK_STREAM, 0);
	struct timeval start, end;
	double timeuse;
	gettimeofday(&start, NULL);
	int ret=connect(sock, (struct sockaddr*)&server, sizeof(server));
	gettimeofday(&end, NULL);
	timeuse=(end.tv_sec - start.tv_sec) + (double)(end.tv_usec - start.tv_usec)/1000000;
	printf("Connect %s:%d ", inet_ntop(AF_INET, &server.sin_addr, ip, INET_ADDRSTRLEN), ntohs(server.sin_port));
	if (ret==0){
		printf("\033[47;31m[ OK ]\033[0m. Time:%fs\n", timeuse);
	}
	else{
		printf("\033[47;31m[ Down ]\033[0m. %s\n", strerror(errno));
	}
	close(sock);
}

int main(int argc, char *argv[]){
	if (argc < 3){
		printf("Usage: %s IP Port\n", argv[0]);
		exit(1);
	}
	struct sockaddr_in server;
	memset(&server, '\0', sizeof(server));
	struct addrinfo hints, *res;
	memset(&hints, '\0', sizeof(hints));
	hints.ai_socktype=SOCK_STREAM;
	getaddrinfo(argv[1], argv[2], &hints, &res);
	server=*(struct sockaddr_in *)res->ai_addr;
	freeaddrinfo(res);
	ConnectServer(server);
	return 0;
}
