#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]){

  int sendToResult;
  int socketDescriptor = socket(AF_INET, SOCK_DGRAM, 0);
  struct sockaddr_in serverAddr;
  const unsigned short int portNum = 25344;
  char msg_array[1026];

  // Create dummy message
  for(int i = 0; i < 1026; i++){
    msg_array[i] = i + '0';
  }

  if(socketDescriptor < 0){
    printf("Could not create a socket. \n");
    exit(1);
  }

  serverAddr.sin_family = AF_INET;          // sets the server address to type AF_INET
  inet_aton(argv[1], &serverAddr.sin_addr); // this sets the server address
  serverAddr.sin_port = htons(portNum);     // sets the server port


  for(int i = 0; i < atoi(argv[2]); i++){
    sendToResult = sendto(socketDescriptor, msg_array, 1026, 0, (struct sockaddr *) &serverAddr, sizeof(serverAddr));
    if(sendToResult < 0){
      printf("%d: Could not send data to the server.\n", sendToResult);
      exit(1);
    }
    else{
      printf("%d: Message Successfully Sent!\n", sendToResult);
    }
  }

  return 0;
}