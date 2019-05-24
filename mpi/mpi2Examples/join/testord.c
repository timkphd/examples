#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char *argv[]){
int inport,outport,back;
inport=atoi(argv[1]);
outport=htons(inport);
back=htons(outport);
printf("%d %d %d\n",inport,outport,back);
}
